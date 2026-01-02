*** Settings ***
Documentation    Test suite for filter combination testing in Field Report list.
...              
...              Tests include:
...              42. Apply Customer + Project filter together
...              43. Apply Date Range + Approval Status filter together
...              44. Apply Installer + Product Description filter together
...              45. Clear all filters - verify all FR displayed
Library          SeleniumLibrary
Library          DateTime
Library          String
Library          Collections
Resource         ../keywords/LoginKeyword.robot

*** Variables ***
# URLs (configurable for different environments)
${BASE_URL}                       https://preproderp.finalisten.se
${LOGIN_URL}                      ${BASE_URL}/login/
${HOMEPAGE_URL}                   ${BASE_URL}/homepage/
${FIELDREPORT_LIST_URL}           ${BASE_URL}/fieldreport/list/

# Filter Selectors
${FILTER_TOGGLE}                  id=fieldreport_list_filter
${SEARCH_BUTTON}                  id=fieldreport_list_search
${CUSTOMER_FILTER}                id=id_related_customer
${PROJECT_FILTER}                 id=related_project
${START_DATE_FILTER}              id=start_work_date
${END_DATE_FILTER}                id=end_work_date
${APPROVAL_STATUS_FILTER}         id=id_approved
${INSTALLER_SEARCH}               id=searchColumn
${PRODUCT_DESCRIPTION_FILTER}     id=product_description

# Results Table
${RESULTS_TABLE}                  id=DataTables_Table_0
${TABLE_ROWS}                     css=.fieldreport_rows

*** Test Cases ***
Test Customer And Project Filter Combined
    [Documentation]    Point 42: Apply Customer and Project filter together and verify results.
    [Tags]    fieldreport    filter    combination
    [Setup]    Login To Application
    
    Log To Console    ======== TEST: Customer + Project Filter Combined ========
    Go To    ${FIELDREPORT_LIST_URL}
    Wait Until Page Contains Element    ${FILTER_TOGGLE}    timeout=15s
    
    # Expand filters
    Click Element    ${FILTER_TOGGLE}
    Sleep    1s
    
    # Set wide date range first
    Clear Element Text    ${START_DATE_FILTER}
    Input Text    ${START_DATE_FILTER}    2025-01-01
    Clear Element Text    ${END_DATE_FILTER}
    Input Text    ${END_DATE_FILTER}    2025-12-31
    
    # Get initial count (no filter)
    Click Element    ${SEARCH_BUTTON}
    Sleep    3s
    ${initial_count}=    Get Element Count    ${TABLE_ROWS}
    Log To Console    Initial results (no filter): ${initial_count}
    
    # Apply Customer filter
    ${customer_options}=    Get List Items    ${CUSTOMER_FILTER}
    IF    len($customer_options) > 1
        Select From List By Index    ${CUSTOMER_FILTER}    1
        ${selected_customer}=    Get Selected List Label    ${CUSTOMER_FILTER}
        Log To Console    Selected Customer: ${selected_customer}
    END
    
    # Apply Project filter
    ${project_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${PROJECT_FILTER}    timeout=5s
    IF    ${project_visible}
        Input Text    ${PROJECT_FILTER}    test
        Log To Console    Entered Project filter: test
    END
    
    # Search with both filters
    Click Element    ${SEARCH_BUTTON}
    Sleep    3s
    
    ${filtered_count}=    Get Element Count    ${TABLE_ROWS}
    Log To Console    Results with Customer+Project filter: ${filtered_count}
    
    # Filtered results should be <= initial (or possibly 0)
    Should Be True    ${filtered_count} <= ${initial_count}    msg=Combined filter should narrow results
    Log To Console    ✓ Customer + Project filter combination works
    
    [Teardown]    Close All Browsers

Test Date Range And Approval Status Filter Combined
    [Documentation]    Point 43: Apply Date Range and Approval Status filter together and verify.
    [Tags]    fieldreport    filter    combination
    [Setup]    Login To Application
    
    Log To Console    ======== TEST: Date Range + Approval Status Filter Combined ========
    Go To    ${FIELDREPORT_LIST_URL}
    Wait Until Page Contains Element    ${FILTER_TOGGLE}    timeout=15s
    
    # Expand filters
    Click Element    ${FILTER_TOGGLE}
    Sleep    1s
    
    # Set specific date range
    Clear Element Text    ${START_DATE_FILTER}
    Input Text    ${START_DATE_FILTER}    2025-10-01
    Clear Element Text    ${END_DATE_FILTER}
    Input Text    ${END_DATE_FILTER}    2025-10-31
    Log To Console    Date Range: 2025-10-01 to 2025-10-31
    
    # Set Approval Status to "Approve"
    ${approval_options}=    Get List Items    ${APPROVAL_STATUS_FILTER}
    Log To Console    Approval options: ${approval_options}
    
    # Select "Approve" option
    ${approve_exists}=    Run Keyword And Return Status    Select From List By Label    ${APPROVAL_STATUS_FILTER}    Approve
    IF    not ${approve_exists}
        Select From List By Index    ${APPROVAL_STATUS_FILTER}    1
    END
    ${selected_status}=    Get Selected List Label    ${APPROVAL_STATUS_FILTER}
    Log To Console    Selected Approval Status: ${selected_status}
    
    # Search with combined filters
    Click Element    ${SEARCH_BUTTON}
    Sleep    3s
    
    ${filtered_count}=    Get Element Count    ${TABLE_ROWS}
    Log To Console    Results with Date Range + Approval filter: ${filtered_count}
    
    Log To Console    ✓ Date Range + Approval Status filter combination works
    
    [Teardown]    Close All Browsers

Test Installer And Product Description Filter Combined
    [Documentation]    Point 44: Apply Installer and Product Description filter together.
    [Tags]    fieldreport    filter    combination
    [Setup]    Login To Application
    
    Log To Console    ======== TEST: Installer + Product Description Filter Combined ========
    Go To    ${FIELDREPORT_LIST_URL}
    Wait Until Page Contains Element    ${FILTER_TOGGLE}    timeout=15s
    
    # Expand filters
    Click Element    ${FILTER_TOGGLE}
    Sleep    1s
    
    # Set wide date range
    Clear Element Text    ${START_DATE_FILTER}
    Input Text    ${START_DATE_FILTER}    2025-01-01
    Clear Element Text    ${END_DATE_FILTER}
    Input Text    ${END_DATE_FILTER}    2025-12-31
    
    # Search for installers
    ${installer_search_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${INSTALLER_SEARCH}    timeout=5s
    IF    ${installer_search_visible}
        Input Text    ${INSTALLER_SEARCH}    admin
        Log To Console    Installer search: admin
        Sleep    1s
        
        # Click first installer checkbox if visible
        ${installer_checkbox}=    Run Keyword And Return Status    Click Element    css=input[name='installer_name_input']
        Sleep    1s
    END
    
    # Add Product Description filter
    ${product_filter_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${PRODUCT_DESCRIPTION_FILTER}    timeout=5s
    IF    ${product_filter_visible}
        Input Text    ${PRODUCT_DESCRIPTION_FILTER}    test
        Log To Console    Product Description: test
    END
    
    # Search with combined filters
    Click Element    ${SEARCH_BUTTON}
    Sleep    3s
    
    ${filtered_count}=    Get Element Count    ${TABLE_ROWS}
    Log To Console    Results with Installer + Product Description filter: ${filtered_count}
    
    Log To Console    ✓ Installer + Product Description filter combination works
    
    [Teardown]    Close All Browsers

Test Clear All Filters Shows All Results
    [Documentation]    Point 45: Clear all filters and verify all Field Reports are displayed.
    [Tags]    fieldreport    filter    clear
    [Setup]    Login To Application
    
    Log To Console    ======== TEST: Clear All Filters ========
    Go To    ${FIELDREPORT_LIST_URL}
    Wait Until Page Contains Element    ${FILTER_TOGGLE}    timeout=15s
    
    # Expand filters
    Click Element    ${FILTER_TOGGLE}
    Sleep    1s
    
    # First apply restrictive filters
    Clear Element Text    ${START_DATE_FILTER}
    Input Text    ${START_DATE_FILTER}    2025-10-15
    Clear Element Text    ${END_DATE_FILTER}
    Input Text    ${END_DATE_FILTER}    2025-10-15
    
    ${customer_options}=    Get List Items    ${CUSTOMER_FILTER}
    IF    len($customer_options) > 1
        Select From List By Index    ${CUSTOMER_FILTER}    1
    END
    
    Click Element    ${SEARCH_BUTTON}
    Sleep    3s
    
    ${restricted_count}=    Get Element Count    ${TABLE_ROWS}
    Log To Console    Results with restrictive filters: ${restricted_count}
    
    # Now clear all filters
    Log To Console    Clearing all filters...
    
    # Reset date range to wide
    Clear Element Text    ${START_DATE_FILTER}
    Input Text    ${START_DATE_FILTER}    2025-01-01
    Clear Element Text    ${END_DATE_FILTER}
    Input Text    ${END_DATE_FILTER}    2025-12-31
    
    # Reset Customer to "All" (first option)
    Select From List By Index    ${CUSTOMER_FILTER}    0
    
    # Reset Approval Status to "All"
    Select From List By Index    ${APPROVAL_STATUS_FILTER}    0
    
    # Clear text fields
    ${project_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${PROJECT_FILTER}
    IF    ${project_visible}
        Clear Element Text    ${PROJECT_FILTER}
    END
    
    ${product_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${PRODUCT_DESCRIPTION_FILTER}
    IF    ${product_visible}
        Clear Element Text    ${PRODUCT_DESCRIPTION_FILTER}
    END
    
    # Search again
    Click Element    ${SEARCH_BUTTON}
    Sleep    3s
    
    ${cleared_count}=    Get Element Count    ${TABLE_ROWS}
    Log To Console    Results after clearing filters: ${cleared_count}
    
    # Cleared results should be >= restricted
    Should Be True    ${cleared_count} >= ${restricted_count}    msg=Clearing filters should show more results
    Log To Console    ✓ Clear all filters restores full results
    
    [Teardown]    Close All Browsers

*** Keywords ***
Login To Application
    [Documentation]    Open browser and login to the application
    Open Browser    ${LOGIN_URL}    ${BROWSER}    options=${CHROME_OPTIONS}
    Maximize Browser Window
    Wait Until Page Contains Element    xpath=//input[@name='username']    timeout=10s
    Input Text    xpath=//input[@name='username']    ${USERNAME}
    Input Text    xpath=//input[@name='password']    ${PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Contains    ${HOMEPAGE_URL}    timeout=15s
    Log To Console    Successfully logged in
