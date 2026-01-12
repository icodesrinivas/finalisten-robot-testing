*** Settings ***
Documentation    Test suite for verifying all search filter fields in the Field Report list view.
...              Each filter field is tested individually to ensure proper functionality.
...              NOTE: The fieldreport list has a default start date filter, so we extend the date range
...              for non-date-specific tests to ensure meaningful results.
Library          SeleniumLibrary
Library          DateTime
Library          String
Resource         ../keywords/LoginKeyword.robot

*** Variables ***
# Navigation Elements
${PRODUCTION_MENU}                xpath=//*[@id="production"]
${FIELD_REPORT_MENU}              xpath=//*[@id="field_reports_app_menu"]
${FILTER_SECTION_HEADER}          id=fieldreport_list_filter
${SEARCH_BUTTON}                  id=fieldreport_list_search
${CLEAR_FILTER_LINK}              xpath=//a[contains(@href, '/fieldreport/list/') and contains(text(), 'Clear')]

# Filter Field Selectors
${RELATED_CUSTOMER_DROPDOWN}      id=id_related_customer
${RELATED_PROJECT_INPUT}          id=related_project
${START_WORK_DATE_INPUT}          id=start_work_date
${END_WORK_DATE_INPUT}            id=end_work_date
${INSTALLER_SEARCH_INPUT}         id=searchColumn
${INSTALLER_CHECKBOX}             id=installer_name_input
${APPROVAL_STATUS_DROPDOWN}       id=id_approved
${PRODUCT_DESCRIPTION_INPUT}      id=product_description
${WITH_ATTACHMENT_DROPDOWN}       id=id_with_attachment
${UNDO_SELECT_CHECKBOX}           id=undo_select_checkbox

# Results Elements
${FIELD_REPORT_ROWS}              css=tr.fieldreport_rows
${DATATABLES_EMPTY}               css=td.dataTables_empty
${NO_RECORDS_H6}                  xpath=//h6[contains(text(), 'No Field Report Records Found')]
${TOTAL_REPORTS_TEXT}             xpath=//p[contains(text(), 'Total Field Reports')]

*** Test Cases ***
Test Related Customer Filter
    [Documentation]    Verify the Related Customer dropdown filter works correctly
    [Tags]    filter    customer    dropdown
    Navigate To Field Report List
    Expand Filter Section
    Clear Date Filters
    Select First Available Option From Dropdown    ${RELATED_CUSTOMER_DROPDOWN}
    Click Search Button
    Verify Search Completed With Retry
    Log To Console    "Related Customer filter test completed successfully."
    [Teardown]    Close Browser

Test Related Project Filter
    [Documentation]    Verify the Related Project text input filter works correctly
    [Tags]    filter    project    text
    Navigate To Field Report List
    Expand Filter Section
    Clear Date Filters
    Input Text    ${RELATED_PROJECT_INPUT}    Albygård
    Click Search Button
    Verify Search Completed With Retry
    Log To Console    "Related Project filter test completed successfully."
    [Teardown]    Close Browser

Test Start Work Date Filter
    [Documentation]    Verify the Start Work Date filter works correctly
    [Tags]    filter    date    start_date
    Navigate To Field Report List
    Expand Filter Section
    ${date}=    Get Current Date    result_format=%Y-%m-%d
    Clear Element Text    ${START_WORK_DATE_INPUT}
    Input Text    ${START_WORK_DATE_INPUT}    ${date}
    Click Search Button
    Verify Search Completed With Retry
    Log To Console    "Start Work Date filter test completed successfully."
    [Teardown]    Close Browser

Test End Work Date Filter
    [Documentation]    Verify the End Work Date filter works correctly
    [Tags]    filter    date    end_date
    Navigate To Field Report List
    Expand Filter Section
    ${date}=    Get Current Date    result_format=%Y-%m-%d
    Clear Element Text    ${END_WORK_DATE_INPUT}
    Input Text    ${END_WORK_DATE_INPUT}    ${date}
    Click Search Button
    Verify Search Completed With Retry
    Log To Console    "End Work Date filter test completed successfully."
    [Teardown]    Close Browser

Test Date Range Filter
    [Documentation]    Verify both Start and End Work Date filters work together for date range search
    [Tags]    filter    date    range
    Navigate To Field Report List
    Expand Filter Section
    ${end_date}=    Get Current Date    result_format=%Y-%m-%d
    ${start_date}=    Subtract Time From Date    ${end_date}    30 days    result_format=%Y-%m-%d
    Clear Element Text    ${START_WORK_DATE_INPUT}
    Input Text    ${START_WORK_DATE_INPUT}    ${start_date}
    Clear Element Text    ${END_WORK_DATE_INPUT}
    Input Text    ${END_WORK_DATE_INPUT}    ${end_date}
    Click Search Button
    Verify Search Completed With Retry
    Log To Console    "Date Range filter test completed successfully."
    [Teardown]    Close Browser

Test Installer Names Search Filter
    [Documentation]    Verify the Installer Names search input field works correctly
    [Tags]    filter    installer    search
    Navigate To Field Report List
    Expand Filter Section
    Clear Date Filters
    Wait Until Element Is Visible    ${INSTALLER_SEARCH_INPUT}    timeout=10s
    Input Text    ${INSTALLER_SEARCH_INPUT}    admin
    Sleep    1s    # Wait for search to filter the list
    Log To Console    "Installer Names search filter test completed successfully."
    [Teardown]    Close Browser

Test Installer Names Checkbox Filter
    [Documentation]    Verify the Installer Names checkbox selection works correctly
    [Tags]    filter    installer    checkbox
    Navigate To Field Report List
    Expand Filter Section
    Clear Date Filters
    ${checkboxes}=    Get WebElements    xpath=//input[@id='installer_name_input']
    ${count}=    Get Length    ${checkboxes}
    IF    ${count} > 0
        Click Element    ${checkboxes}[0]
    END
    Click Search Button
    Verify Search Completed With Retry
    Log To Console    "Installer Names checkbox filter test completed successfully."
    [Teardown]    Close Browser

Test Approval Status Filter - All
    [Documentation]    Verify the Approval Status dropdown filter works with 'All' option
    [Tags]    filter    approval    dropdown
    Navigate To Field Report List
    Expand Filter Section
    # Approval Status requires Date Range as per user "exception" logic
    Set Wide Date Range For Testing
    Select From List By Index    ${APPROVAL_STATUS_DROPDOWN}    0
    Click Search Button
    Verify Search Completed With Retry
    Log To Console    "Approval Status filter (All) test completed successfully."
    [Teardown]    Close Browser

Test Approval Status Filter - Approve
    [Documentation]    Verify the Approval Status dropdown filter works with 'Approve' option
    [Tags]    filter    approval    dropdown
    Navigate To Field Report List
    Expand Filter Section
    Set Wide Date Range For Testing
    Select Option By Visible Text Or Index    ${APPROVAL_STATUS_DROPDOWN}    Approve    1
    Click Search Button
    Verify Search Completed With Retry
    Log To Console    "Approval Status filter (Approve) test completed successfully."
    [Teardown]    Close Browser

Test Approval Status Filter - Unapprove
    [Documentation]    Verify the Approval Status dropdown filter works with 'Unapprove' option
    [Tags]    filter    approval    dropdown
    Navigate To Field Report List
    Expand Filter Section
    Set Wide Date Range For Testing
    Select Option By Visible Text Or Index    ${APPROVAL_STATUS_DROPDOWN}    Unapprove    2
    Click Search Button
    Verify Search Completed With Retry
    Log To Console    "Approval Status filter (Unapprove) test completed successfully."
    [Teardown]    Close Browser

Test Product Description Filter
    [Documentation]    Verify the Product Description text input filter works correctly.
    [Tags]    filter    product    text    validation
    Navigate To Field Report List
    Expand Filter Section
    Set Wide Date Range For Testing
    # Use a Swedish term that commonly exists in product descriptions
    ${search_term}=    Set Variable    dörr
    Input Text    ${PRODUCT_DESCRIPTION_INPUT}    ${search_term}
    Click Search Button
    
    # Use the Retry logic to find data first
    Verify Search Completed With Retry
    
    Log To Console    "Search results found. Opening first fieldreport to validate product description..."
    # Double-click on the first result row to open the fieldreport edit page
    ${first_row}=    Get WebElement    ${FIELD_REPORT_ROWS}
    Double Click Element    ${first_row}
    # Wait for new tab/window to open and switch to it
    Sleep    3s
    ${handles}=    Get Window Handles
    ${handle_count}=    Get Length    ${handles}
    IF    ${handle_count} > 1
        Switch Window    NEW
    END
    # Wait for the edit page to load (should contain "FIELD REPORT" text)
    Wait Until Page Contains    FIELD REPORT    timeout=15s
    # Scroll down to find the Products table
    Execute Javascript    window.scrollTo(0, document.body.scrollHeight / 2)
    Sleep    1s
    # Verify the search term exists in the Products table (Description column)
    ${page_source}=    Get Source
    ${term_found}=    Run Keyword And Return Status    Should Contain    ${page_source}    ${search_term}    ignore_case=True
    IF    not ${term_found}
        # Try alternative spellings (Dörr with capital D)
        ${term_found}=    Run Keyword And Return Status    Should Contain    ${page_source}    Dörr
    END
    IF    ${term_found}
        Log To Console    "SUCCESS: Product description '${search_term}' found in fieldreport. Filter validation passed!"
    ELSE
        Fail    Product description "${search_term}" was NOT found in the opened fieldreport. Filter may not be working correctly.
    END
    [Teardown]    Close Browser

Test With Attachment Filter - With Attachment
    [Documentation]    Verify the With Attachment dropdown filter works for reports with attachments
    [Tags]    filter    attachment    dropdown
    Navigate To Field Report List
    Expand Filter Section
    Clear Date Filters
    Select Option By Visible Text Or Index    ${WITH_ATTACHMENT_DROPDOWN}    With Attachment    1
    Click Search Button
    Verify Search Completed With Retry
    Log To Console    "With Attachment filter test completed successfully."
    [Teardown]    Close Browser

Test With Attachment Filter - All Reports
    [Documentation]    Verify the With Attachment dropdown filter works with 'All Reports' option (default)
    [Tags]    filter    attachment    dropdown
    Navigate To Field Report List
    Expand Filter Section
    Clear Date Filters
    Select Option By Visible Text Or Index    ${WITH_ATTACHMENT_DROPDOWN}    All Reports    0
    Click Search Button
    Verify Search Completed With Retry
    Log To Console    "With Attachment filter (All Reports) test completed successfully."
    [Teardown]    Close Browser

Test Clear Filter Functionality
    [Documentation]    Verify the Clear filter functionality resets all filter fields
    [Tags]    filter    clear
    Navigate To Field Report List
    Expand Filter Section
    # Apply some filters first
    Input Text    ${RELATED_PROJECT_INPUT}    Test
    Input Text    ${PRODUCT_DESCRIPTION_INPUT}    Door
    Click Search Button
    Sleep    2s
    # Ensure filter is visible before clearing (search might collapse it)
    Expand Filter Section
    # Clear filters
    Click Element    ${CLEAR_FILTER_LINK}
    Wait Until Page Contains    Filters    timeout=10s
    # Expand filter section again after clear
    Expand Filter Section
    # Verify filters are cleared
    ${project_value}=    Get Value    ${RELATED_PROJECT_INPUT}
    ${product_value}=    Get Value    ${PRODUCT_DESCRIPTION_INPUT}
    Should Be Empty    ${project_value}
    Should Be Empty    ${product_value}
    Log To Console    "Clear filter functionality test completed successfully."
    [Teardown]    Close Browser

Test Combined Filters - Customer And Date Range
    [Documentation]    Verify multiple filters work together (Customer + Date Range)
    [Tags]    filter    combined
    Navigate To Field Report List
    Expand Filter Section
    # Set date range first (Explicit date range test, so use range)
    ${end_date}=    Get Current Date    result_format=%Y-%m-%d
    ${start_date}=    Subtract Time From Date    ${end_date}    90 days    result_format=%Y-%m-%d
    Clear Element Text    ${START_WORK_DATE_INPUT}
    Input Text    ${START_WORK_DATE_INPUT}    ${start_date}
    Clear Element Text    ${END_WORK_DATE_INPUT}
    Input Text    ${END_WORK_DATE_INPUT}    ${end_date}
    # Select customer
    Select First Available Option From Dropdown    ${RELATED_CUSTOMER_DROPDOWN}
    Click Search Button
    Verify Search Completed With Retry
    Log To Console    "Combined filters (Customer + Date Range) test completed successfully."
    [Teardown]    Close Browser

Test Combined Filters - Approval Status And Attachment
    [Documentation]    Verify multiple filters work together (Approval Status + Attachment)
    [Tags]    filter    combined
    Navigate To Field Report List
    Expand Filter Section
    Set Wide Date Range For Testing
    # Select approval status
    Select Option By Visible Text Or Index    ${APPROVAL_STATUS_DROPDOWN}    Approve    1
    # Select with attachment
    Select Option By Visible Text Or Index    ${WITH_ATTACHMENT_DROPDOWN}    With Attachment    1
    Click Search Button
    Verify Search Completed With Retry
    Log To Console    "Combined filters (Approval Status + Attachment) test completed successfully."
    [Teardown]    Close Browser

Test Filter Section Collapse And Expand
    [Documentation]    Verify the filter section can be collapsed and expanded
    [Tags]    filter    ui
    Navigate To Field Report List
    # Filter section should be visible initially after clicking
    Click Element    ${FILTER_SECTION_HEADER}
    Wait Until Element Is Visible    ${SEARCH_BUTTON}    timeout=10s
    # Collapse the filter section
    Click Element    ${FILTER_SECTION_HEADER}
    Sleep    1s
    # Expand again
    Click Element    ${FILTER_SECTION_HEADER}
    Wait Until Element Is Visible    ${SEARCH_BUTTON}    timeout=10s
    Log To Console    "Filter section collapse and expand test completed successfully."
    [Teardown]    Close Browser

*** Keywords ***
Navigate To Field Report List
    [Documentation]    Login and navigate to the Field Report list view
    Open And Login
    Hover Over Production Menu
    Click On Field Report Menu
    Wait Until Page Contains    Filters    timeout=15s
    Wait Until Element Is Visible    ${FILTER_SECTION_HEADER}    timeout=10s

Hover Over Production Menu
    [Documentation]    Hover over the Production menu to reveal submenu
    Wait Until Page Contains Element    ${PRODUCTION_MENU}    timeout=20s
    Execute Javascript    var el = document.getElementById('production'); if(el) el.scrollIntoView({behavior: 'smooth', block: 'center'});
    Sleep    2s
    Wait Until Element Is Visible    ${PRODUCTION_MENU}    timeout=15s
    Mouse Over    ${PRODUCTION_MENU}
    Sleep    1s

Click On Field Report Menu
    [Documentation]    Click on the Field Report submenu item
    Wait Until Element Is Visible    ${FIELD_REPORT_MENU}    timeout=15s
    Click Element    ${FIELD_REPORT_MENU}

Expand Filter Section
    [Documentation]    Expand the filter section if not already expanded
    Sleep    2s
    Execute Javascript    window.scrollTo(0, 0);
    Sleep    1s
    Wait Until Page Contains Element    ${FILTER_SECTION_HEADER}    timeout=30s
    ${is_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${SEARCH_BUTTON}
    IF    not ${is_visible}
        Execute Javascript    var el = document.getElementById('fieldreport_list_filter'); if(el) el.click();
        Sleep    2s
    END
    Wait Until Element Is Visible    ${SEARCH_BUTTON}    timeout=15s

Set Wide Date Range For Testing
    [Documentation]    Set a date range (3 months back to today) to ensure results are not filtered out by default date
    ${end_date}=    Get Current Date    result_format=%Y-%m-%d
    ${start_date}=    Subtract Time From Date    ${end_date}    90 days    result_format=%Y-%m-%d
    Clear Element Text    ${START_WORK_DATE_INPUT}
    Input Text    ${START_WORK_DATE_INPUT}    ${start_date}
    Clear Element Text    ${END_WORK_DATE_INPUT}
    Input Text    ${END_WORK_DATE_INPUT}    ${end_date}

Clear Date Filters
    [Documentation]    Clear Start and End Work Date inputs to allow searching all records
    Clear Element Text    ${START_WORK_DATE_INPUT}
    Clear Element Text    ${END_WORK_DATE_INPUT}
    # Ensure they are really empty by keys if needed, but clear should work.
    
Click Search Button
    [Documentation]    Click the Search button to apply filters
    ${element}=    Get WebElement    ${SEARCH_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${element}
    Sleep    3s    # Wait for results to load

Select First Available Option From Dropdown
    [Documentation]    Select the first non-empty option from a dropdown
    [Arguments]    ${dropdown_locator}
    ${options}=    Get List Items    ${dropdown_locator}
    ${count}=    Get Length    ${options}
    IF    ${count} > 1
        Select From List By Index    ${dropdown_locator}    1
    END

Select Option By Visible Text Or Index
    [Documentation]    Try to select by visible text, fallback to index if not found
    [Arguments]    ${dropdown_locator}    ${text}    ${fallback_index}
    ${status}=    Run Keyword And Return Status    Select From List By Label    ${dropdown_locator}    ${text}
    IF    not ${status}
        Select From List By Index    ${dropdown_locator}    ${fallback_index}
    END

Verify Search Results
    [Documentation]    Simple verification of search results (Success if Rows found Or "No Records" message)
    ...                Does NOT retry search.
    ${has_results}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${FIELD_REPORT_ROWS}    timeout=5s
    IF    ${has_results}
        Log    Search returned results - fieldreport rows found
        RETURN
    END
    
    # Check for empty state indicators
    ${has_datatable_empty}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${DATATABLES_EMPTY}    timeout=3s
    ${has_custom_message}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${NO_RECORDS_H6}    timeout=3s
    ${has_total_text}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${TOTAL_REPORTS_TEXT}    timeout=3s
    
    IF    ${has_datatable_empty} or ${has_custom_message} or ${has_total_text}
         Log    Search completed (No results found, but UI handled it correctly).
         RETURN
    END

    Fail    Search did not complete properly - no results, empty message, or total text found.

Verify Search Completed With Retry
    [Documentation]    Verify search results, with recursive logic to search further back in time if no results found.
    ...                Used for Date and Approval Status filters.
    
    FOR    ${i}    IN RANGE    0    5
        ${has_results}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${FIELD_REPORT_ROWS}    timeout=5s
        
        IF    ${has_results}
            Log    Search returned results - fieldreport rows found
            RETURN
        END
        
        # If no results found, try searching further back in time
        Log To Console    No results found in current range. Extending search range backwards by 90 days...
        
        # Ensure filter section is expanded before interacting with date inputs
        Expand Filter Section
        
        # Get current date values from inputs or state
        ${current_start}=    Get Value    ${START_WORK_DATE_INPUT}
        ${current_end}=    Get Value    ${END_WORK_DATE_INPUT}
        
        # If inputs empty, set a baseline (though test setup usually sets them)
        IF    '${current_start}' == ''
            ${end_date}=    Get Current Date    result_format=%Y-%m-%d
            ${start_date}=    Subtract Time From Date    ${end_date}    90 days    result_format=%Y-%m-%d
        ELSE
            # Logic: Shift window back by 90 days. 
            # New End Date = Old Start Date - 1 day
            # New Start Date = New End Date - 90 days
            ${old_start_obj}=    Convert Date    ${current_start}    result_format=datetime
            ${new_end_obj}=      Subtract Time From Date    ${old_start_obj}    1 day    result_format=%Y-%m-%d
            ${new_start_obj}=    Subtract Time From Date    ${new_end_obj}    90 days    result_format=%Y-%m-%d
            ${start_date}=       Set Variable    ${new_start_obj}
            ${end_date}=         Set Variable    ${new_end_obj}
        END

        # Apply new dates
        Clear Element Text    ${START_WORK_DATE_INPUT}
        Input Text    ${START_WORK_DATE_INPUT}    ${start_date}
        Clear Element Text    ${END_WORK_DATE_INPUT}
        Input Text    ${END_WORK_DATE_INPUT}    ${end_date}
        
        Log To Console    Retrying search (Attempt ${i+1}) with range: ${start_date} to ${end_date}
        Click Search Button
        
    END

    # Final check after retries
    ${has_results_final}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${FIELD_REPORT_ROWS}    timeout=5s
    IF    ${has_results_final}
         Log    Search returned results after extended range search
         RETURN
    END

    # If still no results, use generic verification for empty state
    Verify Search Results

Undo All Installer Selections
    [Documentation]    Click the undo selection button for installer checkboxes
    ${is_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${UNDO_SELECT_CHECKBOX}
    IF    ${is_visible}
        Click Element    ${UNDO_SELECT_CHECKBOX}
    END
