*** Settings ***
Documentation    Test suite for verifying Close button and reopening Field Report.
...              
...              Test Flow:
...              1. Create a new field report (setup)
...              2. Record the field report values
...              3. Click Close button and verify we return to list
...              4. Reopen the same field report from list
...              5. Verify all values are still intact
...              6. Delete the field report (teardown)
Library          SeleniumLibrary
Library          DateTime
Library          String
Library          Collections
Resource         ../keywords/LoginKeyword.robot

*** Variables ***
# Form Field Selectors
${CUSTOMER_DROPDOWN}              id=id_related_customer
${PROJECT_DROPDOWN}               id=id_related_project
${SUBPROJECT_DROPDOWN}            id=id_related_subproject
${WORK_DATE_INPUT}                id=id_work_date
${TOTAL_HOURS_INPUT}              id=id_total_work_hours
${MESSAGE_TO_APPROVER}            id=id_message_to_approver
${INSTALLER_DROPDOWN}             id=id_installer_name
${SAVE_BUTTON}                    css=button.save

# Action Buttons
${CLOSE_BUTTON}                   id=fieldreport_cancel

# Initial Values (for creation)
${INITIAL_WORK_DATE}              2025-10-20
${INITIAL_TOTAL_HOURS}            6
${INITIAL_MESSAGE}                Close Button Test Message

# Test State Variables
${CREATED_FIELDREPORT_ID}         ${EMPTY}
${ORIGINAL_CUSTOMER}              ${EMPTY}
${ORIGINAL_PROJECT}               ${EMPTY}
${ORIGINAL_SUBPROJECT}            ${EMPTY}
${ORIGINAL_WORK_DATE}             ${EMPTY}
${ORIGINAL_TOTAL_HOURS}           ${EMPTY}
${ORIGINAL_MESSAGE}               ${EMPTY}

*** Test Cases ***
Test Close Button And Reopen Field Report
    [Documentation]    Test that Close button navigates to list and field report can be reopened.
    ...                Verify all values are intact after reopening.
    [Tags]    fieldreport    close    navigation    validation
    [Setup]    Create Field Report For Close Test
    
    # Navigate to edit page
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${CLOSE_BUTTON}    timeout=15s
    Log To Console    ======== TESTING CLOSE BUTTON FOR FIELD REPORT ${CREATED_FIELDREPORT_ID} ========
    
    # ======== RECORD VALUES BEFORE CLOSING ========
    Log To Console    \n--- Recording Values Before Close ---
    ${orig_customer}=    Get Selected List Label    ${CUSTOMER_DROPDOWN}
    ${orig_project}=    Get Selected List Label    ${PROJECT_DROPDOWN}
    ${orig_subproject}=    Get Selected List Label    ${SUBPROJECT_DROPDOWN}
    ${orig_date}=    Get Value    ${WORK_DATE_INPUT}
    ${orig_hours}=    Get Value    ${TOTAL_HOURS_INPUT}
    ${orig_message}=    Get Value    ${MESSAGE_TO_APPROVER}
    
    Set Suite Variable    ${ORIGINAL_CUSTOMER}    ${orig_customer}
    Set Suite Variable    ${ORIGINAL_PROJECT}    ${orig_project}
    Set Suite Variable    ${ORIGINAL_SUBPROJECT}    ${orig_subproject}
    Set Suite Variable    ${ORIGINAL_WORK_DATE}    ${orig_date}
    Set Suite Variable    ${ORIGINAL_TOTAL_HOURS}    ${orig_hours}
    Set Suite Variable    ${ORIGINAL_MESSAGE}    ${orig_message}
    
    Log To Console    Customer: ${orig_customer}
    Log To Console    Project: ${orig_project}
    Log To Console    Work Date: ${orig_date}
    Log To Console    Total Hours: ${orig_hours}
    
    # ======== CLICK CLOSE BUTTON ========
    Log To Console    \n--- Clicking CLOSE Button ---
    Click Element    ${CLOSE_BUTTON}
    Sleep    2s
    
    # Handle confirmation alert if present
    ${alert_present}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=3s
    IF    ${alert_present}
        Log To Console    ✓ Accepted confirmation dialog
    END
    Sleep    2s
    
    # ======== VERIFY NAVIGATED TO LIST PAGE ========
    ${current_url}=    Get Location
    Should Contain    ${current_url}    /fieldreport/list/    msg=Should navigate to field report list page
    Should Not Contain    ${current_url}    /edit/    msg=Should not be on edit page anymore
    Log To Console    ✓ Navigated to list page: ${current_url}
    
    # ======== REOPEN THE SAME FIELD REPORT ========
    Log To Console    \n--- Reopening Field Report ${CREATED_FIELDREPORT_ID} ---
    ${reopen_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${reopen_url}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Log To Console    ✓ Field Report reopened successfully
    
    # ======== VERIFY ALL VALUES ARE INTACT ========
    Log To Console    \n--- Verifying All Values Are Intact ---
    
    ${check_customer}=    Get Selected List Label    ${CUSTOMER_DROPDOWN}
    Should Be Equal    ${check_customer}    ${ORIGINAL_CUSTOMER}    msg=Customer should be intact!
    Log To Console    ✓ Customer intact: ${check_customer}
    
    ${check_project}=    Get Selected List Label    ${PROJECT_DROPDOWN}
    Should Be Equal    ${check_project}    ${ORIGINAL_PROJECT}    msg=Project should be intact!
    Log To Console    ✓ Project intact: ${check_project}
    
    ${check_subproject}=    Get Selected List Label    ${SUBPROJECT_DROPDOWN}
    Should Be Equal    ${check_subproject}    ${ORIGINAL_SUBPROJECT}    msg=SubProject should be intact!
    Log To Console    ✓ SubProject intact: ${check_subproject}
    
    ${check_date}=    Get Value    ${WORK_DATE_INPUT}
    Should Be Equal    ${check_date}    ${ORIGINAL_WORK_DATE}    msg=Work Date should be intact!
    Log To Console    ✓ Work Date intact: ${check_date}
    
    ${check_hours}=    Get Value    ${TOTAL_HOURS_INPUT}
    Should Be Equal    ${check_hours}    ${ORIGINAL_TOTAL_HOURS}    msg=Total Hours should be intact!
    Log To Console    ✓ Total Hours intact: ${check_hours}
    
    ${check_message}=    Get Value    ${MESSAGE_TO_APPROVER}
    Should Be Equal    ${check_message}    ${ORIGINAL_MESSAGE}    msg=Message should be intact!
    Log To Console    ✓ Message intact: ${check_message}
    
    Log To Console    \n======== CLOSE AND REOPEN TEST COMPLETED SUCCESSFULLY! ========
    
    [Teardown]    Cleanup Created Fieldreport

*** Keywords ***
Create Field Report For Close Test
    [Documentation]    Create a new field report for close button testing
    Open And Login
    Setup Dynamic Test Data
    
    Log To Console    ======== CREATING FIELD REPORT FOR CLOSE TEST ========
    Go To    https://preproderp.finalisten.se/fieldreport/create/
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    Select Customer And Project    customer=${DB_CUSTOMER}    project=${DB_PROJECT}
    
    # Set work date
    Input Text    ${WORK_DATE_INPUT}    ${INITIAL_WORK_DATE}
    
    # Set total hours
    Input Text    ${TOTAL_HOURS_INPUT}    ${INITIAL_TOTAL_HOURS}
    
    # Set message
    Input Text    ${MESSAGE_TO_APPROVER}    ${INITIAL_MESSAGE}
    
    # Select installer
    Select From List By Index    ${INSTALLER_DROPDOWN}    1
    
    # Save the field report
    ${save_btn}=    Wait Until Element Is Visible    ${SAVE_BUTTON}    timeout=10s
    Click Element    ${save_btn}
    Sleep    3s
    
    # Extract field report ID from URL
    Wait Until Keyword Succeeds    5x    5s    Location Should Contain    /edit/
    ${fieldreport_id}=    Extract And Verify Fieldreport ID
    Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${fieldreport_id}
    Log To Console    ✓ Created Field Report ID: ${fieldreport_id}
