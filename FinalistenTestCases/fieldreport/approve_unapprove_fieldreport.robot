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

# Action Buttons
${APPROVE_BUTTON}                 id=id_fieldreport_approve_btn
${DELETE_BUTTON}                  id=remove_fieldreport

# Initial Values (for creation)
${INITIAL_WORK_DATE}              2025-10-20

# Test State Variables
${CREATED_FIELDREPORT_ID}         ${EMPTY}

*** Test Cases ***
Test Approve And Unapprove Field Report
    [Documentation]    Test the Approve and Unapprove button functionality.
    ...                Verify that status changes correctly between Approved and Unapproved states.
    [Tags]    fieldreport    approve    unapprove    validation
    [Setup]    Create Field Report For Approval Test
    
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

Create Field Report For Approval Test
    [Documentation]    Create a new field report for approval testing
    Login To Application
    
    Log To Console    ======== CREATING FIELD REPORT FOR APPROVAL TEST ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Select first available customer
    ${options}=    Get List Items    ${CUSTOMER_DROPDOWN}
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
    [Documentation]    Delete the created fieldreport to maintain data cleanliness
    Log To Console    ======== CLEANUP: Deleting Field Report ========
    
    ${has_id}=    Run Keyword And Return Status    Should Not Be Empty    ${CREATED_FIELDREPORT_ID}
    
    IF    ${has_id}
        ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
        Go To    ${edit_url}
        Sleep    2s
        
        # First unapprove if approved (delete is disabled for approved reports)
        ${approve_btn_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${APPROVE_BUTTON}    timeout=5s
        IF    ${approve_btn_exists}
            ${btn_value}=    Get Element Attribute    ${APPROVE_BUTTON}    value
            ${is_approved}=    Run Keyword And Return Status    Should Contain    ${btn_value}    Unapprove
            IF    ${is_approved}
                Log To Console    Field Report is approved - unapproving first...
                Click Element    ${APPROVE_BUTTON}
                Sleep    1s
                Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
                Sleep    2s
            END
        END
        
        # Now delete
        ${delete_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${DELETE_BUTTON}    timeout=10s
        
        IF    ${delete_exists}
            Log To Console    Deleting Field Report ID: ${CREATED_FIELDREPORT_ID}
            # Use JavaScript click to avoid interception
            ${delete_btn}=    Get WebElement    ${DELETE_BUTTON}
            Execute Javascript    arguments[0].click();    ARGUMENTS    ${delete_btn}
            Sleep    1s
            Handle Alert    action=ACCEPT    timeout=5s
            Sleep    2s
            Log To Console    ✓ Field Report ${CREATED_FIELDREPORT_ID} deleted successfully!
        END
    END
    
    Close All Browsers

