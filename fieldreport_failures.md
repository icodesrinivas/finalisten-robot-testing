# Field Report Module - Failed Test Cases (2026-01-08)

This file lists the test cases that failed during the execution of the `fieldreport` test suite. These failures need to be investigated and fixed sequentially.

## Summary
- **Suite**: FinalistenTestCases/fieldreport
- **Total Tests**: 91
- **Passed**: 75
- **Failed**: 14
- **Skipped**: 2

---

## Failure Details

| # | Test Case Name | Suite / File | Primary Error Message |
| :--- | :--- | :--- | :--- |
| 1 | **Debug Field Report Creation And Products** | debug_earnings.robot | Element with locator 'css=#prodInProjTable tbody tr:first-child .selected-checkbox' not found. |
| 2 | **Test Earnings And Per Hour Display** | earnings_calculation_fieldreport.robot | Should display 'Earnings': '' does not contain 'Earnings' |
| 3 | **Verify Field Report Edit Page Opens Successfully** | open_fieldreport_edit.robot | Text 'FIELD REPORT' did not appear in 10 seconds. |
| 4 | **Test Page Position Maintained After Detail View** | pagination_list_fieldreport.robot | ElementClickInterceptedException: navbar overlapping the project link. |
| 5 | **Test Fields Copied From Sales Product To FR Product** | product_data_integrity_fieldreport.robot | Element with locator 'css=#prodInProjTable tbody tr:first-child' not found. |
| 6 | **Test Modify FR Product Sales Product Unchanged** | product_data_integrity_fieldreport.robot | Setup failed: Could not prepare test data. |
| 7 | **Test Add Same Product Twice Duplicate Handling** | product_data_integrity_fieldreport.robot | Setup failed. |
| 8 | **Test Add Product With Zero Quantity** | product_data_integrity_fieldreport.robot | Setup failed. |
| 9 | **Test Delete Product From Field Report** | product_data_integrity_fieldreport.robot | Setup failed. |
| 10 | **Test Upload Attachment To Product** | product_delete_attachment_fieldreport.robot | Setup failed. |
| 11 | **Test Delete Attachment From Product** | product_delete_attachment_fieldreport.robot | Setup failed. |
| 12 | **Test Common Save Button Persists Changes** | product_edit_save_cancel_fieldreport.robot | Element with locator 'css=#prodInFieldReportTable tbody tr:first-child' not found. |
| 13 | **Test With Attachment Filter - All Reports** | search_filter_fieldreport.robot | Element with locator 'id=fieldreport_list_filter' not found. |
| 14 | **Test Reject Field Report With Future Date** | work_date_validation_fieldreport.robot | StaleElementReferenceException: Page refreshed during validation. |

---

## Investigation Notes
- **Chromedriver**: Used local version at `./chromedriver-mac-x64/` to match Chrome.
- **Environment**: Executed in `headlesschrome` mode via `fintest` virtual environment.
- **Skipped Tests**: `Test Regular User View Own Field Reports` and `Test Guest User Read Only Access` skipped due to missing credentials in `LoginKeyword.robot`.
