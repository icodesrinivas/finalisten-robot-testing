*** Settings ***
Documentation    Test suite for editing a Field Report, modifying all fields, saving, and validating.
...              Tests are run on PRE-PRODUCTION environment: https://preproderp.finalisten.se/
...              IMPORTANT: Created fieldreports are deleted in teardown to maintain data cleanliness.
...              
...              Test Flow:
...              1. Create a new field report (setup)
...              2. Modify each editable field with new values
...              3. Save the changes
...              4. Refresh the page
...              5. Validate all fields contain the modified values
...              6. Delete the field report (teardown)
Library          SeleniumLibrary
Library          DateTime
Library          String
Library          Collections

*** Variables ***
# Pre-Production URLs
${PREPROD_URL}                    https://preproderp.finalisten.se/
${PREPROD_LOGIN_URL}              https://preproderp.finalisten.se/login/
${PREPROD_HOMEPAGE_URL}           https://preproderp.finalisten.se/homepage/
${PREPROD_FIELDREPORT_LIST_URL}   https://preproderp.finalisten.se/fieldreport/list/
${PREPROD_FIELDREPORT_CREATE_URL}    https://preproderp.finalisten.se/fieldreport/create/

# Credentials
${USERNAME}                       erpadmin@finalisten.se
${PASSWORD}                       Djangocrm123

# Browser Settings
${BROWSER}                        chrome
${CHROME_OPTIONS}                 add_argument("--ignore-certificate-errors");add_argument("--disable-web-security");add_argument("--allow-running-insecure-content")

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
${DELETE_BUTTON}                  id=remove_fieldreport

# Initial Values (for creation)
${INITIAL_TOTAL_HOURS}            4
${INITIAL_MESSAGE}                Initial Test Message - Before Edit
${INITIAL_WORK_DATE}              2025-10-31

# Modified Values (for edit test)
${MODIFIED_TOTAL_HOURS}           12
${MODIFIED_MESSAGE}               MODIFIED: Robot Framework Edit Test - Please Delete
${MODIFIED_WORK_DATE}             2025-10-15

# Test State Variables
${CREATED_FIELDREPORT_ID}         ${EMPTY}
${INITIAL_CUSTOMER}               ${EMPTY}
${INITIAL_PROJECT}                ${EMPTY}
${INITIAL_SUBPROJECT}             ${EMPTY}
${INITIAL_INSTALLER}              ${EMPTY}
${MODIFIED_CUSTOMER}              ${EMPTY}
${MODIFIED_PROJECT}               ${EMPTY}
${MODIFIED_SUBPROJECT}            ${EMPTY}
${MODIFIED_INSTALLER}             ${EMPTY}

*** Test Cases ***
Test Edit Field Report And Verify Modified Values
    [Documentation]    Create a field report, then edit all fields, save, refresh, and verify changes.
    ...                This test ensures that all field modifications are properly persisted.
    [Tags]    fieldreport    edit    validation    preprod
    [Setup]    Create Field Report For Editing
    
    # Navigate to edit page
    ${edit_url}=    Set Variable    ${PREPROD_FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Log To Console    ======== EDITING FIELD REPORT ${CREATED_FIELDREPORT_ID} ========
    
    # Record initial values for comparison
    ${initial_customer}=    Get Selected List Label    ${CUSTOMER_DROPDOWN}
    ${initial_project}=    Get Selected List Label    ${PROJECT_DROPDOWN}
    ${initial_subproject}=    Get Selected List Label    ${SUBPROJECT_DROPDOWN}
    ${initial_installer}=    Get Selected List Label    ${INSTALLER_DROPDOWN}
    Log To Console    Initial Customer: ${initial_customer}
    Log To Console    Initial Project: ${initial_project}
    Log To Console    Initial SubProject: ${initial_subproject}
    Log To Console    Initial Installer: ${initial_installer}
    
    # ======== CLICK EDIT BUTTON TO ENABLE FIELDS ========
    # NOTE: Fields are READ-ONLY by default on edit page. Must click Edit button first!
    Log To Console    Clicking Edit button to enable form fields...
    Wait Until Element Is Visible    ${EDIT_GENERAL_DATA_BUTTON}    timeout=10s
    Click Element    ${EDIT_GENERAL_DATA_BUTTON}
    Sleep    1s    # Wait for fields to become editable
    Log To Console    ✓ Edit mode enabled
    
    # ======== MODIFY FIELD 1: Work Date ========
    Log To Console    Modifying Work Date to: ${MODIFIED_WORK_DATE}
    Clear Element Text    ${WORK_DATE_INPUT}
    Input Text    ${WORK_DATE_INPUT}    ${MODIFIED_WORK_DATE}
    
    # ======== MODIFY FIELD 2: Total Hours ========
    Log To Console    Modifying Total Hours to: ${MODIFIED_TOTAL_HOURS}
    Clear Element Text    ${TOTAL_HOURS_INPUT}
    Input Text    ${TOTAL_HOURS_INPUT}    ${MODIFIED_TOTAL_HOURS}
    
    # ======== MODIFY FIELD 3: Message to Approver ========
    Log To Console    Modifying Message to: ${MODIFIED_MESSAGE}
    Clear Element Text    ${MESSAGE_TO_APPROVER}
    Input Text    ${MESSAGE_TO_APPROVER}    ${MODIFIED_MESSAGE}
    
    # ======== MODIFY FIELD 4: Security Control Checkbox ========
    # Get current state and toggle it
    ${checkbox_selected}=    Run Keyword And Return Status    Checkbox Should Be Selected    ${SECURITY_CONTROL_CHECKBOX}
    IF    ${checkbox_selected}
        Unselect Checkbox    ${SECURITY_CONTROL_CHECKBOX}
        Log To Console    Toggling Security Control: CHECKED -> UNCHECKED
        Set Suite Variable    ${EXPECTED_CHECKBOX_STATE}    ${FALSE}
    ELSE
        Select Checkbox    ${SECURITY_CONTROL_CHECKBOX}
        Log To Console    Toggling Security Control: UNCHECKED -> CHECKED
        Set Suite Variable    ${EXPECTED_CHECKBOX_STATE}    ${TRUE}
    END
    
    # ======== MODIFY FIELD 5: Customer (changes Project and SubProject too) ========
    ${new_customer}=    Select Different Option From Dropdown    ${CUSTOMER_DROPDOWN}    ${initial_customer}
    Set Suite Variable    ${MODIFIED_CUSTOMER}    ${new_customer}
    Log To Console    Modifying Customer to: ${new_customer}
    Sleep    2s    # Wait for Projects to load
    
    # ======== MODIFY FIELD 6: Project ========
    ${new_project}=    Select First Available Option And Get Text    ${PROJECT_DROPDOWN}
    Set Suite Variable    ${MODIFIED_PROJECT}    ${new_project}
    Log To Console    Modifying Project to: ${new_project}
    Sleep    2s    # Wait for SubProjects to load
    
    # ======== MODIFY FIELD 7: SubProject ========
    ${new_subproject}=    Select First Available Option And Get Text    ${SUBPROJECT_DROPDOWN}
    Set Suite Variable    ${MODIFIED_SUBPROJECT}    ${new_subproject}
    Log To Console    Modifying SubProject to: ${new_subproject}
    
    # ======== MODIFY FIELD 8: Installer ========
    ${new_installer}=    Select Different Option From Dropdown    ${INSTALLER_DROPDOWN}    ${initial_installer}
    Set Suite Variable    ${MODIFIED_INSTALLER}    ${new_installer}
    Log To Console    Modifying Installer to: ${new_installer}
    
    # ======== SAVE THE CHANGES ========
    Log To Console    ======== SAVING CHANGES ========
    # Use the specific edit form save button
    Wait Until Element Is Visible    ${EDIT_SAVE_BUTTON}    timeout=10s
    ${save_btn}=    Get WebElement    ${EDIT_SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    3s
    
    # Verify we're still on edit page (save was successful)
    ${current_url}=    Get Location
    Should Contain    ${current_url}    /edit/    msg=Failed to save - not on edit page
    Log To Console    Save completed successfully.
    
    # ======== REFRESH THE PAGE ========
    Log To Console    ======== REFRESHING PAGE TO VALIDATE PERSISTENCE ========
    Reload Page
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Sleep    2s    # Wait for page to fully load
    
    # ======== VALIDATE ALL MODIFIED FIELDS ========
    Log To Console    ======== VALIDATING MODIFIED VALUES ========
    
    # Validate Work Date
    ${stored_date}=    Get Value    ${WORK_DATE_INPUT}
    Should Be Equal    ${stored_date}    ${MODIFIED_WORK_DATE}    msg=Work Date was not saved correctly!
    Log To Console    ✓ Work Date verified: ${stored_date}
    
    # Validate Total Hours (handle Swedish format)
    ${stored_hours}=    Get Value    ${TOTAL_HOURS_INPUT}
    ${hours_match}=    Run Keyword And Return Status    Should Start With    ${stored_hours}    ${MODIFIED_TOTAL_HOURS}
    IF    not ${hours_match}
        ${normalized_stored}=    Replace String    ${stored_hours}    ,    .
        ${stored_num}=    Convert To Number    ${normalized_stored}
        ${expected_num}=    Convert To Number    ${MODIFIED_TOTAL_HOURS}
        Should Be Equal As Numbers    ${stored_num}    ${expected_num}    msg=Total Hours was not saved correctly!
    END
    Log To Console    ✓ Total Hours verified: ${stored_hours}
    
    # Validate Message to Approver
    ${stored_message}=    Get Value    ${MESSAGE_TO_APPROVER}
    Should Be Equal    ${stored_message}    ${MODIFIED_MESSAGE}    msg=Message was not saved correctly!
    Log To Console    ✓ Message verified: ${stored_message}
    
    # Validate Security Control Checkbox
    IF    ${EXPECTED_CHECKBOX_STATE}
        Checkbox Should Be Selected    ${SECURITY_CONTROL_CHECKBOX}
        Log To Console    ✓ Security Control verified: CHECKED
    ELSE
        Checkbox Should Not Be Selected    ${SECURITY_CONTROL_CHECKBOX}
        Log To Console    ✓ Security Control verified: UNCHECKED
    END
    
    # Validate Customer
    ${stored_customer}=    Get Selected List Label    ${CUSTOMER_DROPDOWN}
    Should Be Equal    ${stored_customer}    ${MODIFIED_CUSTOMER}    msg=Customer was not saved correctly!
    Log To Console    ✓ Customer verified: ${stored_customer}
    
    # Validate Project
    ${stored_project}=    Get Selected List Label    ${PROJECT_DROPDOWN}
    Should Be Equal    ${stored_project}    ${MODIFIED_PROJECT}    msg=Project was not saved correctly!
    Log To Console    ✓ Project verified: ${stored_project}
    
    # Validate SubProject
    ${stored_subproject}=    Get Selected List Label    ${SUBPROJECT_DROPDOWN}
    Should Be Equal    ${stored_subproject}    ${MODIFIED_SUBPROJECT}    msg=SubProject was not saved correctly!
    Log To Console    ✓ SubProject verified: ${stored_subproject}
    
    # Validate Installer
    ${stored_installer}=    Get Selected List Label    ${INSTALLER_DROPDOWN}
    Should Be Equal    ${stored_installer}    ${MODIFIED_INSTALLER}    msg=Installer was not saved correctly!
    Log To Console    ✓ Installer verified: ${stored_installer}
    
    Log To Console    ======== ALL 8 FIELDS VERIFIED SUCCESSFULLY! ========
    Log To Console    Field Report ${CREATED_FIELDREPORT_ID} edited and validated successfully.
    
    [Teardown]    Cleanup Created Fieldreport

*** Keywords ***
Login To PreProd
    [Documentation]    Open browser and login to pre-production environment
    Open Browser    ${PREPROD_LOGIN_URL}    ${BROWSER}    options=${CHROME_OPTIONS}
    Maximize Browser Window
    Wait Until Page Contains Element    xpath=//input[@name='username']    timeout=10s
    Input Text    xpath=//input[@name='username']    ${USERNAME}
    Input Text    xpath=//input[@name='password']    ${PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Contains    ${PREPROD_HOMEPAGE_URL}    timeout=15s
    Log To Console    Successfully logged in to PreProd

Create Field Report For Editing
    [Documentation]    Create a new field report that will be used for the edit test
    Login To PreProd
    
    Log To Console    ======== CREATING FIELD REPORT FOR EDIT TEST ========
    Go To    ${PREPROD_FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Select first available customer
    ${customer_name}=    Select First Available Option And Get Text    ${CUSTOMER_DROPDOWN}
    Set Suite Variable    ${INITIAL_CUSTOMER}    ${customer_name}
    Log To Console    Selected Customer: ${customer_name}
    
    # Wait for project dropdown to load and select first available
    Sleep    2s
    ${project_name}=    Select First Available Option And Get Text    ${PROJECT_DROPDOWN}
    Set Suite Variable    ${INITIAL_PROJECT}    ${project_name}
    Log To Console    Selected Project: ${project_name}
    
    # Wait for subproject dropdown to load and select first available
    Sleep    2s
    ${subproject_name}=    Select First Available Option And Get Text    ${SUBPROJECT_DROPDOWN}
    Set Suite Variable    ${INITIAL_SUBPROJECT}    ${subproject_name}
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
    Set Suite Variable    ${INITIAL_INSTALLER}    ${installer_name}
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

Select Different Option From Dropdown
    [Documentation]    Select a different option from the dropdown (not the current one)
    [Arguments]    ${dropdown_locator}    ${current_value}
    ${options}=    Get List Items    ${dropdown_locator}
    ${count}=    Get Length    ${options}
    
    # Find an option that's different from current
    FOR    ${i}    IN RANGE    1    ${count}
        ${option_text}=    Set Variable    ${options}[${i}]
        IF    '${option_text}' != '${current_value}'
            Select From List By Index    ${dropdown_locator}    ${i}
            # Trigger change event for dynamic dropdowns
            ${element}=    Get WebElement    ${dropdown_locator}
            Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
            ${selected}=    Get Selected List Label    ${dropdown_locator}
            RETURN    ${selected}
        END
    END
    
    # If no different option found, just select index 1
    Select From List By Index    ${dropdown_locator}    1
    ${element}=    Get WebElement    ${dropdown_locator}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    ${selected}=    Get Selected List Label    ${dropdown_locator}
    RETURN    ${selected}

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
        ${edit_url}=    Set Variable    ${PREPROD_FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
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
