#!/bin/bash
source venv/bin/activate
mkdir -p local_verification

tests=(
    "FinalistenTestCases/fieldreport/copy_fieldreport.robot:Test Copy Field Report Creates Duplicate"
    "FinalistenTestCases/fieldreport/earnings_calculation_fieldreport.robot:Test Earnings And Per Hour Display"
    "FinalistenTestCases/fieldreport/filter_combinations_fieldreport.robot:Test Customer And Project Filter Combined"
    "FinalistenTestCases/fieldreport/open_fieldreport_create.robot:Verify Field Report Create Page Opens Successfully"
    "FinalistenTestCases/fieldreport/open_fieldreport_edit.robot:Verify Field Report Edit Page Opens Successfully"
    "FinalistenTestCases/fieldreport/pagination_list_fieldreport.robot:Test Page Position Maintained After Detail View"
    "FinalistenTestCases/fieldreport/product_data_integrity_fieldreport.robot:Test Fields Copied From Sales Product To FR Product"
    "FinalistenTestCases/fieldreport/product_data_integrity_fieldreport.robot:Test Modify FR Product Sales Product Unchanged"
    "FinalistenTestCases/fieldreport/product_data_integrity_fieldreport.robot:Test Add Product With Zero Quantity"
    "FinalistenTestCases/fieldreport/product_edit_save_cancel_fieldreport.robot:Test Common Save Button Persists Changes"
    "FinalistenTestCases/fieldreport/search_filter_fieldreport.robot:Test With Attachment Filter - All Reports"
    "FinalistenTestCases/fieldreport/validation_required_fields_fieldreport.robot:Test Submit Without Installer Shows Error"
    "FinalistenTestCases/invoicing/open_invoice_edit.robot:Verify Invoice Edit View Opens Successfully"
    "FinalistenTestCases/purchaseproductregister/open_purchaseproductregister_edit.robot:Verify Purchase Product Register Edit Page Opens Successfully"
)

for test_info in "${tests[@]}"; do
    file="${test_info%%:*}"
    test_name="${test_info#*:}"
    echo "=========================================="
    echo "RUNNING: $test_name"
    echo "FILE: $file"
    robot --outputdir "local_verification/${test_name// /_}" --test "$test_name" "$file"
done
