#!/bin/bash
# Script to run the 14 failing tests identified on 2026-01-08

# Activate virtual environment
source fintest/bin/activate

# Add ChromeDriver to PATH
export PATH="${PWD}/chromedriver-mac-x64:$PATH"

# Create results directory
mkdir -p baseline_results

# List of failing tests (File:TestName)
tests=(
    "FinalistenTestCases/fieldreport/debug_earnings.robot:Debug Field Report Creation And Products"
    "FinalistenTestCases/fieldreport/earnings_calculation_fieldreport.robot:Test Earnings And Per Hour Display"
    "FinalistenTestCases/fieldreport/open_fieldreport_edit.robot:Verify Field Report Edit Page Opens Successfully"
    "FinalistenTestCases/fieldreport/pagination_list_fieldreport.robot:Test Page Position Maintained After Detail View"
    "FinalistenTestCases/fieldreport/product_data_integrity_fieldreport.robot:Test Fields Copied From Sales Product To FR Product"
    "FinalistenTestCases/fieldreport/product_data_integrity_fieldreport.robot:Test Modify FR Product Sales Product Unchanged"
    "FinalistenTestCases/fieldreport/product_data_integrity_fieldreport.robot:Test Add Same Product Twice Duplicate Handling"
    "FinalistenTestCases/fieldreport/product_data_integrity_fieldreport.robot:Test Add Product With Zero Quantity"
    "FinalistenTestCases/fieldreport/product_data_integrity_fieldreport.robot:Test Delete Product From Field Report"
    "FinalistenTestCases/fieldreport/product_delete_attachment_fieldreport.robot:Test Upload Attachment To Product"
    "FinalistenTestCases/fieldreport/product_delete_attachment_fieldreport.robot:Test Delete Attachment From Product"
    "FinalistenTestCases/fieldreport/product_edit_save_cancel_fieldreport.robot:Test Common Save Button Persists Changes"
    "FinalistenTestCases/fieldreport/search_filter_fieldreport.robot:Test With Attachment Filter - All Reports"
    "FinalistenTestCases/fieldreport/work_date_validation_fieldreport.robot:Test Reject Field Report With Future Date"
)

for test_info in "${tests[@]}"; do
    file="${test_info%%:*}"
    test_name="${test_info#*:}"
    echo "=========================================="
    echo "RUNNING: $test_name"
    echo "FILE: $file"
    # Create a safe directory name for results
    dir_name=$(echo "$test_name" | sed 's/ /_/g' | tr -dc '[:alnum:]_')
    robot --outputdir "baseline_results/$dir_name" --test "$test_name" "$file"
done
