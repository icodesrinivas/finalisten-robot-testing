#!/usr/bin/env python3
"""
Batch fix Robot Framework tests to add menu visibility waits for headless Chrome.
Applies the proven pattern from contact tests to employee, customer, and supplier tests.
"""

import re
import os

def add_menu_waits_to_keywords(content, menu_var_name, submenu_var_name):
    """Add Wait Until Element Is Visible before menu interactions"""
    
    # Pattern 1: Fix "Hover Over X Menu" or "Click On X Menu" keywords
    # Add wait before Mouse Over
    content = re.sub(
        r'((?:Hover Over|Click On) \w+ Menu)\n(\s+)(Mouse Over\s+\$\{' + menu_var_name + r'\})',
        r'\1\n\2Wait Until Element Is Visible    ${' + menu_var_name + r'}    timeout=15s\n\2Sleep    1s\n\2\3',
        content
    )
    
    # Add wait and sleep after Click Element for submenu
    content = re.sub(
        r'((?:Click On|Click) \w+ Menu)\n(\s+)(Click Element\s+\$\{' + submenu_var_name + r'\})',
        r'\1\n\2Wait Until Element Is Visible    ${' + submenu_var_name + r'}    timeout=10s\n\2\3\n\2Sleep    2s',
        content
    )
    
    # Pattern 2: Direct Click Element (no keywords) - for employee tests
    content = re.sub(
        r'(Open And Login)\n(\s+)(Click Element\s+\$\{REGISTER_MENU\})',
        r'\1\n\2Wait Until Element Is Visible    ${REGISTER_MENU}    timeout=15s\n\2Sleep    1s\n\2\3',
        content
    )
    
    content = re.sub(
        r'(Click Element\s+\$\{REGISTER_MENU\})\n(\s+)(Click Element\s+\$\{EMPLOYEES_MENU\})',
        r'\1\n\2Wait Until Element Is Visible    ${EMPLOYEES_MENU}    timeout=10s\n\2Sleep    1s\n\2\3\n\2Sleep    2s',
        content
    )
    
    return content

def fix_test_file(filepath):
    """Fix a single test file"""
    print(f"Fixing: {filepath}")
    
    with open(filepath, 'r') as f:
        content = f.read()
    
    original_content = content
    
    # Determine which menu variables to use based on file
    if 'employee' in filepath:
        content = add_menu_waits_to_keywords(content, 'REGISTER_MENU', 'EMPLOYEES_MENU')
    elif 'customer' in filepath:
        content = add_menu_waits_to_keywords(content, 'REGISTER_MENU', 'CUSTOMERS_MENU')
    elif 'supplier' in filepath:
        content = add_menu_waits_to_keywords(content, 'REGISTER_MENU', 'SUPPLIERS_MENU')
    
    # Only write if content changed
    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        print(f"  ✓ Fixed!")
        return True
    else:
        print(f"  - No changes needed or already fixed")
        return False

def main():
    base_dir = "/Users/sreesrini/Desktop/Python_Work/FinalistenTesting/finalisten-robot-testing"
    
    test_files = [
        # Employee tests
        f"{base_dir}/FinalistenTestCases/employee/open_employee_create.robot",
        f"{base_dir}/FinalistenTestCases/employee/open_employee_edit.robot",
        f"{base_dir}/FinalistenTestCases/employee/open_employee_list.robot",
        # Customer tests
        f"{base_dir}/FinalistenTestCases/customer/open_customer_create.robot",
        f"{base_dir}/FinalistenTestCases/customer/open_customer_edit.robot",
        f"{base_dir}/FinalistenTestCases/customer/open_customer_list.robot",
        # Supplier tests
        f"{base_dir}/FinalistenTestCases/supplier/open_supplier_create.robot",
        f"{base_dir}/FinalistenTestCases/supplier/open_supplier_edit.robot",
        f"{base_dir}/FinalistenTestCases/supplier/open_supplier_list.robot",
    ]
    
    print("=" * 60)
    print("BATCH FIXING ROBOT FRAMEWORK TESTS FOR HEADLESS CHROME")
    print("=" * 60)
    print()
    
    fixed_count = 0
    for filepath in test_files:
        if os.path.exists(filepath):
            if fix_test_file(filepath):
                fixed_count += 1
        else:
            print(f"NOT FOUND: {filepath}")
    
    print()
    print("=" * 60)
    print(f"SUMMARY: Fixed {fixed_count}/{len(test_files)} files")
    print("=" * 60)

if __name__ == "__main__":
    main()
