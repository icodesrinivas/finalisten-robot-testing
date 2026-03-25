# Finalisten Robot Testing Project

## Project Overview
This project contains automated test cases for the **Finalisten ERP System** using **Robot Framework** with **SeleniumLibrary**. The tests are designed to verify various functionalities of the Finalisten ERP web application.

## Technology Stack
- **Test Framework**: Robot Framework 7.2.2
- **Browser Automation**: SeleniumLibrary 6.7.1
- **WebDriver**: Selenium 4.24.0
- **Browser**: Chrome (requires matching ChromeDriver version)
- **Language**: Python 3.10+
- **ChromeDriver**: v145.0.7632.162 (Must match Chrome version)

## Project Structure
```
finalisten-robot-testing/
├── .github/workflows/             # GitHub Actions workflows
│   ├── test-fieldreport-app.yml   # Separate job for Field Report app tests
│   └── ... (other workflows)
├── FinalistenTestCases/           # Main test cases directory
│   ├── __init__.robot             # Suite initialization
│   ├── keywords/                  # Shared keywords
│   │   └── LoginKeyword.robot     # Login functionality and common keywords
│   ├── common/                    # Common test utilities
│   │   └── login/                 # Login-specific tests
│   ├── contact/                   # Contact module tests
│   ├── customer/                  # Customer module tests
│   ├── employee/                  # Employee module tests
│   ├── fieldreport/               # Field Report module tests
│   ├── fieldreportapproval/       # Field Report Approval tests
│   ├── project/                   # Project module tests
│   ├── quotation/                 # Quotation module tests
│   ├── invoicing/                 # Invoicing module tests
│   ├── supplier/                  # Supplier module tests
│   ├── subcontractor/             # Subcontractor module tests
│   ├── productregister/           # Product Register tests
│   ├── purchaseproductregister/   # Purchase Product Register tests
│   ├── doorplanning/              # Door Planning tests
│   ├── resourceplanning/          # Resource Planning tests
│   ├── dailyplanner/              # Daily Planner tests
│   ├── guestuser/                 # Guest User tests
│   ├── myproduction/              # My Production tests
│   ├── setting/                   # Settings tests
│   ├── invoicereport/             # Invoice Report tests
│   ├── projectreport/             # Project Report tests
│   └── performancereport/         # Performance Report tests
├── chromedriver-mac-x64/          # ChromeDriver for macOS
├── robot-results/                 # Test execution output
├── fintest/                       # Python virtual environment
├── requirements.txt               # Python dependencies
├── Jenkinsfile                    # CI/CD configuration
└── GEMINI.md                      # This documentation file
```

## Application Under Test: Finalisten ERP

### Access Details
- **URL**: https://erp.finalisten.se/
- **Login URL**: https://erp.finalisten.se/login/
- **Homepage URL**: https://erp.finalisten.se/homepage/

### Test Credentials
- **Username**: erpadmin@finalisten.se
- **Password**: Djangocrm123

### Main Navigation Menus
1. **Register** (id="register")
   - Contacts (id="contacts_app_menu")
   - Customers
   - Employees
   - Suppliers
   - Subcontractors

2. **Production** (id="production")
   - Field Reports (id="field_reports_app_menu")
   - Door Planning
   - Resource Planning
   - My Production

3. **Projects**
   - Project List
   - Quotations

4. **Finance**
   - Invoicing
   - Invoice Reports

## Pre-Production Environment

### Access Details
- **URL**: https://preproderp.finalisten.se/
- **Login URL**: https://preproderp.finalisten.se/login/
- **Homepage URL**: https://preproderp.finalisten.se/homepage/

### When to Use Pre-Production
- **Create/Update/Delete tests** should run on PRE-PRODUCTION to avoid polluting production data
- **Read-only tests** (search, filter, view) can run on production

### Important: Reporting Periods
- Pre-production may have **closed reporting periods** for recent months
- As of December 2025, **October 2025 is the last open period** (use date: `2025-10-31`)
- If you get error "The period you are trying to report to is closed for reporting", use a valid open period date

## Field Report Create Form Details

### Create Page URL (Pre-Prod)
https://preproderp.finalisten.se/fieldreport/create/

### Form Fields and Selectors
| Field | Type | Selector | Required |
|-------|------|----------|----------|
| Customer | Dropdown | `id=id_related_customer` | Yes |
| Project | Dropdown | `id=id_related_project` | Yes (loads after customer) |
| Sub Project | Dropdown | `id=id_related_subproject` | Yes (loads after project) |
| Work Date | Date Input | `id=id_work_date` | Yes (YYYY-MM-DD) |
| Total Hours | Number Input | `id=id_total_work_hours` | No |
| Message To Approver | Textarea | `id=id_message_to_approver` | No |
| Security Control OK | Checkbox | `id=id_security_control` | No |
| Installer Name | Dropdown | `id=id_installer_name` | No |

### Buttons
- **Save**: `css=button.save`
- **Cancel**: Link to `/fieldreport/list/`
- **Delete** (Edit Page): `id=remove_fieldreport`

### Dynamic Field Behavior
1. Selecting a **Customer** triggers AJAX to load related **Projects**
2. Selecting a **Project** triggers AJAX to load related **Sub Projects**
3. Wait 2 seconds after each selection before interacting with the next field

### Total Hours Format
- Swedish locale formats numbers like "8" as "8,00"
- When validating, convert commas to dots for numeric comparison

### Cleanup in Teardown
Always delete created fieldreports in teardown:
```robot
[Teardown]    Cleanup Created Fieldreport
```
This ensures database cleanliness whether tests pass or fail.

### Edit Page - IMPORTANT
**Form fields are READ-ONLY by default on the edit page!**

To modify fields on the edit page:
1. Click the **Edit** button (`id="EditGeneralDataButton"`) first
2. Fields become editable
3. Make your modifications
4. Click **Save** button (`id="fieldreport_general_data_save"`)

```robot
# Enable edit mode
Wait Until Element Is Visible    id=EditGeneralDataButton    timeout=10s
Click Element    id=EditGeneralDataButton
Sleep    1s    # Wait for fields to become editable

# Now you can modify fields...
Clear Element Text    id=id_work_date
Input Text    id=id_work_date    2025-10-15

# Save changes
Click Element    id=fieldreport_general_data_save
```

## Environment Setup

### Virtual Environment
```bash
# Create virtual environment
python3 -m venv fintest

# Activate virtual environment
source fintest/bin/activate

# Install dependencies
pip install -r requirements.txt
```

### Database Connection
Direct database connections are used for dynamic test data fetching and environment setup.
- **Environment Variable**: `DATABASE_URL`
- **Key Tables**:
  - Customers: `account_customer`
  - Projects: `projects_project`
  - Employees/Installers: `employee_employment` (name column is often `display_name`)
- **How to fetch**: `export DATABASE_URL=$(heroku config:get DATABASE_URL --app finalistenerppreprod-eu)`

### ChromeDriver
- The project includes ChromeDriver for Mac in `chromedriver-mac-x64/` directory.
- **Dynamic Detection**: `LoginKeyword.robot` now automatically detects the environment:
  - **Local Mac**: Uses the bundled driver in `chromedriver-mac-x64/`.
  - **GitHub Actions (CI)**: Bypasses the bundled driver and relies on the system-installed ChromeDriver (configured in `verify-fixes.yml`).
- **IMPORTANT**: Local ChromeDriver version must match your Chrome browser version.
- To update ChromeDriver, download from: https://googlechromelabs.github.io/chrome-for-testing/

## Running Tests

### Basic Test Execution
```bash
# Activate virtual environment
source fintest/bin/activate

# Add ChromeDriver to PATH (Optional, handled automatically by LoginKeyword.robot)
export PATH="${PWD}/chromedriver-mac-x64:$PATH"

# Run all tests in a directory
robot --outputdir robot-results FinalistenTestCases/fieldreport/

# Run specific test file
robot --outputdir robot-results FinalistenTestCases/fieldreport/search_filter_fieldreport.robot

# Run specific test case
robot --outputdir robot-results --test "Test Related Customer Filter" FinalistenTestCases/fieldreport/search_filter_fieldreport.robot

# Run tests by tag
robot --outputdir robot-results --include filter FinalistenTestCases/

# Run multiple specific tests
robot --outputdir robot-results --test "Test A*" --test "Test B*" FinalistenTestCases/
```

### Test Results
- Output files are saved to `robot-results/` directory
- `output.xml` - Machine-readable results
- `log.html` - Detailed test execution log
- `report.html` - Summary report

## Test Case Patterns

### Standard Test Structure
```robot
*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${MENU_SELECTOR}    xpath=//*[@id="menu_id"]

*** Test Cases ***
Test Case Name
    [Documentation]    Description of what this test verifies
    [Tags]    tag1    tag2
    Navigate To Module List
    Perform Test Actions
    Verify Expected Results
    [Teardown]    Close Browser

*** Keywords ***
Custom Keyword Name
    [Documentation]    What this keyword does
    [Arguments]    ${arg1}    ${arg2}
    # Implementation
```

### Common Keywords (LoginKeyword.robot)
- `Open And Login` - Opens browser, navigates to login page, and logs in
- `Handle SSL Warning` - Handles SSL certificate warnings if present
- `Close Browser` - Safely closes all browser windows

### Chrome Options
The `${CHROME_OPTIONS}` variable in LoginKeyword.robot contains:
```
add_argument("--ignore-certificate-errors");add_argument("--disable-web-security");add_argument("--allow-running-insecure-content")
```

### Failed Test Tracking
Detailed failures for the fieldreport module are tracked in [fieldreport_failures.md](./fieldreport_failures.md).

## Field Report Module Details

### List View URL
https://erp.finalisten.se/fieldreport/list/

### Filter Section
- **Toggle ID**: `fieldreport_list_filter`
- **Search Button ID**: `fieldreport_list_search`

### Available Filters
| Filter | Type | Selector |
|--------|------|----------|
| Related Customer | Dropdown | `id=id_related_customer` |
| Related Project | Text Input | `id=related_project` |
| Start Work Date | Date Picker | `id=start_work_date` |
| End Work Date | Date Picker | `id=end_work_date` |
| Installer Names | Searchable Checkbox | `id=searchColumn` (search), `id=installer_name_input` (checkboxes) |
| Approval Status | Dropdown | `id=id_approved` |
| Product Description | Text Input | `id=product_description` |
| With Attachment | Dropdown | `id=id_with_attachment` |

### Approval Status Options
- Index 0: "All" (value: "")
- Index 1: "Approve" (value: "Approve")
- Index 2: "Unapprove" (value: "Unapprove")

### With Attachment Options
- Index 0: "All Reports" (value: "all_reports")
- Index 1: "With Attachment" (value: "with_attachment")
- **Note**: There is NO "Without Attachment" option

### Results Table
- **Table ID**: `DataTables_Table_0`
- **Row Class**: `fieldreport_rows`
- **Row ID Pattern**: `fieldreport_details[ID]` (e.g., `fieldreport_details27240`)
- **Columns**: ID, Installer Name, Project, Sub Project, Customer, Week, Work Date, Total Hours

### Opening Field Report Details
- **Method**: Double-click on a row to open the edit page in a new tab
- **Edit Page URL Pattern**: `/fieldreport/list/[ID]/edit/`

### Important Behaviors
1. **Default Date Filter**: The list view has a default start date filter that may limit results. Always set a wide date range (e.g., 3 months back) when testing other filters.

2. **Product Description**: This field is NOT visible in the list view. It exists in the "PRODUCTS" table within each field report's edit page. To validate this filter, you must open a field report and check the Products table.

3. New Tab Handling: Double-clicking a row opens the edit page in a new tab. Use `Switch Window    NEW` to switch to it.

## Test Stability Guidelines

To ensure reliable test execution across environments:

1. **Forced English Environment**: All tests must use the shared `Open And Login` keyword. This keyword triggers a direct database update (via `DatabaseKeywords.py`) to set the user's language to English before login. This ensures assertions for English strings (like "CUSTOMER DATA") always pass.
2. **Robust Dropdown Selection**: When selecting records from dropdowns (Customer, Project), use a fallback pattern. Attempt to select by label (e.g., "Arcona Aktiebolag") and, if it fails, fallback to selecting by index 1.
3. **Wait Until Element Is Visible**: Use a 60-second timeout for critical UI elements (e.g., "CUSTOMER DATA") to handle slow page loads in pre-production.
4. **Shared Login**: Consolidate all login logic into `LoginKeyword.robot`. Avoid using local `Login To Application` keywords that might bypass the language reset.
5. **Dynamic Data Selection**: To avoid `NoSuchElementException` when hardcoded labels (like "Arcona Aktiebolag") are missing, always use `Setup Dynamic Test Data` at the start of tests. This fetches valid customer, project, and installer names directly from the database and stores them in `${DB_CUSTOMER}`, `${DB_PROJECT}`, and `${DB_INSTALLER}`.
6. **Robust ID Extraction**: Use `Extract And Verify Fieldreport ID` after saving a new record. This ensures the record was successfully created and the ID is available for downstream steps or cleanup.

## Effort Summary Format

When completing tasks, provide an effort summary in this format:
```
1. [Category]: [Description of work done]. — COMPLETED — [DDMMYYYY]
```

**IMPORTANT**: Always use TODAY'S date in DDMMYYYY format. Get the current date from the system-provided timestamp in the conversation.

Example:
```
1. Test Stabilization: Implemented dynamic database fetching for customers, projects, and installers to replace fragile hardcoded labels. — COMPLETED — 14032026
2. Test Stabilization: Enhanced ID extraction logic with robust URL verification and centralized error handling. — COMPLETED — 14032026
3. Localization: Standardized all test assertions and environment settings to English for consistent execution. — COMPLETED — 14032026
2. Bug Fix: Fixed ChromeDriver version mismatch issue. — COMPLETED — 31122025
```

## Known Issues and Solutions

### ChromeDriver Version Mismatch
**Error**: `SessionNotCreatedException: This version of ChromeDriver only supports Chrome version X`
**Solution**: Download matching ChromeDriver from Chrome for Testing website and update the `chromedriver-mac-x64/` directory. Ensure `executable_path` is explicitly set in `LoginKeyword.robot` to point to the local version.

### Missing CHROME_OPTIONS Variable
**Error**: `Variable '${CHROME_OPTIONS}' not found`
**Solution**: Ensure `${CHROME_OPTIONS}` is defined in `LoginKeyword.robot`.

### No Results in Filter Tests
**Cause**: Default date filter restricts results
**Solution**: Use `Set Wide Date Range For Testing` keyword before applying other filters.

### Element Not Found After Search

### Filter Section Collapses After Search in Headless Chrome
**Issue**: `ElementNotInteractableException` when interacting with filter dropdowns after search
**Cause**: In headless Chrome, the filter section collapses after `Click Search` and dropdown elements become not visible/interactable.
**Solution**: Always call `Expand Filter Section` or `Expand Filters` after each search operation. Added `Ensure Filter Inputs Visible` keyword to verify filter visibility before interaction.

### User Credentials for Different Roles
**Issue**: Tests requiring "Regular User" or "Guest User" skip.
**Solution**: Configure credentials for ``/`` and ``/`` in `LoginKeyword.robot`. Currently, only `` (erpadmin) is set.

**Cause**: Page content loads asynchronously
**Solution**: Add appropriate `Sleep` or `Wait Until` keywords after clicking search.

### GitHub Actions Workflows
- **Field Report App Testing** (`test-fieldreport-app.yml`): Specifically runs all test cases in the `fieldreport/` and `fieldreportapproval/` directories. This can be manually triggered via the GitHub Actions tab.
- **Daily Robot Framework Tests** (`daily-tests.yml`): Runs the full test suite daily.
- **Verify Robot Test Fixes** (`verify-fixes.yml`): Runs a targeted set of tests to verify recent fixes.

### GitHub Actions / CI Timeout Standards
Tests run slower in headless GitHub Actions runners than locally. Use these standard timeouts:

| Action Type | Recommended Timeout |
|-------------|---------------------|
| Page load / Location change | **45s** |
| Element visibility (menus, forms) | **30s** |
| Modal / AJAX content | **15-30s** |
| Quick UI feedback | **10s** |

**Key learnings (Jan 2026):**
- Door Planning board takes 30s+ to show "Sales Week" text in CI
- Login redirect can take 45s in headless Chrome
- Always use the shared `LoginKeyword.robot` which has proper CI-tested timeouts

## Contact Module Details

### List View URL
https://erp.finalisten.se/contacts/list/

### Navigation
- Hover over "Register" menu (id="register")
- Click "Contacts" (id="contacts_app_menu")

### Add Contact
- Button selector: `xpath=//a[@href="/fieldreport/create/" and @title="Add New Fieldreport"]`

## Fieldreport Approval Module Details

### Access URL
https://preproderp.finalisten.se/fieldreport/fieldreport_approval/

### Navigation
- Hover over "Production" menu (id="production")
- Click "Field Report Approval" (id="field_report_approval_app_menu")

### Tree Structure
The approval page displays a hierarchical tree:
1. **List Of Installers** - Root level, shows all installers
2. **Projects** - Appear when an installer is clicked/expanded
3. **Fieldreports** - Appear when a project is clicked/expanded

### Key Selectors
| Element | Selector |
|---------|----------|
| Installer Links | `css=a.fieldreport-approval-installer-name` |
| Fieldreport Links | `css=a.fieldreport_record_details` |
| Tree Container | `css=div.tree_container` |

### Date Range Filter
- Located at top right (shows date range like "2026-01-19 to 2026-01-25")
- Click to open daterangepicker with options: "This Week", "Last Week", "This Month", "Last Month", "Custom"

### Fieldreport Link Behavior
- Fieldreport links have `target="_blank"` and open in new tab
- URL pattern: `/fieldreport/list/{ID}/edit/`

## Settings Module Details

### Tree View Navigation
- **App Menu ID**: `settings_app_menu`
- **Tree Container**: `css=div.tree_container`
- **Pencil Icons**: `css=i.global-setting-pencil`

### Form Loading Behavior (AJAX)
The settings forms load on the right side of the screen using AJAX. A robust verification strategy is required to ensure the form is fully loaded before interacting:
1. **Loading Buffer**: An overlay with `id="loading_buffer"` becomes visible (opacity: 1) during AJAX loads.
2. **Content Refresh**: Wait for the right-side form container (`id=id_global_setting_data`) to refresh its content and for the `loading_buffer` opacity to return to 0.

### Verification Strategy
Use a combination of `loading_buffer` check and `Wait Until Keyword Succeeds` to detect content changes:
```robot
# Capture current content
${old_content}=    Get Text    id=id_global_setting_data

# Click the pencil
Execute Javascript    document.getElementById('setting_id').click();

# Wait for refresh
Wait Until Keyword Succeeds    15x    1s    Verify Form Content Refresh    ${old_content}
```

## Contributing New Tests

1. Follow the existing file naming convention: `open_[module]_[action].robot` or `[feature]_[module].robot`
2. Always use the shared `LoginKeyword.robot` resource
3. Add appropriate tags for filtering (e.g., `filter`, `dropdown`, `text`, `validation`)
4. Include proper documentation for test cases
5. Use descriptive variable names
6. Add teardown to close browser

## Version History

- **2026-03-18**: Enhanced `verify_add_supplier_to_product.robot` with a more robust waiting strategy (Presence -> Scroll -> Visibility Poll -> JS Click) and increased timeouts to 60s to resolve intermittent CI failures in GitHub Actions.
- **2026-03-18**: Created `verify_fixed_agreement_delete.robot` to validate Fixed Agreement deletion. Implemented `create_fixed_agreement` DB helper in `DatabaseKeywords.py` with boolean status handling. 
- **2026-03-11**: Created `verify_add_supplier_to_product.robot` to validate the 'ADD' button functionality in Purchase Product Register. Identified `#supplier_add_button` and corrected row selector to `tr.purchase_product_rows`.
- **2026-03-11**: Created `verify_all_settings_forms.robot` in `FinalistenTestCases/settings/` to validate all 23 settings options in a single pass. Implemented advanced AJAX detection logic using DOM opacity and content-refresh polling. Updated ChromeDriver to version 145.
- **2026-03-04**: Updated customer list locators from "Filters" text to "Advanced search" element (`id_advanced_search_toggle`) due to UI changes.
- **2026-03-04**: Identified 500 Internal Server error in Settings -> Fieldreport -> Reporting Date Range edit view on Pre-Production environment, which causes `update_fieldreport_date_range.robot` failure.
- **2026-01-08**: Executed 91 test cases across 28 files for Field Report module. 75 Passed, 14 Failed, 2 Skipped.
- **2026-01-08**: Confirmed `fintest` as the virtual environment and identified `headlesschrome` as the stable browser mode.
- **2026-01-08**: Identified that Regular and Guest user tests skip due to missing credentials in `LoginKeyword.robot'.
- **2025-12-31**: Created field report edit test with all field modifications and validation (preprod)
- **2025-12-31**: Created field report creation test with validation and cleanup (preprod)
- **2025-12-31**: Created comprehensive search filter test suite for Field Report module
- **2025-12-31**: Fixed ChromeDriver compatibility issues
- **2025-12-31**: Added CHROME_OPTIONS variable to LoginKeyword.robot

## Purchase Product Register Module Details

### List View
- **Row Selector**: `css=tr.purchase_product_rows`
- **Row ID Pattern**: `purchase_product_details[ID]`

### Edit Page
- **ADD Button (Suppliers)**: `id=supplier_add_button`
- **Button Visibility**: Requires a robust sequence for CI stability: Wait for `#loading_buffer` (opacity 0) -> Wait for Presence -> Scroll (approx Y=990px) -> Wait for Visibility Polling (60s) -> JS Click.
- **Loading Behavior**: Uses `id="loading_buffer"` during AJAX loads. Always wait for this buffer to have opacity 0 before interacting with the button.
- **ADD SUPPLIER Modal**: `id=myModal3`
- **Supplier Checkboxes**: `css=input.supplier_in_product_checkbox`
- **Save Button (Modal)**: `id=supplier_in_product_save_button`

- **Delete Fixed Agreement Button**: `button[contains(@id, 'fixed_agreement_remove')]` or `title="Delete Fixed Agreement"`
- **Fixed Agreement Row Locator**: `tr[td[contains(., 'Name')]]`

## Project Module Details

### Edit Page - Fixed Agreements
- **Tab Header ID**: `id_fixed_agreement_frame_header`
- **Table Container ID**: `fixed_agreement_table_div`
- **Table ID**: `fixed_agreement_table`
- **Database Table**: `project_fixedagreement`
- **Key Columns**:
  - `agreement_name`: character varying (NO)
  - `agreement_amount`: character varying (YES)
  - `related_project_id`: integer (YES)
  - `agreement_status`: boolean (NO) - `true` is Active
  - `agreement_is_retainage`: boolean (NO)
  - `agreement_total_cost`: character varying (YES)

## Project Rules

- **Strict Non-Attribution**: NEVER mention AI usage, Claude, or Gemini in any git commit messages or task summaries. All work must be attributed to a human developer.
- Always use the `fintest` virtual environment for executing tests locally in this project (`source fintest/bin/activate`).
