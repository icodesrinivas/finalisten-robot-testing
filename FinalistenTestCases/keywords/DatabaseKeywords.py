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
            raise Exception("DATABASE_URL environment variable is not set")

    def force_user_language_to_english(self, email):
        """
        Directly updates the language_setting in the database for the given email.
        """
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

    def get_valid_installer_name(self):
        """
        Fetches an active installer name from the database.
        """
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
