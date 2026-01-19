# Implementation Plan - Fix 14 Failed Field Report Test Cases

The goal is to investigate, diagnose, and fix the 14 failing test cases identified in `fieldreport_failures.md` for the Field Report module.

## 1. Preparation and Baseline Execution
- [ ] Create a dedicated execution script `run_failing_tests.sh` to run the 14 failing tests specifically.
- [ ] Execute the script using the `fintest` virtual environment.
- [ ] Collect results in a `baseline_results` directory.

## 2. Diagnostics and Categorization
- Analyze each failure from the baseline run:
  - **Case 1 & 12**: `prodInProjTable` / `prodInFieldReportTable` locator issues.
  - **Case 2**: Earnings calculation display issue.
  - **Case 3**: 'FIELD REPORT' text timeout in `open_fieldreport_edit.robot`.
  - **Case 4**: Navbar overlapping project link in `pagination_list_fieldreport.robot`.
  - **Case 5-9**: Data integrity tests with setup failures or missing elements.
  - **Case 10-11**: Attachment tests with setup failures.
  - **Case 13**: `fieldreport_list_filter` not found.
  - **Case 14**: `StaleElementReferenceException` in work date validation.

## 3. Implementation of Fixes
### Category A: Locators and Wait Times
- [ ] Update locators if the UI has changed.
- [ ] Add `Wait Until Element Is Visible` or `Wait Until Page Contains` where app is slow.
- [ ] Adjust `Sleep` durations if necessary (using sparingly).

### Category B: Interaction Fixes
- [ ] For overlapping elements (Case 4), use `Scroll Element Into View` or JavaScript clicks.
- [ ] For stale elements (Case 14), implement retry logic or wait for page stability.

### Category C: Setup and Data Fixes
- [ ] Investigate `Setup failed` for product and attachment tests. Ensure test data (Customer/Project) exists and is correctly selected.
- [ ] Fix AJAX loading waits between Customer -> Project -> Subproject selection.

## 4. Final Verification
- [ ] Run all 14 tests again to ensure 100% pass rate.
- [ ] Update `fieldreport_failures.md` with the new status.
- [ ] Update `GEMINI.md` with any new findings.

## 5. Reporting
- [ ] Summarize the effort for the user.
