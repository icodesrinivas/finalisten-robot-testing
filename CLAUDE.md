# Project Rules

- **Strict Non-Attribution**: NEVER mention AI usage, Claude, or Gemini in any git commit messages or task summaries. All work must be attributed to a human developer.

- **Virtual Environment**: Always use the `fintest` virtual environment for executing tests locally in this project.
    - Command: `source fintest/bin/activate`
- **Testing**:
    - Use Robot Framework for automated testing.
    - For this project, local test executions must be performed within the `fintest` venv.
    - **GitHub Actions**: 
        - `Field Report App Testing` (`test-fieldreport-app.yml`): Runs all tests for the field report and field report approval modules. Manual trigger.
        - `Daily Robot Framework Tests` (`daily-tests.yml`): Runs all tests daily.
        - `Verify Robot Test Fixes` (`verify-fixes.yml`): Runs a subset of tests to verify specific fixes.
- **Diagnostics**:
    - When tests fail in CI, check the `results/` artifact for screenshots.
- **Design**:
    - Maintain a premium design aesthetic for all UI components.
- **Reporting**:
    - After task completion, provide effort summary in the standard format.

- **Environment Secrets**:
    - Some tests (e.g., Inactive Installer regression) require a `DATABASE_URL` environment variable to query the database.
    - Fetch via: `heroku config:get DATABASE_URL --app finalistenerppreprod-eu`
    - In CI (GitHub/Jenkins), this must be configured as a secret.

- **UI Changes (March 2026)**:
    - The "Filters" text on the Customers list has been replaced by an "Advanced search" toggle with ID `id_advanced_search_toggle`. Use this for list page load validation `Wait Until Page Contains Element`.
- **Known Bugs (March 2026)**:
    - The "Reporting Date Range" edit view in Settings currently throws a 500 error in pre-production, preventing the test `update_fieldreport_date_range.robot` from passing.
- **Settings Form Loading**: Always wait for AJAX content refresh when clicking settings pencils. Use the helper keyword `Verify Form Content Refresh` which checks `loading_buffer` opacity and container content changes.
- **ChromeDriver**: WebDriver path is managed automatically. Locally on Mac, it uses the bundled driver in `chromedriver-mac-x64/`. In GitHub Actions, it relies on the system PATH.
- **Purchase Product Register**:
    - Row selector: `css=tr.purchase_product_rows`.
    - ADD button ID: `id=supplier_add_button`.
    - **Note**: The ADD button requires a robust sequence for CI stability: Wait for `#loading_buffer` (opacity 0) -> Wait for Presence -> Scroll (approx Y=990px) -> Wait for Visibility Polling (60s) -> JS Click.
    - Modal ID: `myModal3`.
- **Test Stability Guidelines**:
    - **Forced English Environment**: All tests MUST use the shared `Open And Login` keyword from `LoginKeyword.robot`. This keyword automatically forces the user's language to English via a direct database update (`DatabaseKeywords.py`), ensuring consistent assertions for strings like "CUSTOMER DATA".
    - **Robust Data Selection**: When selecting records from dropdowns (e.g., Customer, Project), always implement a fallback strategy: try selecting by label (e.g., "Arcona Aktiebolag") and fallback to `Select From List By Index | ... | 1` if the specific label is not found.
    - **Wait Times**: Use a default 60-second timeout for critical page elements like "CUSTOMER DATA" to accommodate slow pre-production loads.
    - **Database Connectivity**: Ensure `DATABASE_URL` is set to allow the `Open And Login` keyword to update user settings.
    - **Dynamic Data Selection**: To avoid `NoSuchElementException` when hardcoded labels (like "Arcona Aktiebolag") are missing, always use `Setup Dynamic Test Data` at the start of tests. This fetches valid customer, project, and installer names directly from the database and stores them in `${DB_CUSTOMER}`, `${DB_PROJECT}`, and `${DB_INSTALLER}`.
    - **Robust ID Extraction**: Use `Extract And Verify Fieldreport ID` after saving a new record. This ensures the record was successfully created and the ID is available for downstream steps or cleanup.
- **Standardized Cleanup**: Always use `[Teardown] Cleanup Created Fieldreport` (or custom multi-ID cleanup if multiple are created). This keyword now automatically handles unapproval before deletion to ensure resources are always removed, even in failure scenarios.
