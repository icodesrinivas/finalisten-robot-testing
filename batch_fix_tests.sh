#!/bin/bash

# Batch fix script to add menu visibility waits to all simple CRUD tests
# This applies the proven pattern from contact tests to employee, customer, and supplier tests

echo "Applying menu wait pattern to employee, customer, and supplier tests..."

# Function to check if a file needs the menu wait pattern
needs_fix() {
    local file=$1
    # Check if file already has "Wait Until Element Is Visible" for menu
    if grep -q "Wait Until Element Is Visible.*REGISTER_MENU\|Wait Until Element Is Visible.*HUMAN_RESOURCE_MENU" "$file"; then
        return 1  # Already fixed
    else
        return 0  # Needs fix
    fi
}

# Arrays of test files to fix
declare -a EMPLOYEE_TESTS=(
    "FinalistenTestCases/employee/open_employee_create.robot"
    "FinalistenTestCases/employee/open_employee_edit.robot" 
    "FinalistenTestCases/employee/open_employee_list.robot"
)

declare -a CUSTOMER_TESTS=(
    "FinalistenTestCases/customer/open_customer_create.robot"
    "FinalistenTestCases/customer/open_customer_edit.robot"
    "FinalistenTestCases/customer/open_customer_list.robot"
)

declare -a SUPPLIER_TESTS=(
    "FinalistenTestCases/supplier/open_supplier_create.robot"
    "FinalistenTestCases/supplier/open_supplier_edit.robot"
    "FinalistenTestCases/supplier/open_supplier_list.robot"
)

echo "Files identified for fixing:"
echo "Employee tests: ${#EMPLOYEE_TESTS[@]}"
echo "Customer tests: ${#CUSTOMER_TESTS[@]}"
echo "Supplier tests: ${#SUPPLIER_TESTS[@]}"
echo ""
echo "Total: $((${#EMPLOYEE_TESTS[@]} + ${#CUSTOMER_TESTS[@]} + ${#SUPPLIER_TESTS[@]})) tests"
echo ""
echo "Pattern to apply:"
echo "  - Wait for menu visibility (15s timeout)"
echo "  - Sleep 1s after wait"
echo "  - Sleep 2s after menu click"
echo ""
echo "This matches the successful pattern used in contact tests."
