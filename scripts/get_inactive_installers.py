#!/usr/bin/env python3
"""
Script to fetch inactive installers and their fieldreports from the Finalisten ERP database.
Used by Robot Framework tests to dynamically get inactive installer fieldreport URLs.

Database connection is configured via environment variables:
- DATABASE_URL: Full PostgreSQL connection URL (preferred)
  OR
- DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD: Individual connection parameters

Usage:
    python get_inactive_installers.py

Output:
    Returns JSON with:
    - inactive_installer_ids: List of employee IDs who are inactive
    - inactive_installer_names: Corresponding names
    - fieldreport_slugs: Slugs of UNAPPROVED fieldreports with inactive installers
    - fieldreport_installer_map: Maps each slug to its installer name
"""

import os
import sys
import json

try:
    import psycopg2
except ImportError:
    print(json.dumps({
        "error": "psycopg2 not installed. Run: pip install psycopg2-binary",
        "success": False,
        "installer_ids": [],
        "installer_names": [],
        "fieldreport_slugs": []
    }))
    sys.exit(1)


def get_db_connection():
    """
    Get database connection using environment variables.
    Supports DATABASE_URL or individual DB_* variables.
    """
    database_url = os.environ.get('DATABASE_URL')
    
    if database_url:
        # Parse DATABASE_URL (Heroku-style)
        return psycopg2.connect(database_url, sslmode='require')
    
    # Fallback to individual variables
    host = os.environ.get('DB_HOST', 'localhost')
    port = os.environ.get('DB_PORT', '5432')
    dbname = os.environ.get('DB_NAME', 'finalistenerp')
    user = os.environ.get('DB_USER', 'postgres')
    password = os.environ.get('DB_PASSWORD', '')
    
    return psycopg2.connect(
        host=host,
        port=port,
        dbname=dbname,
        user=user,
        password=password
    )


def get_inactive_installers_with_fieldreports():
    """
    Query the database to find:
    1. Inactive employees (employee_status = False)
    2. UNAPPROVED fieldreports assigned to them (approved = 'Unapprove')
    
    Returns fieldreport slugs that can be used to construct edit URLs directly
    """
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Query to find UNAPPROVED fieldreports from inactive installers
        # These are editable and have inactive installers assigned
        query = """
            SELECT DISTINCT 
                f.slug,
                e.id as employee_id,
                CONCAT(e.first_name, ' ', e.last_name) as installer_name
            FROM fieldreport_fieldreport f
            INNER JOIN employee_employment e ON f.installer_name_id = e.id
            WHERE e.employee_status = FALSE
              AND f.approved = 'Unapprove'
            ORDER BY f.slug
            LIMIT 20
        """
        
        cursor.execute(query)
        results = cursor.fetchall()
        
        # Also get the unique inactive installers for logging
        cursor.execute("""
            SELECT DISTINCT e.id, CONCAT(e.first_name, ' ', e.last_name) as full_name
            FROM employee_employment e
            INNER JOIN fieldreport_fieldreport f ON f.installer_name_id = e.id
            WHERE e.employee_status = FALSE
            ORDER BY e.id
            LIMIT 10
        """)
        installer_results = cursor.fetchall()
        
        cursor.close()
        conn.close()
        
        if results:
            fieldreport_slugs = [row[0] for row in results]
            installer_map = {row[0]: {"id": row[1], "name": row[2]} for row in results}
            installer_ids = [str(row[0]) for row in installer_results]
            installer_names = [row[1] for row in installer_results]
            
            return {
                "success": True,
                "fieldreport_count": len(results),
                "fieldreport_slugs": fieldreport_slugs,
                "fieldreport_installer_map": installer_map,
                "installer_count": len(installer_results),
                "installer_ids": installer_ids,
                "installer_names": installer_names
            }
        else:
            return {
                "success": True,
                "fieldreport_count": 0,
                "fieldreport_slugs": [],
                "fieldreport_installer_map": {},
                "installer_count": 0,
                "installer_ids": [],
                "installer_names": [],
                "message": "No UNAPPROVED fieldreports with inactive installers found"
            }
            
    except psycopg2.OperationalError as e:
        return {
            "success": False,
            "error": f"Database connection failed: {str(e)}",
            "fieldreport_slugs": [],
            "installer_ids": [],
            "installer_names": []
        }
    except psycopg2.Error as e:
        return {
            "success": False,
            "error": f"Database query failed: {str(e)}",
            "fieldreport_slugs": [],
            "installer_ids": [],
            "installer_names": []
        }


def main():
    """Main entry point - outputs JSON result"""
    result = get_inactive_installers_with_fieldreports()
    print(json.dumps(result, indent=2))
    
    # Exit with error code if failed
    if not result.get("success", False):
        sys.exit(1)


if __name__ == "__main__":
    main()
