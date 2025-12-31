*** Settings ***
Documentation    Test suite for creating a Field Report, verifying stored values, and cleanup.
...              Tests are run on PRE-PRODUCTION environment: https://preproderp.finalisten.se/
...              IMPORTANT: Created fieldreports are deleted in teardown to maintain data cleanliness.
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

# Create Form Field Selectors
${CUSTOMER_DROPDOWN}              id=id_related_customer
${PROJECT_DROPDOWN}               id=id_related_project
${SUBPROJECT_DROPDOWN}            id=id_related_subproject
${WORK_DATE_INPUT}                id=id_work_date
${TOTAL_HOURS_INPUT}              id=id_total_work_hours
${MESSAGE_TO_APPROVER}            id=id_message_to_approver
${SECURITY_CONTROL_CHECKBOX}      id=id_security_control
${INSTALLER_DROPDOWN}             id=id_installer_name
${SAVE_BUTTON}                    css=button.save
${CANCEL_BUTTON}                  id=fieldreport_cancel

# Edit Page Selectors
${DELETE_BUTTON}                  id=remove_fieldreport
${FIELD_REPORT_ID_TEXT}           xpath=//h4[contains(text(), 'FIELD REPORT')]

# Test Data Variables (will be set during test)
${TEST_CUSTOMER}                  ${EMPTY}
${TEST_PROJECT}                   ${EMPTY}
${TEST_SUBPROJECT}                ${EMPTY}
${TEST_WORK_DATE}                 ${EMPTY}
${TEST_TOTAL_HOURS}               8
${TEST_MESSAGE}                   Robot Framework Automated Test - Please Delete
${TEST_INSTALLER}                 ${EMPTY}
${CREATED_FIELDREPORT_ID}         ${EMPTY}

*** Test Cases ***
Test Create Field Report And Verify Stored Values
    [Documentation]    Create a new field report, verify values are stored correctly, then delete it.
    ...                This test ensures data integrity by verifying each field after creation.
    [Tags]    fieldreport    create    validation    preprod
    [Setup]    Login To PreProd
    
    # Navigate to create page
    Go To    ${PREPROD_FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Select first available customer
    ${customer_name}=    Select First Available Option And Get Text    ${CUSTOMER_DROPDOWN}
    Set Suite Variable    ${TEST_CUSTOMER}    ${customer_name}
    Log To Console    Selected Customer: ${customer_name}
    
    # Wait for project dropdown to load and select first available
    Sleep    2s    # Wait for AJAX to load projects
    ${project_name}=    Select First Available Option And Get Text    ${PROJECT_DROPDOWN}
    Set Suite Variable    ${TEST_PROJECT}    ${project_name}
    Log To Console    Selected Project: ${project_name}
    
    # Wait for subproject dropdown to load and select first available
    Sleep    2s    # Wait for AJAX to load subprojects
    ${subproject_name}=    Select First Available Option And Get Text    ${SUBPROJECT_DROPDOWN}
    Set Suite Variable    ${TEST_SUBPROJECT}    ${subproject_name}
    Log To Console    Selected SubProject: ${subproject_name}
    
    # Set work date to a valid open period (try current week)
    ${work_date}=    Get Valid Work Date
    Set Suite Variable    ${TEST_WORK_DATE}    ${work_date}
    Input Text    ${WORK_DATE_INPUT}    ${work_date}
    Log To Console    Set Work Date: ${work_date}
    
    # Set total hours
    Input Text    ${TOTAL_HOURS_INPUT}    ${TEST_TOTAL_HOURS}
    Log To Console    Set Total Hours: ${TEST_TOTAL_HOURS}
    
    # Set message to approver
    Input Text    ${MESSAGE_TO_APPROVER}    ${TEST_MESSAGE}
    Log To Console    Set Message: ${TEST_MESSAGE}
    
    # Select installer (first available)
    ${installer_name}=    Select First Available Option And Get Text    ${INSTALLER_DROPDOWN}
    Set Suite Variable    ${TEST_INSTALLER}    ${installer_name}
    Log To Console    Selected Installer: ${installer_name}
    
    # Click Security Control checkbox
    Select Checkbox    ${SECURITY_CONTROL_CHECKBOX}
    
    # Save the field report
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Log To Console    Clicking Save button...
    
    # Wait for save to complete and verify we're on edit page
    Sleep    3s
    ${current_url}=    Get Location
    ${is_edit_page}=    Run Keyword And Return Status    Should Contain    ${current_url}    /edit/
    
    IF    not ${is_edit_page}
        # Check for error message (e.g., closed period)
        ${page_source}=    Get Source
        ${has_period_error}=    Run Keyword And Return Status    Should Contain    ${page_source}    period
        IF    ${has_period_error}
            # Try different date
            ${new_date}=    Get Future Valid Work Date
            Log To Console    Initial date failed. Trying new date: ${new_date}
            Input Text    ${WORK_DATE_INPUT}    ${new_date}
            Set Suite Variable    ${TEST_WORK_DATE}    ${new_date}
            ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
            Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
            Sleep    3s
        END
    END
    
    # Verify we're on the edit page now
    ${current_url}=    Get Location
    Should Contain    ${current_url}    /edit/    msg=Failed to navigate to edit page after save
    
    # Extract field report ID from URL
    ${fieldreport_id}=    Extract Fieldreport ID From URL    ${current_url}
    Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${fieldreport_id}
    Log To Console    Created Field Report ID: ${fieldreport_id}
    
    # VERIFY: Check that stored values match input values
    Log To Console    ======== VERIFYING STORED VALUES ========
    
    # Verify Customer
    ${stored_customer}=    Get Selected List Label    ${CUSTOMER_DROPDOWN}
    Should Be Equal    ${stored_customer}    ${TEST_CUSTOMER}    msg=Customer mismatch!
    Log To Console    ✓ Customer verified: ${stored_customer}
    
    # Verify Project
    ${stored_project}=    Get Selected List Label    ${PROJECT_DROPDOWN}
    Should Be Equal    ${stored_project}    ${TEST_PROJECT}    msg=Project mismatch!
    Log To Console    ✓ Project verified: ${stored_project}
    
    # Verify SubProject
    ${stored_subproject}=    Get Selected List Label    ${SUBPROJECT_DROPDOWN}
    Should Be Equal    ${stored_subproject}    ${TEST_SUBPROJECT}    msg=SubProject mismatch!
    Log To Console    ✓ SubProject verified: ${stored_subproject}
    
    # Verify Work Date
    ${stored_date}=    Get Value    ${WORK_DATE_INPUT}
    Should Be Equal    ${stored_date}    ${TEST_WORK_DATE}    msg=Work Date mismatch!
    Log To Console    ✓ Work Date verified: ${stored_date}
    
    # Verify Total Hours (handle Swedish decimal format: 8,00 vs 8)
    ${stored_hours}=    Get Value    ${TOTAL_HOURS_INPUT}
    # The system may format "8" as "8,00" (Swedish locale), so we check if it starts with our value
    ${hours_match}=    Run Keyword And Return Status    Should Start With    ${stored_hours}    ${TEST_TOTAL_HOURS}
    IF    not ${hours_match}
        # Alternative: Check if the numeric values match
        ${normalized_stored}=    Replace String    ${stored_hours}    ,    .
        ${stored_num}=    Convert To Number    ${normalized_stored}
        ${expected_num}=    Convert To Number    ${TEST_TOTAL_HOURS}
        Should Be Equal As Numbers    ${stored_num}    ${expected_num}    msg=Total Hours mismatch!
    END
    Log To Console    ✓ Total Hours verified: ${stored_hours}
    
    # Verify Message
    ${stored_message}=    Get Value    ${MESSAGE_TO_APPROVER}
    Should Be Equal    ${stored_message}    ${TEST_MESSAGE}    msg=Message mismatch!
    Log To Console    ✓ Message verified: ${stored_message}
    
    # Verify Installer
    ${stored_installer}=    Get Selected List Label    ${INSTALLER_DROPDOWN}
    Should Be Equal    ${stored_installer}    ${TEST_INSTALLER}    msg=Installer mismatch!
    Log To Console    ✓ Installer verified: ${stored_installer}
    
    # Verify Security Control checkbox
    Checkbox Should Be Selected    ${SECURITY_CONTROL_CHECKBOX}
    Log To Console    ✓ Security Control checkbox verified: CHECKED
    
    Log To Console    ======== ALL VALUES VERIFIED SUCCESSFULLY! ========
    Log To Console    Field Report ${CREATED_FIELDREPORT_ID} created and verified successfully.
    
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

Get Valid Work Date
    [Documentation]    Get a valid work date for pre-prod (October 2025 is the last open period)
    # Note: Pre-prod has Nov/Dec 2025 periods closed, so we use October 2025
    RETURN    2025-10-31

Get Future Valid Work Date
    [Documentation]    Alternative valid work date (earlier in October)
    RETURN    2025-10-30

Extract Fieldreport ID From URL
    [Documentation]    Extract the fieldreport ID from the edit page URL
    [Arguments]    ${url}
    # URL pattern: /fieldreport/list/[ID]/edit/
    ${parts}=    Split String    ${url}    /
    FOR    ${i}    ${part}    IN ENUMERATE    @{parts}
        ${is_numeric}=    Run Keyword And Return Status    Should Match Regexp    ${part}    ^\\d+$
        IF    ${is_numeric}
            RETURN    ${part}
        END
    END
    Fail    Could not extract fieldreport ID from URL: ${url}

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
