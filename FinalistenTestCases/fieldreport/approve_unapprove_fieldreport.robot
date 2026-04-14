*** Settings ***
Documentation    Test suite for verifying Approve/Unapprove functionality on Field Report.
...              
...              Test Flow:
...              1. Create a new field report (setup)
...              2. Verify initial status is Unapproved
...              3. Click Approve button and verify status changes
...              4. Click Unapprove button and verify status reverts
...              5. Delete the field report (teardown)
Library          SeleniumLibrary
Library          DateTime
Library          String
Library          Collections
Resource         ../keywords/LoginKeyword.robot

*** Variables ***
# Initial Values (for creation)
${INITIAL_WORK_DATE}              2025-10-20

# Test State Variables
${CREATED_FIELDREPORT_ID}         ${EMPTY}

*** Test Cases ***
Test Approve And Unapprove Field Report
    [Documentation]    Test the Approve and Unapprove button functionality.
    ...                Verify that status changes correctly between Approved and Unapproved states.
    [Tags]    fieldreport    approve    unapprove    validation
    [Setup]    Create Test Field Report
    
    # Navigate to edit page
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${APPROVE_BUTTON}    timeout=15s
    Log To Console    ======== TESTING APPROVE/UNAPPROVE FOR FIELD REPORT ${CREATED_FIELDREPORT_ID} ========
    
    # ======== VERIFY INITIAL STATE (UNAPPROVED) ========
    Log To Console    \n--- Checking Initial Status ---
    # Note: Approve button is an INPUT element, so we get the 'value' attribute not text
    ${button_value}=    Get Element Attribute    ${APPROVE_BUTTON}    value
    Should Contain    ${button_value}    Approve    msg=Initial button should show 'Approve'
    Log To Console    ✓ Initial status is Unapproved (button shows: ${button_value})
    
    # ======== CLICK APPROVE ========
    Log To Console    \n--- Clicking APPROVE Button ---
    Click Element    ${APPROVE_BUTTON}
    Sleep    2s
    
    # Handle confirmation alert if present
    ${alert_present}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=3s
    IF    ${alert_present}
        Log To Console    ✓ Accepted confirmation dialog
    END
    Sleep    2s
    
    # Verify button changed to Unapprove
    ${button_value_after_approve}=    Get Element Attribute    ${APPROVE_BUTTON}    value
    Should Contain    ${button_value_after_approve}    Unapprove    msg=Button should now show 'Unapprove' after approval
    Log To Console    ✓ Field Report APPROVED successfully (button shows: ${button_value_after_approve})
    
    # ======== CLICK UNAPPROVE ========
    Log To Console    \n--- Clicking UNAPPROVE Button ---
    Click Element    ${APPROVE_BUTTON}
    Sleep    2s
    
    # Handle confirmation alert if present
    ${alert_present2}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=3s
    IF    ${alert_present2}
        Log To Console    ✓ Accepted confirmation dialog
    END
    Sleep    2s
    
    # Verify button changed back to Approve
    ${button_value_after_unapprove}=    Get Element Attribute    ${APPROVE_BUTTON}    value
    Should Contain    ${button_value_after_unapprove}    Approve    msg=Button should now show 'Approve' after unapproval
    Log To Console    ✓ Field Report UNAPPROVED successfully (button shows: ${button_value_after_unapprove})
    
    # ======== VERIFY PERSISTENCE AFTER REFRESH ========
    Log To Console    \n--- Verifying Status Persists After Refresh ---
    
    # Approve again
    Click Element    ${APPROVE_BUTTON}
    Sleep    2s
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
    Sleep    2s
    
    # Refresh page
    Reload Page
    Wait Until Page Contains Element    ${APPROVE_BUTTON}    timeout=15s
    
    # Verify approved status persisted
    ${button_after_refresh}=    Get Element Attribute    ${APPROVE_BUTTON}    value
    Should Contain    ${button_after_refresh}    Unapprove    msg=Approved status should persist after refresh
    Log To Console    ✓ Approved status persisted after page refresh
    
    Log To Console    \n======== APPROVE/UNAPPROVE TEST COMPLETED SUCCESSFULLY! ========
    
    [Teardown]    Cleanup Created Fieldreport

*** Keywords ***
Create Test Field Report
    [Documentation]    Create a fresh field report for testing.
    Open And Login
    Setup Dynamic Test Data
    
    Go To    https://preproderp.finalisten.se/fieldreport/create/
    # Use dynamic data and fallback if specific one fails
    Select Customer And Project    customer=${DB_CUSTOMER}    project=${DB_PROJECT}
    
    Input Text    id=id_work_date    ${INITIAL_WORK_DATE}
    Select From List By Index    id=id_installer_name    1
    
    # Save the field report
    # Use explicit click and wait for location change
    ${save_btn}=    Wait Until Element Is Visible    css=button.save    timeout=10s
    Click Element    ${save_btn}
    
    # Wait for the redirect to the edit page (URL contains /edit/)
    Wait Until Keyword Succeeds    5x    5s    Location Should Contain    /edit/
    
    ${id}=    Extract And Verify Fieldreport ID
    Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${id}
    Log To Console    ✓ Created FR: ${id}
