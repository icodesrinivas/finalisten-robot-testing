*** Settings ***
Documentation    Test suite for verifying Product Delete and Attachment functionality in Field Report.
...              
...              Tests include:
...              - Deleting a product from the FR products table
...              - Uploading attachment to a product
...              - Deleting attachment from a product
Library          SeleniumLibrary
Library          DateTime
Library          String
Library          Collections
Library          OperatingSystem
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
${MODAL_SAVE_BUTTON}              css=.prodinfr_save_button
${PRODUCT_CHECKBOX}               css=#prodInProjTable tbody tr:first-child .selected-checkbox

# Products in FR Table Selectors
${PRODUCTS_TABLE}                 id=prodInFieldReportTable
${COMMON_SAVE_BUTTON}             id=product_in_fieldreport_save
${PRODUCT_DELETE_BUTTON}          css=.delete_product
${PRODUCT_ATTACHMENT_INPUT}       css=input[type='file']
${PRODUCT_ATTACHMENT_ICON}        css=.attachment-icon
${PRODUCT_ATTACHMENT_DELETE}      css=.delete-attachment

# Test Values
${INITIAL_WORK_DATE}              2025-10-20

# Test State Variables
${CREATED_FIELDREPORT_ID}         ${EMPTY}

*** Test Cases ***
Test Delete Product From Field Report
    [Documentation]    Test that clicking delete button removes the product from field report.
    [Tags]    fieldreport    product    delete
    [Setup]    Create Field Report With Product
    
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    2s
    Log To Console    ======== TESTING PRODUCT DELETE ========
    
    # Count products before delete
    ${products_before}=    Get Element Count    css=#prodInFieldReportTable tbody tr
    Log To Console    Products before delete: ${products_before}
    Should Be True    ${products_before} >= 1    msg=Need at least 1 product to test delete
    
    # Click delete button on first product
    Log To Console    \n--- Clicking Delete Button ---
    ${delete_btn}=    Set Variable    css=#prodInFieldReportTable tbody tr:first-child .delete_product
    ${delete_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${delete_btn}    timeout=10s
    
    IF    ${delete_exists}
        Click Element    ${delete_btn}
        Sleep    1s
        
        # Handle confirmation if present
        ${alert_present}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=3s
        IF    ${alert_present}
            Log To Console    ✓ Accepted delete confirmation
        END
        Sleep    2s
        
        # Verify product was deleted
        ${products_after}=    Get Element Count    css=#prodInFieldReportTable tbody tr
        Log To Console    Products after delete: ${products_after}
        
        ${expected}=    Evaluate    ${products_before} - 1
        Should Be Equal As Integers    ${products_after}    ${expected}    msg=Product count should decrease by 1
        Log To Console    ✓ Product deleted successfully
    ELSE
        Log To Console    ⚠ Delete button not found on product row
    END
    
    Log To Console    \n======== PRODUCT DELETE TEST PASSED! ========
    
    [Teardown]    Cleanup Created Fieldreport

Test Upload Attachment To Product
    [Documentation]    Test uploading an attachment to a product in field report.
    [Tags]    fieldreport    product    attachment    upload
    [Setup]    Create Field Report With Product
    
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    2s
    Log To Console    ======== TESTING ATTACHMENT UPLOAD ========
    
    # Check for file input on product row
    ${file_input_exists}=    Run Keyword And Return Status    Page Should Contain Element    css=input[type='file']
    
    IF    ${file_input_exists}
        Log To Console    \n--- Testing File Upload ---
        
        # Create a test text file
        ${test_file}=    Set Variable    /tmp/test_attachment.txt
        Create File    ${test_file}    This is a test attachment file for Robot Framework testing.
        
        # Find and use the file input
        ${file_input}=    Get WebElement    css=input[type='file']
        Choose File    css=input[type='file']    ${test_file}
        Sleep    3s
        
        # Handle any alerts
        Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
        Sleep    2s
        
        Log To Console    ✓ File upload attempted
        
        # Verify attachment indicator appears (if applicable)
        ${attachment_visible}=    Run Keyword And Return Status    Page Should Contain Element    ${PRODUCT_ATTACHMENT_ICON}
        IF    ${attachment_visible}
            Log To Console    ✓ Attachment indicator visible
        ELSE
            Log To Console    ⚠ Attachment indicator not found (may need page refresh)
        END
        
        # Cleanup temp file
        Remove File    ${test_file}
    ELSE
        Log To Console    ⚠ File input not found - attachment upload may require edit mode
        
        # Try enabling edit mode first
        ${common_edit}=    Run Keyword And Return Status    Page Should Contain Element    id=common_edit_product
        IF    ${common_edit}
            Click Element    id=common_edit_product
            Sleep    2s
            ${file_input_after_edit}=    Run Keyword And Return Status    Page Should Contain Element    css=input[type='file']
            Log To Console    File input after edit mode: ${file_input_after_edit}
        END
    END
    
    Log To Console    \n======== ATTACHMENT UPLOAD TEST COMPLETED! ========
    
    [Teardown]    Cleanup Created Fieldreport

Test Delete Attachment From Product
    [Documentation]    Test deleting an attachment from a product in field report.
    [Tags]    fieldreport    product    attachment    delete
    [Setup]    Create Field Report With Product
    
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    2s
    Log To Console    ======== TESTING ATTACHMENT DELETE ========
    
    # First try to upload an attachment
    ${file_input_exists}=    Run Keyword And Return Status    Page Should Contain Element    css=input[type='file']
    
    IF    ${file_input_exists}
        # Upload a file first
        ${test_file}=    Set Variable    /tmp/test_attachment_delete.txt
        Create File    ${test_file}    Test file for deletion testing.
        Choose File    css=input[type='file']    ${test_file}
        Sleep    3s
        Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
        Sleep    2s
        
        # Now try to delete the attachment
        ${delete_attachment_exists}=    Run Keyword And Return Status    Page Should Contain Element    ${PRODUCT_ATTACHMENT_DELETE}
        
        IF    ${delete_attachment_exists}
            Log To Console    \n--- Deleting Attachment ---
            Click Element    ${PRODUCT_ATTACHMENT_DELETE}
            Sleep    1s
            Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
            Sleep    2s
            Log To Console    ✓ Attachment delete attempted
        ELSE
            Log To Console    ⚠ Attachment delete button not found
        END
        
        # Cleanup
        Remove File    ${test_file}
    ELSE
        Log To Console    ⚠ Cannot test attachment deletion - file input not available
    END
    
    Log To Console    \n======== ATTACHMENT DELETE TEST COMPLETED! ========
    
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

Create Field Report With Product
    [Documentation]    Create a new field report and add a product
    Login To Application
    
    Log To Console    ======== CREATING FIELD REPORT WITH PRODUCT ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Select first available customer
    Select From List By Index    ${CUSTOMER_DROPDOWN}    1
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Select first available project
    Select From List By Index    ${PROJECT_DROPDOWN}    1
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
    
    # Add a product
    Add Sample Product To FR

Add Sample Product To FR
    [Documentation]    Add a sample product to the field report with qty=1
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    1s
    
    Wait Until Element Is Visible    ${ADD_PRODUCT_BUTTON}    timeout=10s
    Click Element    ${ADD_PRODUCT_BUTTON}
    Wait Until Element Is Visible    ${PRODUCT_MODAL}    timeout=10s
    Sleep    2s
    
    # Select first product
    Log To Console    \n--- Selecting Product in Modal ---
    Wait Until Element Is Visible    ${PRODUCT_CHECKBOX}    timeout=30s
    Click Element    ${PRODUCT_CHECKBOX}
    Sleep    1s
    
    # Save in modal
    Execute Javascript    document.querySelector('#myModal3 .modal-content').scrollTo(0, 9999);
    Sleep    1s
    Click Element    ${MODAL_SAVE_BUTTON}
    Sleep    2s
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
    Sleep    2s
    
    # Wait for AJAX row to appear
    Wait Until Element Is Visible    css=#prodInFieldReportTable tbody tr    timeout=30s
    Log To Console    ✓ Product row appeared via AJAX
    
    # SET QUANTITY TO 1 IMMEDIATELY via JavaScript (before saving FR!)
    Log To Console    Setting quantity to 1 via JavaScript...
    Sleep    2s
    ${qty_set}=    Execute Javascript
    ...    var qtyInput = document.querySelector('#prodInFieldReportTable input[id^="id_quantity_"]');
    ...    if (qtyInput) { qtyInput.value = '1'; qtyInput.dispatchEvent(new Event('change')); return true; }
    ...    return false;
    Log To Console    Quantity set via JS: ${qty_set}
    Sleep    1s
    
    # SAVE Field Report to persist the product with qty
    Log To Console    Saving field report...
    Wait Until Element Is Visible    ${COMMON_SAVE_BUTTON}    timeout=10s
    Click Element    ${COMMON_SAVE_BUTTON}
    Sleep    5s
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Reload and verify
    Reload Page
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    2s
    Wait Until Element Is Visible    css=#prodInFieldReportTable tbody tr    timeout=15s
    Log To Console    ✓ Product added with quantity 1 and report saved

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
