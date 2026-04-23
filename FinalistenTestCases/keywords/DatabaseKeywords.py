import os
import psycopg2

class DatabaseKeywords:
    """
    Custom Robot Framework library for direct database interactions 
    in the Finalisten ERP system.
    """
    
    def __init__(self):
        self.db_url = os.environ.get('DATABASE_URL')
        if not self.db_url:
            print("WARNING: DATABASE_URL environment variable is not set. Database operations will use fallbacks.")

    def force_user_language_to_english(self, email):
        """
        Directly updates the language_setting in the database for the given email.
        """
        if not self.db_url:
            print(f"Skipping language force for {email}: DATABASE_URL not set.")
            return

        conn = None
        try:
            conn = psycopg2.connect(self.db_url, sslmode='require')
            cur = conn.cursor()
            
            # Execute the update query
            query = "UPDATE employee_employment SET language_setting = 'English' WHERE employee_email = %s"
            cur.execute(query, (email,))
            
            # Commit the changes
            conn.commit()
            
            # Verify if any row was updated
            if cur.rowcount == 0:
                print(f"Warning: No user found with email {email}")
            else:
                print(f"Successfully forced language to English for {email}")
                
            cur.close()
        except Exception as e:
            raise Exception(f"Database operation failed: {str(e)}")
        finally:
            if conn:
                conn.close()

    def get_valid_customer_and_project(self):
        """
        Fetches a customer name and a related project name from the database.
        Returns a dictionary with 'customer' and 'project' keys.
        """
        if not self.db_url:
            print("DATABASE_URL not set, returning fallback customer and project.")
            return {"customer": "Arcona Aktiebolag", "project": "Systemkameran"}

        conn = None
        try:
            conn = psycopg2.connect(self.db_url, sslmode='require')
            cur = conn.cursor()
            
            # Query to find a customer who has at least one project
            # This handles the AJAX dependency where project depends on customer
            query = """
                SELECT c.name, p.project_name 
                FROM account_customer c
                JOIN projects_project p ON c.id = p.related_customer_id
                WHERE p.is_active = True AND c.is_active = True
                LIMIT 1
            """
            cur.execute(query)
            result = cur.fetchone()
            
            if not result:
                # Fallback to any customer and project if no perfect match (unlikely in real DB)
                cur.execute("SELECT name FROM account_customer WHERE is_active = True LIMIT 1")
                cust = cur.fetchone()
                cur.execute("SELECT project_name FROM projects_project WHERE is_active = True LIMIT 1")
                proj = cur.fetchone()
                return {"customer": cust[0] if cust else "Arcona Aktiebolag", 
                        "project": proj[0] if proj else "Systemkameran"}
            
            return {"customer": result[0], "project": result[1]}
        except Exception as e:
            print(f"Error fetching data from DB: {str(e)}")
            self._debug_list_tables_and_columns()
            return {"customer": "Arcona Aktiebolag", "project": "Systemkameran"}
        finally:
            if conn:
                conn.close()

    def get_valid_installer_name(self):
        """
        Fetches an active installer name from the database.
        """
        if not self.db_url:
            print("DATABASE_URL not set, returning fallback installer.")
            return "Admin Finalisten"

        conn = None
        try:
            conn = psycopg2.connect(self.db_url, sslmode='require')
            cur = conn.cursor()
            
            # Try to find correct name column
            cur.execute("SELECT column_name FROM information_schema.columns WHERE table_name = 'employee_employment'")
            cols = [c[0] for c in cur.fetchall()]
            name_col = 'display_name'
            if 'display_name' not in cols:
                if 'employee_name' in cols: name_col = 'employee_name'
                elif 'name' in cols: name_col = 'name'
                elif 'first_name' in cols: name_col = 'first_name'
            
            query = f"SELECT {name_col} FROM employee_employment WHERE is_active = True LIMIT 1"
            cur.execute(query)
            result = cur.fetchone()
            return result[0] if result else "Admin Finalisten"
        except Exception as e:
            print(f"Error fetching installer from DB: {str(e)}")
            return "Admin Finalisten"
        finally:
            if conn:
                conn.close()

    def _debug_list_tables_and_columns(self):
        """Internal helper to log schema info to help debug relation errors."""
        if not self.db_url:
            return
            
        try:
            conn = psycopg2.connect(self.db_url, sslmode='require')
            cur = conn.cursor()
            cur.execute("SELECT tablename FROM pg_catalog.pg_tables WHERE schemaname = 'public'")
            tables = [t[0] for t in cur.fetchall()]
            print(f"SCHEMA DEBUG: Tables available: {tables}")
            cur.close()
            conn.close()
        except:
            pass

    def create_fixed_agreement(self, project_id, name="Auto Test Agreement", amount=5000.00):
        """
        Creates a fixed agreement for a given project directly in the DB.
        """
        if not self.db_url:
            print("DATABASE_URL not set, cannot create fixed agreement.")
            return False

        conn = None
        try:
            conn = psycopg2.connect(self.db_url, sslmode='require')
            cur = conn.cursor()
            
            query = """
                INSERT INTO project_fixedagreement 
                (agreement_name, agreement_amount, related_project_id, agreement_status, agreement_is_retainage, agreement_total_cost)
                VALUES (%s, %s, %s, true, false, %s)
                RETURNING id;
            """
            cur.execute(query, (name, str(amount), project_id, str(amount)))
            new_id = cur.fetchone()[0]
            conn.commit()
            print(f"Successfully created fixed agreement {new_id} for project {project_id}")
            return new_id
        except Exception as e:
            print(f"Error creating fixed agreement: {str(e)}")
            return False
        finally:
            if conn:
                conn.close()

    def delete_fieldreport_by_slug(self, slug):
        """
        Deletes a field report and its related products/attachments directly from DB using the fieldreport slug.
        This is used as a cleanup fallback when UI deletion fails in CI.
        """
        if not self.db_url:
            print("DATABASE_URL not set, cannot delete field report.")
            return False

        if not slug:
            print("No slug provided, skipping delete_fieldreport_by_slug.")
            return False

        conn = None
        try:
            conn = psycopg2.connect(self.db_url, sslmode='require')
            cur = conn.cursor()

            # Find fieldreport id by slug
            cur.execute("SELECT id FROM fieldreport_fieldreport WHERE slug = %s", (slug,))
            row = cur.fetchone()
            if not row:
                print(f"No field report found for slug {slug}")
                cur.close()
                return False

            fr_id = row[0]

            # Delete attachments -> products -> fieldreport
            cur.execute(
                """
                DELETE FROM fieldreport_productinfieldreportattachment
                WHERE related_product_in_fieldreport_id IN (
                    SELECT id FROM fieldreport_productsinfieldreport WHERE fieldreport_id_id = %s
                )
                """,
                (fr_id,),
            )
            cur.execute("DELETE FROM fieldreport_productsinfieldreport WHERE fieldreport_id_id = %s", (fr_id,))
            cur.execute("DELETE FROM fieldreport_fieldreport WHERE id = %s", (fr_id,))

            conn.commit()
            cur.close()
            print(f"Deleted field report slug={slug} (id={fr_id}) via DB cleanup.")
            return True
        except Exception as e:
            try:
                if conn:
                    conn.rollback()
            except Exception:
                pass
            print(f"Error deleting field report by slug: {str(e)}")
            return False
        finally:
            if conn:
                conn.close()

    def delete_robot_fieldreports_by_message_prefix(self, prefix="Robot Framework", limit=50):
        """
        Deletes recent robot-created field reports (and related products/attachments) by matching message_to_approver prefix.
        Intended as a safety net for daily CI runs on preprod.
        """
        if not self.db_url:
            print("DATABASE_URL not set, cannot delete robot field reports.")
            return 0

        conn = None
        deleted = 0
        try:
            conn = psycopg2.connect(self.db_url, sslmode='require')
            cur = conn.cursor()

            like = prefix + "%"
            cur.execute(
                """
                SELECT id, slug
                FROM fieldreport_fieldreport
                WHERE message_to_approver ILIKE %s
                ORDER BY created_on DESC NULLS LAST
                LIMIT %s
                """,
                (like, int(limit)),
            )
            rows = cur.fetchall()
            for fr_id, slug in rows:
                cur.execute(
                    """
                    DELETE FROM fieldreport_productinfieldreportattachment
                    WHERE related_product_in_fieldreport_id IN (
                        SELECT id FROM fieldreport_productsinfieldreport WHERE fieldreport_id_id = %s
                    )
                    """,
                    (fr_id,),
                )
                cur.execute("DELETE FROM fieldreport_productsinfieldreport WHERE fieldreport_id_id = %s", (fr_id,))
                cur.execute("DELETE FROM fieldreport_fieldreport WHERE id = %s", (fr_id,))
                deleted += 1

            conn.commit()
            cur.close()
            print(f"Deleted {deleted} robot field reports with prefix '{prefix}'.")
            return deleted
        except Exception as e:
            try:
                if conn:
                    conn.rollback()
            except Exception:
                pass
            print(f"Error deleting robot field reports: {str(e)}")
            return deleted
        finally:
            if conn:
                conn.close()

