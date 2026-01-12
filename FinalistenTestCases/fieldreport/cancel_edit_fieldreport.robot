*** Settings ***
Documentation    Test suite for verifying Cancel functionality on Field Report edit page.
...              
...              Test Flow:
...              1. Create a new field report (setup)
...              2. Record the original values
...              3. Modify each editable field with new values
...              4. Click Cancel instead of Save
...              5. Accept confirmation dialog
...              6. Verify all fields are reverted to original values
...              7. Delete the field report (teardown)
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
${MESSAGE_TO_APPROVER}            id=id_message_to_approver
${SECURITY_CONTROL_CHECKBOX}      id=id_security_control
${INSTALLER_DROPDOWN}             id=id_installer_name
${SAVE_BUTTON}                    css=button.save
${EDIT_GENERAL_DATA_BUTTON}       id=EditGeneralDataButton
${EDIT_SAVE_BUTTON}               id=fieldreport_general_data_save
# Note: Cancel button uses the SAME ID as Edit button - the button transforms when in edit mode
${EDIT_CANCEL_BUTTON}             id=EditGeneralDataButton
${DELETE_BUTTON}                  id=remove_fieldreport

# Initial Values (for creation)
${INITIAL_TOTAL_HOURS}            5
${INITIAL_MESSAGE}                Original Message - Cancel Test
${INITIAL_WORK_DATE}              2025-10-20

# Modified Values (will be discarded on cancel)
${MODIFIED_TOTAL_HOURS}           99
${MODIFIED_MESSAGE}               THIS SHOULD NOT BE SAVED - Testing Cancel
${MODIFIED_WORK_DATE}             2025-10-01

# Test State Variables
${CREATED_FIELDREPORT_ID}         ${EMPTY}
${ORIGINAL_CUSTOMER}              ${EMPTY}
${ORIGINAL_PROJECT}               ${EMPTY}
${ORIGINAL_SUBPROJECT}            ${EMPTY}
${ORIGINAL_INSTALLER}             ${EMPTY}
${ORIGINAL_WORK_DATE}             ${EMPTY}
${ORIGINAL_TOTAL_HOURS}           ${EMPTY}
${ORIGINAL_MESSAGE}               ${EMPTY}
${ORIGINAL_CHECKBOX_STATE}        ${FALSE}

*** Test Cases ***
Test Cancel Reverts All Field Changes
    [Documentation]    Modify all fields on edit page, click Cancel, and verify all values revert.
    ...                This test ensures that Cancel discards unsaved changes.
    [Tags]    fieldreport    cancel    validation
    [Setup]    Create Field Report For Cancel Test
    
    # Navigate to edit page
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Log To Console    ======== TESTING CANCEL FUNCTIONALITY FOR FIELD REPORT ${CREATED_FIELDREPORT_ID} ========
    
    # ======== RECORD ORIGINAL VALUES ========
    Log To Console    \n--- Recording Original Values ---
    ${orig_customer}=    Get Selected List Label    ${CUSTOMER_DROPDOWN}
    ${orig_project}=    Get Selected List Label    ${PROJECT_DROPDOWN}
    ${orig_subproject}=    Get Selected List Label    ${SUBPROJECT_DROPDOWN}
    ${orig_installer}=    Get Selected List Label    ${INSTALLER_DROPDOWN}
    ${orig_date}=    Get Value    ${WORK_DATE_INPUT}
    ${orig_hours}=    Get Value    ${TOTAL_HOURS_INPUT}
    ${orig_message}=    Get Value    ${MESSAGE_TO_APPROVER}
    ${orig_checkbox}=    Run Keyword And Return Status    Checkbox Should Be Selected    ${SECURITY_CONTROL_CHECKBOX}
    
    Set Suite Variable    ${ORIGINAL_CUSTOMER}    ${orig_customer}
    Set Suite Variable    ${ORIGINAL_PROJECT}    ${orig_project}
    Set Suite Variable    ${ORIGINAL_SUBPROJECT}    ${orig_subproject}
    Set Suite Variable    ${ORIGINAL_INSTALLER}    ${orig_installer}
    Set Suite Variable    ${ORIGINAL_WORK_DATE}    ${orig_date}
    Set Suite Variable    ${ORIGINAL_TOTAL_HOURS}    ${orig_hours}
    Set Suite Variable    ${ORIGINAL_MESSAGE}    ${orig_message}
    Set Suite Variable    ${ORIGINAL_CHECKBOX_STATE}    ${orig_checkbox}
    
    Log To Console    Original Customer: ${orig_customer}
    Log To Console    Original Project: ${orig_project}
    Log To Console    Original SubProject: ${orig_subproject}
    Log To Console    Original Installer: ${orig_installer}
    Log To Console    Original Work Date: ${orig_date}
    Log To Console    Original Total Hours: ${orig_hours}
    Log To Console    Original Message: ${orig_message}
    Log To Console    Original Security Control: ${orig_checkbox}
    
    # ======== CLICK EDIT BUTTON TO ENABLE FIELDS ========
    Log To Console    \n--- Enabling Edit Mode ---
    Wait Until Element Is Visible    ${EDIT_GENERAL_DATA_BUTTON}    timeout=10s
    Click Element    ${EDIT_GENERAL_DATA_BUTTON}
    Sleep    1s
    Log To Console    ✓ Edit mode enabled
    
    # ======== MODIFY ALL FIELDS ========
    Log To Console    \n--- Modifying All Fields (these changes will be cancelled) ---
    
    # Modify Work Date
    Log To Console    Modifying Work Date to: ${MODIFIED_WORK_DATE}
    Clear Element Text    ${WORK_DATE_INPUT}
    Input Text    ${WORK_DATE_INPUT}    ${MODIFIED_WORK_DATE}
    
    # Modify Total Hours
    Log To Console    Modifying Total Hours to: ${MODIFIED_TOTAL_HOURS}
    Clear Element Text    ${TOTAL_HOURS_INPUT}
    Input Text    ${TOTAL_HOURS_INPUT}    ${MODIFIED_TOTAL_HOURS}
    
    # Modify Message
    Log To Console    Modifying Message to: ${MODIFIED_MESSAGE}
    Clear Element Text    ${MESSAGE_TO_APPROVER}
    Input Text    ${MESSAGE_TO_APPROVER}    ${MODIFIED_MESSAGE}
    
    # Toggle Security Control Checkbox
    IF    ${ORIGINAL_CHECKBOX_STATE}
        Unselect Checkbox    ${SECURITY_CONTROL_CHECKBOX}
        Log To Console    Toggling Security Control: CHECKED -> UNCHECKED
    ELSE
        Select Checkbox    ${SECURITY_CONTROL_CHECKBOX}
        Log To Console    Toggling Security Control: UNCHECKED -> CHECKED
    END
    
    # Try to change Customer (if possible)
    ${customer_options}=    Get List Items    ${CUSTOMER_DROPDOWN}
    ${customer_count}=    Get Length    ${customer_options}
    IF    ${customer_count} > 2
        Log To Console    Attempting to change Customer...
        Select From List By Index    ${CUSTOMER_DROPDOWN}    2
        ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
        Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
        Sleep    2s
    END
    
    # Try to change Installer
    ${installer_options}=    Get List Items    ${INSTALLER_DROPDOWN}
    ${installer_count}=    Get Length    ${installer_options}
    IF    ${installer_count} > 2
        Log To Console    Attempting to change Installer...
        Select From List By Index    ${INSTALLER_DROPDOWN}    2
        ${element}=    Get WebElement    ${INSTALLER_DROPDOWN}
        Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    END
    
    Log To Console    ✓ All fields modified (unsaved)
    
    # ======== CLICK CANCEL BUTTON ========
    Log To Console    \n--- Clicking CANCEL Button ---
    Wait Until Element Is Visible    ${EDIT_CANCEL_BUTTON}    timeout=10s
    Click Element    ${EDIT_CANCEL_BUTTON}
    
    # Handle confirmation dialog - the app shows "Are you sure to CANCEL?" alert
    Sleep    1s
    ${alert_present}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=5s
    IF    ${alert_present}
        Log To Console    ✓ Accepted confirmation dialog
    END
    Sleep    2s
    Log To Console    ✓ Cancel button clicked
    
    # ======== VERIFY ALL VALUES REVERTED ========
    Log To Console    \n--- Verifying All Values Reverted to Original ---
    
    # Verify Customer
    ${current_customer}=    Get Selected List Label    ${CUSTOMER_DROPDOWN}
    Should Be Equal    ${current_customer}    ${ORIGINAL_CUSTOMER}    msg=Customer was not reverted after Cancel!
    Log To Console    ✓ Customer reverted: ${current_customer}
    
    # Verify Project
    ${current_project}=    Get Selected List Label    ${PROJECT_DROPDOWN}
    Should Be Equal    ${current_project}    ${ORIGINAL_PROJECT}    msg=Project was not reverted after Cancel!
    Log To Console    ✓ Project reverted: ${current_project}
    
    # Verify SubProject
    ${current_subproject}=    Get Selected List Label    ${SUBPROJECT_DROPDOWN}
    Should Be Equal    ${current_subproject}    ${ORIGINAL_SUBPROJECT}    msg=SubProject was not reverted after Cancel!
    Log To Console    ✓ SubProject reverted: ${current_subproject}
    
    # Verify Work Date
    ${current_date}=    Get Value    ${WORK_DATE_INPUT}
    Should Be Equal    ${current_date}    ${ORIGINAL_WORK_DATE}    msg=Work Date was not reverted after Cancel!
    Log To Console    ✓ Work Date reverted: ${current_date}
    
    # Verify Total Hours
    ${current_hours}=    Get Value    ${TOTAL_HOURS_INPUT}
    Should Be Equal    ${current_hours}    ${ORIGINAL_TOTAL_HOURS}    msg=Total Hours was not reverted after Cancel!
    Log To Console    ✓ Total Hours reverted: ${current_hours}
    
    # Verify Message
    ${current_message}=    Get Value    ${MESSAGE_TO_APPROVER}
    Should Be Equal    ${current_message}    ${ORIGINAL_MESSAGE}    msg=Message was not reverted after Cancel!
    Log To Console    ✓ Message reverted: ${current_message}
    
    # Verify Security Control Checkbox
    ${current_checkbox}=    Run Keyword And Return Status    Checkbox Should Be Selected    ${SECURITY_CONTROL_CHECKBOX}
    Should Be Equal    ${current_checkbox}    ${ORIGINAL_CHECKBOX_STATE}    msg=Security Control was not reverted after Cancel!
    Log To Console    ✓ Security Control reverted: ${current_checkbox}
    
    # Verify Installer
    ${current_installer}=    Get Selected List Label    ${INSTALLER_DROPDOWN}
    Should Be Equal    ${current_installer}    ${ORIGINAL_INSTALLER}    msg=Installer was not reverted after Cancel!
    Log To Console    ✓ Installer reverted: ${current_installer}
    
    Log To Console    \n======== ALL 8 FIELDS VERIFIED - CANCEL WORKS CORRECTLY! ========
    Log To Console    All unsaved changes were discarded as expected.
    
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

Create Field Report For Cancel Test
    [Documentation]    Create a new field report that will be used for the cancel test
    Login To Application
    
    Log To Console    ======== CREATING FIELD REPORT FOR CANCEL TEST ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Select first available customer
    ${customer_name}=    Select First Available Option And Get Text    ${CUSTOMER_DROPDOWN}
    Log To Console    Selected Customer: ${customer_name}
    
    # Wait for project dropdown to load and select first available
    Sleep    2s
    ${project_name}=    Select First Available Option And Get Text    ${PROJECT_DROPDOWN}
    Log To Console    Selected Project: ${project_name}
    
    # Wait for subproject dropdown to load and select first available
    Sleep    2s
    ${subproject_name}=    Select First Available Option And Get Text    ${SUBPROJECT_DROPDOWN}
    Log To Console    Selected SubProject: ${subproject_name}
    
    # Set work date
    Input Text    ${WORK_DATE_INPUT}    ${INITIAL_WORK_DATE}
    Log To Console    Set Work Date: ${INITIAL_WORK_DATE}
    
    # Set total hours
    Input Text    ${TOTAL_HOURS_INPUT}    ${INITIAL_TOTAL_HOURS}
    Log To Console    Set Total Hours: ${INITIAL_TOTAL_HOURS}
    
    # Set message to approver
    Input Text    ${MESSAGE_TO_APPROVER}    ${INITIAL_MESSAGE}
    Log To Console    Set Message: ${INITIAL_MESSAGE}
    
    # Select installer
    ${installer_name}=    Select First Available Option And Get Text    ${INSTALLER_DROPDOWN}
    Log To Console    Selected Installer: ${installer_name}
    
    # Ensure security control is checked
    Select Checkbox    ${SECURITY_CONTROL_CHECKBOX}
    
    # Save the field report
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Log To Console    Clicking Save button...
    Sleep    3s
    
    # Verify we're on the edit page
    ${current_url}=    Get Location
    Should Contain    ${current_url}    /edit/    msg=Failed to create field report
    
    # Extract field report ID from URL
    ${fieldreport_id}=    Extract Fieldreport ID From URL    ${current_url}
    Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${fieldreport_id}
    Log To Console    ✓ Created Field Report ID: ${fieldreport_id}

Select First Available Option And Get Text
    [Documentation]    Select the first non-empty option from a dropdown and return its text
    [Arguments]    ${dropdown_locator}
    ${options}=    Get List Items    ${dropdown_locator}
    ${count}=    Get Length    ${options}
    IF    ${count} > 1
        Select From List By Index    ${dropdown_locator}    1
        # Trigger change event for dynamic dropdowns
        ${element}=    Get WebElement    ${dropdown_locator}
        Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
        ${selected}=    Get Selected List Label    ${dropdown_locator}
        RETURN    ${selected}
    ELSE
        Fail    No options available in dropdown ${dropdown_locator}
    END

Extract Fieldreport ID From URL
    [Documentation]    Extract the fieldreport slug/ID from the edit page URL
    ...                URLs now use alphanumeric slugs like: /fieldreport/list/{SLUG}/edit/
    [Arguments]    ${url}
    ${parts}=    Split String    ${url}    /
    ${num_parts}=    Get Length    ${parts}
    # Look for the slug which is the part before 'edit' in the URL
    FOR    ${i}    ${part}    IN ENUMERATE    @{parts}
        ${next_idx}=    Evaluate    ${i} + 1
        IF    ${next_idx} < ${num_parts}
            ${next_part}=    Evaluate    $parts[${next_idx}]
            IF    '${next_part}' == 'edit'
                RETURN    ${part}
            END
        END
    END
    # Fallback: Try matching alphanumeric slug pattern
    FOR    ${i}    ${part}    IN ENUMERATE    @{parts}
        ${is_slug}=    Run Keyword And Return Status    Should Match Regexp    ${part}    ^[A-Za-z0-9]{5,8}$
        IF    ${is_slug}
            RETURN    ${part}
        END
    END
    Fail    Could not extract fieldreport slug from URL: ${url}

Cleanup Created Fieldreport
    [Documentation]    Delete the created fieldreport to maintain data cleanliness.
    ...                This runs in teardown, so it executes whether test passes or fails.
    Log To Console    ======== CLEANUP: Deleting Field Report ========
    
    # Check if we have a fieldreport ID to delete
    ${has_id}=    Run Keyword And Return Status    Should Not Be Empty    ${CREATED_FIELDREPORT_ID}
    
    IF    ${has_id}
        # Navigate to the edit page if not already there
        ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
        Go To    ${edit_url}
        Sleep    2s
        
        # Check if delete button exists and click it
        ${delete_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${DELETE_BUTTON}    timeout=10s
        
        IF    ${delete_exists}
            Log To Console    Deleting Field Report ID: ${CREATED_FIELDREPORT_ID}
            Click Element    ${DELETE_BUTTON}
            
            # Handle confirmation dialog if present
            Sleep    1s
            Handle Alert    action=ACCEPT    timeout=5s
            
            Sleep    2s
            Log To Console    ✓ Field Report ${CREATED_FIELDREPORT_ID} deleted successfully!
        ELSE
            Log To Console    WARNING: Delete button not found. Manual cleanup may be required for ID: ${CREATED_FIELDREPORT_ID}
        END
    ELSE
        Log To Console    No fieldreport was created or ID not captured. No cleanup needed.
    END
    
    # Always close browser
    Close All Browsers
