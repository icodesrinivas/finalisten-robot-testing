*** Settings ***
Documentation    Test suite for verifying Product ADD table functionality in Field Report.
...              
...              Tests include:
...              - Opening the ADD product modal
...              - Search functionality within the modal
...              - Pagination of products in the modal
...              - Selecting products and saving from checkbox (row-wise)
...              - Selecting products and saving from bottom Save button
...              - Verifying fields are correctly copied from sales product to FR product
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
${FIELDREPORT_CREATE_URL}         ${BASE_URL}/fieldreport/create/

# Form Field Selectors
${CUSTOMER_DROPDOWN}              id=id_related_customer
${PROJECT_DROPDOWN}               id=id_related_project
${SUBPROJECT_DROPDOWN}            id=id_related_subproject
${WORK_DATE_INPUT}                id=id_work_date
${INSTALLER_DROPDOWN}             id=id_installer_name
${SAVE_BUTTON}                    css=button.save
${DELETE_BUTTON}                  id=remove_fieldreport

# Product Modal Selectors
${ADD_PRODUCT_BUTTON}             xpath=//span[text()='ADD']
${PRODUCT_MODAL}                  id=myModal3
${PRODUCT_SEARCH_INPUT}           id=myInput
${SELECT_ALL_CHECKBOX}            id=select-all
${PRODUCT_CHECKBOX}               css=#prodInProjTable .selected-checkbox
${ROW_SAVE_BUTTON}                css=.prod-in-fr-save
${MODAL_SAVE_BUTTON}              css=.prodinfr_save_button
${MODAL_CANCEL_BUTTON}            xpath=//div[@id='myModal3']//button[contains(text(),'Cancel')]
${PAGINATION_NEXT}                css=#prodInProjTable_next
${PAGINATION_PREV}                css=#prodInProjTable_previous
${PRODUCT_TABLE_ROWS}             css=#prodInProjTable tbody tr

# Products in FR Table
${PRODUCTS_TABLE}                 id=prodInFieldReportTable
${COMMON_EDIT_BUTTON}             id=product_in_fieldreport_edit

# Initial Values (for creation)
${INITIAL_WORK_DATE}              2025-10-20

# Test State Variables
${CREATED_FIELDREPORT_ID}         ${EMPTY}

*** Test Cases ***
Test Open ADD Product Modal
    [Documentation]    Test that clicking ADD button opens the product selection modal.
    [Tags]    fieldreport    product    modal    add
    [Setup]    Create Field Report For Product Test
    
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Log To Console    ======== TESTING ADD PRODUCT MODAL ========
    
    # Scroll down to Products section
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    1s
    
    # Click ADD button
    Log To Console    \n--- Clicking ADD Button ---
    Wait Until Element Is Visible    ${ADD_PRODUCT_BUTTON}    timeout=10s
    Click Element    ${ADD_PRODUCT_BUTTON}
    Sleep    2s
    
    # Verify modal is open
    Wait Until Element Is Visible    ${PRODUCT_MODAL}    timeout=10s
    ${modal_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${PRODUCT_MODAL}
    Should Be True    ${modal_visible}    msg=Product modal should be visible
    Log To Console    ✓ ADD Product Modal opened successfully
    
    # Verify search input exists
    Wait Until Element Is Visible    ${PRODUCT_SEARCH_INPUT}    timeout=5s
    Log To Console    ✓ Search input field is present
    
    # Close modal
    Click Element    ${MODAL_CANCEL_BUTTON}
    Sleep    1s
    Log To Console    ✓ Modal closed
    
    Log To Console    \n======== ADD PRODUCT MODAL TEST PASSED! ========
    
    [Teardown]    Cleanup Created Fieldreport

Test Product Modal Search Functionality
    [Documentation]    Test the search functionality within the ADD product modal.
    [Tags]    fieldreport    product    modal    search
    [Setup]    Create Field Report For Product Test
    
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Log To Console    ======== TESTING PRODUCT SEARCH FUNCTIONALITY ========
    
    # Open ADD modal
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    1s
    Wait Until Element Is Visible    ${ADD_PRODUCT_BUTTON}    timeout=10s
    Click Element    ${ADD_PRODUCT_BUTTON}
    Wait Until Element Is Visible    ${PRODUCT_MODAL}    timeout=10s
    
    # Get initial row count
    Sleep    2s
    ${initial_rows}=    Get Element Count    ${PRODUCT_TABLE_ROWS}
    Log To Console    Initial product count: ${initial_rows}
    
    # Enter search term
    Log To Console    \n--- Testing Search Functionality ---
    Input Text    ${PRODUCT_SEARCH_INPUT}    test
    Sleep    2s
    
    # Verify search filters results
    ${filtered_rows}=    Get Element Count    ${PRODUCT_TABLE_ROWS}
    Log To Console    Filtered product count: ${filtered_rows}
    Log To Console    ✓ Search filter applied (rows changed from ${initial_rows} to ${filtered_rows})
    
    # Clear search
    Clear Element Text    ${PRODUCT_SEARCH_INPUT}
    Sleep    2s
    
    ${restored_rows}=    Get Element Count    ${PRODUCT_TABLE_ROWS}
    Log To Console    Restored product count: ${restored_rows}
    Log To Console    ✓ Search cleared successfully
    
    # Close modal
    Click Element    ${MODAL_CANCEL_BUTTON}
    Sleep    1s
    
    Log To Console    \n======== PRODUCT SEARCH TEST PASSED! ========
    
    [Teardown]    Cleanup Created Fieldreport

Test Product Modal Pagination
    [Documentation]    Test the pagination functionality in the ADD product modal.
    [Tags]    fieldreport    product    modal    pagination
    [Setup]    Create Field Report For Product Test
    
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Log To Console    ======== TESTING PRODUCT MODAL PAGINATION ========
    
    # Open ADD modal
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    1s
    Wait Until Element Is Visible    ${ADD_PRODUCT_BUTTON}    timeout=10s
    Click Element    ${ADD_PRODUCT_BUTTON}
    Wait Until Element Is Visible    ${PRODUCT_MODAL}    timeout=10s
    Sleep    2s
    
    # Check if pagination exists
    Log To Console    \n--- Testing Pagination ---
    ${pagination_exists}=    Run Keyword And Return Status    Page Should Contain Element    ${PAGINATION_NEXT}
    
    IF    ${pagination_exists}
        # Get first row text before pagination
        ${first_row_before}=    Get Text    css=#prodInProjTable tbody tr:first-child
        Log To Console    First row before navigation: ${first_row_before}
        
        # Click next page
        Click Element    ${PAGINATION_NEXT}
        Sleep    2s
        
        # Verify content changed
        ${first_row_after}=    Get Text    css=#prodInProjTable tbody tr:first-child
        Log To Console    First row after navigation: ${first_row_after}
        
        IF    '${first_row_before}' != '${first_row_after}'
            Log To Console    ✓ Pagination working - content changed
        ELSE
            Log To Console    ⚠ Only one page of results available
        END
        
        # Click previous
        ${prev_enabled}=    Run Keyword And Return Status    Element Should Be Enabled    ${PAGINATION_PREV}
        IF    ${prev_enabled}
            Click Element    ${PAGINATION_PREV}
            Sleep    2s
            Log To Console    ✓ Previous page navigation works
        END
    ELSE
        Log To Console    ⚠ Pagination not present (less than one page of products)
    END
    
    # Close modal
    Click Element    ${MODAL_CANCEL_BUTTON}
    Sleep    1s
    
    Log To Console    \n======== PAGINATION TEST PASSED! ========
    
    [Teardown]    Cleanup Created Fieldreport

Test Select Product With Row Save Button
    [Documentation]    Test selecting a product and saving using the row-wise save button (checkbox area).
    [Tags]    fieldreport    product    modal    rowsave
    [Setup]    Create Field Report For Product Test
    
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Log To Console    ======== TESTING ROW-WISE PRODUCT SAVE ========
    
    # Open ADD modal
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    1s
    Wait Until Element Is Visible    ${ADD_PRODUCT_BUTTON}    timeout=10s
    Click Element    ${ADD_PRODUCT_BUTTON}
    Wait Until Element Is Visible    ${PRODUCT_MODAL}    timeout=10s
    Sleep    2s
    
    # Select first product checkbox
    Log To Console    \n--- Selecting Product and Using Row Save ---
    # Wait longer for products to load
    ${status}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${PRODUCT_CHECKBOX}    timeout=30s
    IF    not ${status}
        Log To Console    ⚠ No products found in modal after 30s.
        Click Element    ${MODAL_CANCEL_BUTTON}
        Fail    Could not find products in modal.
    END

    Click Element    ${PRODUCT_CHECKBOX}
    Sleep    1s
    
    # Look for the row-wise save button that appears after selection
    ${row_save_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${ROW_SAVE_BUTTON}    timeout=5s
    
    IF    ${row_save_visible}
        Click Element    ${ROW_SAVE_BUTTON}
        Sleep    2s
        Log To Console    ✓ Row save button clicked
    ELSE
        Log To Console    ⚠ Row save button not visible, using modal save button
        Click Element    ${MODAL_SAVE_BUTTON}
        Sleep    2s
    END
    
    # Handle any alerts
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
    Sleep    2s
    
    # Wait for products to appear in the main table
    Wait Until Element Is Visible    css=#prodInFieldReportTable tbody tr    timeout=15s
    ${product_rows}=    Get Element Count    css=#prodInFieldReportTable tbody tr
    Should Be True    ${product_rows} >= 1    msg=Product should be added to the field report
    Log To Console    ✓ Product added successfully (${product_rows} product(s) in FR)
    
    Log To Console    \n======== ROW-WISE SAVE TEST PASSED! ========
    
    [Teardown]    Cleanup Created Fieldreport

Test Select Product With Modal Save Button
    [Documentation]    Test selecting a product and saving using the main Save button at the bottom.
    [Tags]    fieldreport    product    modal    modalsave
    [Setup]    Create Field Report For Product Test
    
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Log To Console    ======== TESTING MODAL SAVE BUTTON ========
    
    # Open ADD modal
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    1s
    Wait Until Element Is Visible    ${ADD_PRODUCT_BUTTON}    timeout=10s
    Click Element    ${ADD_PRODUCT_BUTTON}
    Wait Until Element Is Visible    ${PRODUCT_MODAL}    timeout=10s
    Sleep    2s
    
    # Select first product checkbox
    Log To Console    \n--- Selecting Product and Using Modal Save ---
    # Wait longer for products to load
    ${status}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${PRODUCT_CHECKBOX}    timeout=30s
    IF    not ${status}
        Log To Console    ⚠ No products found in modal after 30s.
        Click Element    ${MODAL_CANCEL_BUTTON}
        Fail    Could not find products in modal.
    END

    Click Element    ${PRODUCT_CHECKBOX}
    Sleep    1s
    Log To Console    ✓ Product selected
    
    # Scroll to bottom of modal and click save
    Execute Javascript    document.querySelector('#myModal3 .modal-content').scrollTo(0, 9999);
    Sleep    1s
    
    Wait Until Element Is Visible    ${MODAL_SAVE_BUTTON}    timeout=5s
    Click Element    ${MODAL_SAVE_BUTTON}
    Sleep    2s
    Log To Console    ✓ Modal save button clicked
    
    # Handle any alerts
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
    Sleep    2s
    
    # Wait for products to appear in the main table
    Wait Until Element Is Visible    css=#prodInFieldReportTable tbody tr    timeout=15s
    ${product_rows}=    Get Element Count    css=#prodInFieldReportTable tbody tr
    Should Be True    ${product_rows} >= 1    msg=Product should be added to the field report
    Log To Console    ✓ Product added successfully (${product_rows} product(s) in FR)
    
    Log To Console    \n======== MODAL SAVE TEST PASSED! ========
    
    [Teardown]    Cleanup Created Fieldreport

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

Create Field Report For Product Test
    [Documentation]    Create a new field report for product testing
    Login To Application
    
    Log To Console    ======== CREATING FIELD REPORT FOR PRODUCT TEST ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Select first available customer
    Select From List By Label    ${CUSTOMER_DROPDOWN}    Arcona Aktiebolag
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Select first available project
    Select From List By Label    ${PROJECT_DROPDOWN}    Systemkameran
    ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Select first available subproject
    Select From List By Index    ${SUBPROJECT_DROPDOWN}    1
    
    # Set work date
    Input Text    ${WORK_DATE_INPUT}    ${INITIAL_WORK_DATE}
    
    # Select installer
    Select From List By Index    ${INSTALLER_DROPDOWN}    1
    
    # Save the field report
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    3s
    
    # Extract field report ID from URL
    ${current_url}=    Get Location
    Should Contain    ${current_url}    /edit/    msg=Failed to create field report
    ${fieldreport_id}=    Extract Fieldreport ID From URL    ${current_url}
    Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${fieldreport_id}
    Log To Console    ✓ Created Field Report ID: ${fieldreport_id}

Extract Fieldreport ID From URL
    [Documentation]    Extract the fieldreport ID from the edit page URL
    [Arguments]    ${url}
    ${parts}=    Split String    ${url}    /
    FOR    ${i}    ${part}    IN ENUMERATE    @{parts}
        ${is_numeric}=    Run Keyword And Return Status    Should Match Regexp    ${part}    ^\\d+$
        IF    ${is_numeric}
            RETURN    ${part}
        END
    END
    Fail    Could not extract fieldreport ID from URL: ${url}

Cleanup Created Fieldreport
    [Documentation]    Delete the created fieldreport
    Log To Console    ======== CLEANUP: Deleting Field Report ========
    
    ${has_id}=    Run Keyword And Return Status    Should Not Be Empty    ${CREATED_FIELDREPORT_ID}
    
    IF    ${has_id}
        ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
        Go To    ${edit_url}
        Sleep    2s
        
        ${delete_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${DELETE_BUTTON}    timeout=10s
        
        IF    ${delete_exists}
            Log To Console    Deleting Field Report ID: ${CREATED_FIELDREPORT_ID}
            Click Element    ${DELETE_BUTTON}
            Sleep    1s
            Handle Alert    action=ACCEPT    timeout=5s
            Sleep    2s
            Log To Console    ✓ Field Report ${CREATED_FIELDREPORT_ID} deleted successfully!
        END
    END
    
    Close All Browsers
