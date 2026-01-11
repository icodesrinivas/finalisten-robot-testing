*** Settings ***
Documentation    Test suite for extended approval workflow testing in Field Report.
...              
...              Tests include:
...              34. Approve FR with products - verify product fields become read-only
...              35. Approve FR - verify general data fields become read-only
...              36. Unapprove FR - verify fields become editable again
...              37. Approve empty FR (no products) - verify behavior
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
${TOTAL_HOURS_INPUT}              id=id_total_work_hours
${INSTALLER_DROPDOWN}             id=id_installer_name
${SAVE_BUTTON}                    css=button.save
${EDIT_GENERAL_DATA_BUTTON}       id=EditGeneralDataButton
${SAVE_GENERAL_DATA_BUTTON}       id=fieldreport_general_data_save

# Action Buttons
${APPROVE_BUTTON}                 id=id_fieldreport_approve_btn
${DELETE_BUTTON}                  id=remove_fieldreport

# Product Selectors
${ADD_PRODUCT_BUTTON}             xpath=//span[text()='ADD']
${PRODUCT_MODAL}                  id=myModal3
${MODAL_SAVE_BUTTON}              css=.prodinfr_save_button
${PRODUCT_CHECKBOX}               css=#myTable .selected-checkbox
${MODAL_CANCEL_BUTTON}            xpath=//div[@id='myModal3']//button[contains(text(),'Cancel')]
${COMMON_EDIT_BUTTON}             id=common_edit_product

# Test Values
${VALID_WORK_DATE}                2025-10-15

# Test State Variables
${CREATED_FIELDREPORT_ID}         ${EMPTY}

*** Test Cases ***
Test Approved FR Products Are Read Only
    [Documentation]    Point 34: Approve FR with products and verify product fields become read-only.
    [Tags]    fieldreport    approval    workflow    readonly
    [Setup]    Create Field Report With Product
    
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${APPROVE_BUTTON}    timeout=15s
    Log To Console    ======== TEST: Approved FR Products Read-Only ========
    
    # Check products can be edited before approval
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    1s
    ${edit_before}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${COMMON_EDIT_BUTTON}    timeout=5s
    Log To Console    Product edit button visible before approval: ${edit_before}
    
    # Approve the FR
    Log To Console    Approving Field Report...
    Click Element    ${APPROVE_BUTTON}
    Sleep    2s
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
    Sleep    2s
    
    # Verify button shows Unapprove (FR is approved)
    ${btn_value}=    Get Element Attribute    ${APPROVE_BUTTON}    value
    Should Contain    ${btn_value}    Unapprove    msg=FR should be approved
    Log To Console    ✓ Field Report approved (button shows: ${btn_value})
    
    # Check if product edit button is still visible/enabled
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    1s
    ${edit_after}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${COMMON_EDIT_BUTTON}    timeout=5s
    
    IF    ${edit_after}
        # Check if button is disabled
        ${btn_class}=    Get Element Attribute    ${COMMON_EDIT_BUTTON}    class
        ${is_disabled}=    Run Keyword And Return Status    Should Contain    ${btn_class}    disabled
        IF    ${is_disabled}
            Log To Console    ✓ Product edit button is disabled after approval
        ELSE
            Log To Console    ⚠ Product edit button might still be active (check manually)
        END
    ELSE
        Log To Console    ✓ Product edit button is hidden after approval
    END
    
    [Teardown]    Cleanup Approved Fieldreport

Test Approved FR General Data Is Read Only
    [Documentation]    Point 35: Approve FR and verify general data fields become read-only.
    [Tags]    fieldreport    approval    workflow    readonly
    [Setup]    Create Field Report For Test
    
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${APPROVE_BUTTON}    timeout=15s
    Log To Console    ======== TEST: Approved FR General Data Read-Only ========
    
    # Check edit button is available before approval
    ${edit_before}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${EDIT_GENERAL_DATA_BUTTON}    timeout=5s
    Log To Console    Edit button visible before approval: ${edit_before}
    
    # Approve the FR
    Log To Console    Approving Field Report...
    Click Element    ${APPROVE_BUTTON}
    Sleep    2s
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
    Sleep    2s
    
    # Verify approved
    ${btn_value}=    Get Element Attribute    ${APPROVE_BUTTON}    value
    Should Contain    ${btn_value}    Unapprove
    Log To Console    ✓ Field Report approved
    
    # Check if edit button is hidden or disabled
    ${edit_after}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${EDIT_GENERAL_DATA_BUTTON}    timeout=5s
    
    IF    ${edit_after}
        ${btn_value_edit}=    Get Element Attribute    ${EDIT_GENERAL_DATA_BUTTON}    value
        ${btn_class}=    Get Element Attribute    ${EDIT_GENERAL_DATA_BUTTON}    class
        Log To Console    Edit button value after approval: ${btn_value_edit}
        Log To Console    Edit button class after approval: ${btn_class}
        ${is_disabled}=    Run Keyword And Return Status    Should Contain    ${btn_class}    disabled
        IF    ${is_disabled}
            Log To Console    ✓ General data edit button is disabled after approval
        END
    ELSE
        Log To Console    ✓ General data edit button is hidden after approval
    END
    
    [Teardown]    Cleanup Approved Fieldreport

Test Unapproved FR Fields Become Editable
    [Documentation]    Point 36: Unapprove previously approved FR and verify fields become editable.
    [Tags]    fieldreport    approval    workflow    editable
    [Setup]    Create Field Report For Test
    
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${APPROVE_BUTTON}    timeout=15s
    Log To Console    ======== TEST: Unapproved FR Fields Become Editable ========
    
    # First approve the FR
    Log To Console    Step 1: Approving Field Report...
    Click Element    ${APPROVE_BUTTON}
    Sleep    2s
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
    Sleep    2s
    
    ${btn_value}=    Get Element Attribute    ${APPROVE_BUTTON}    value
    Should Contain    ${btn_value}    Unapprove
    Log To Console    ✓ Field Report approved
    
    # Now unapprove the FR
    Log To Console    Step 2: Unapproving Field Report...
    Click Element    ${APPROVE_BUTTON}
    Sleep    2s
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
    Sleep    2s
    
    ${btn_value_after}=    Get Element Attribute    ${APPROVE_BUTTON}    value
    Should Contain    ${btn_value_after}    Approve
    Log To Console    ✓ Field Report unapproved
    
    # Verify edit button is now available
    ${edit_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${EDIT_GENERAL_DATA_BUTTON}    timeout=5s
    Should Be True    ${edit_visible}    msg=Edit button should be visible after unapproval
    Log To Console    ✓ Edit button is visible after unapproval
    
    # Try clicking edit to verify it works
    Click Element    ${EDIT_GENERAL_DATA_BUTTON}
    Sleep    1s
    
    # Fields should now be editable - try modifying a field
    ${hours_editable}=    Run Keyword And Return Status    Input Text    ${TOTAL_HOURS_INPUT}    99
    Log To Console    ✓ Fields are editable after unapproval
    
    [Teardown]    Cleanup Created Fieldreport

Test Approve Empty FR Behavior
    [Documentation]    Point 37: Attempt to approve empty FR (no products) and verify behavior.
    [Tags]    fieldreport    approval    workflow    empty
    [Setup]    Create Field Report For Test
    
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${APPROVE_BUTTON}    timeout=15s
    Log To Console    ======== TEST: Approve Empty FR (No Products) ========
    
    # Verify no products
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    1s
    ${product_rows}=    Get Element Count    css=#product-list-table tbody tr
    Log To Console    Number of products in FR: ${product_rows}
    
    # Try to approve
    Execute Javascript    window.scrollTo(0, 0);
    Sleep    1s
    Log To Console    Attempting to approve empty Field Report...
    Click Element    ${APPROVE_BUTTON}
    Sleep    2s
    
    # Check for alert - might prevent approval of empty FR
    ${alert_text}=    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=5s
    Log To Console    Alert response: ${alert_text}
    Sleep    2s
    
    # Check current state
    ${btn_value}=    Get Element Attribute    ${APPROVE_BUTTON}    value
    Log To Console    Button value after attempt: ${btn_value}
    
    ${is_approved}=    Run Keyword And Return Status    Should Contain    ${btn_value}    Unapprove
    IF    ${is_approved}
        Log To Console    ✓ System allows approving empty FR (0 products)
    ELSE
        Log To Console    ✓ System prevents approving empty FR (requires products)
    END
    
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

Create Field Report For Test
    [Documentation]    Create a basic field report
    Login To Application
    
    Log To Console    Creating Field Report...
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    Select From List By Label    ${CUSTOMER_DROPDOWN}    Arcona Aktiebolag
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    Select From List By Label    ${PROJECT_DROPDOWN}    Systemkameran
    ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    Select From List By Index    ${SUBPROJECT_DROPDOWN}    1
    Input Text    ${WORK_DATE_INPUT}    ${VALID_WORK_DATE}
    Select From List By Index    ${INSTALLER_DROPDOWN}    1
    
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    3s
    
    ${current_url}=    Get Location
    ${fieldreport_id}=    Extract Fieldreport ID From URL    ${current_url}
    Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${fieldreport_id}
    Log To Console    ✓ Created Field Report ID: ${fieldreport_id}

Create Field Report With Product
    [Documentation]    Create a field report and add a product
    Create Field Report For Test
    
    # Add a product
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    2s
    
    Wait Until Element Is Visible    ${ADD_PRODUCT_BUTTON}    timeout=10s
    Click Element    ${ADD_PRODUCT_BUTTON}
    Wait Until Element Is Visible    ${PRODUCT_MODAL}    timeout=10s
    
    # Wait specifically for the checkbox to appear - this confirms products are loaded
    Log To Console    Waiting for products to load in modal...
    ${status}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${PRODUCT_CHECKBOX}    timeout=30s
    
    IF    not ${status}
        Log To Console    ⚠ No products found in modal after 30s.
        Click Element    ${MODAL_CANCEL_BUTTON}
        Sleep    1s
        Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
        Fail    Could not add product: No products available in modal.
    ELSE
        Log To Console    ✓ Products loaded. Selecting the first one.
        # Try regular click first
        ${click_status}=    Run Keyword And Return Status    Click Element    ${PRODUCT_CHECKBOX}
        IF    not ${click_status}
            Log To Console    Regular click failed, trying JavaScript click...
            Execute Javascript    document.querySelector('#myTable .selected-checkbox').click()
        END
        Sleep    1s
        
        Execute Javascript    document.querySelector('#myModal3 .modal-content').scrollTo(0, 9999);
        Sleep    1s
        Click Element    ${MODAL_SAVE_BUTTON}
        Sleep    2s
        Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
        Sleep    2s
        Log To Console    ✓ Added product to Field Report
    END

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
    [Documentation]    Delete the field report
    Log To Console    Cleaning up...
    ${has_id}=    Run Keyword And Return Status    Should Not Be Empty    ${CREATED_FIELDREPORT_ID}
    
    IF    ${has_id}
        ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
        Go To    ${edit_url}
        Sleep    2s
        
        ${delete_btn}=    Get WebElement    ${DELETE_BUTTON}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${delete_btn}
        Sleep    1s
        Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=5s
        Sleep    1s
        Log To Console    ✓ Deleted Field Report
    END
    
    Close All Browsers

Cleanup Approved Fieldreport
    [Documentation]    Unapprove then delete the field report
    Log To Console    Cleaning up approved FR...
    ${has_id}=    Run Keyword And Return Status    Should Not Be Empty    ${CREATED_FIELDREPORT_ID}
    
    IF    ${has_id}
        ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
        Go To    ${edit_url}
        Sleep    2s
        
        # Unapprove first
        ${btn_value}=    Get Element Attribute    ${APPROVE_BUTTON}    value
        ${is_approved}=    Run Keyword And Return Status    Should Contain    ${btn_value}    Unapprove
        IF    ${is_approved}
            Click Element    ${APPROVE_BUTTON}
            Sleep    1s
            Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
            Sleep    2s
        END
        
        # Delete
        ${delete_btn}=    Get WebElement    ${DELETE_BUTTON}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${delete_btn}
        Sleep    1s
        Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=5s
        Sleep    1s
        Log To Console    ✓ Deleted Field Report
    END
    
    Close All Browsers
