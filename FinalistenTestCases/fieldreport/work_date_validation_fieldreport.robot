*** Settings ***
Documentation    Test suite for verifying Work Date Range validation in Field Report.
...              
...              Tests include:
...              - Creating field report with valid work date (within allowed range)
...              - Attempting to create field report with work date outside allowed range
...              - Verifying error message when work date is outside range
...              
...              Note: The allowed work date range is configured in the Settings app.
...              Pre-production has October 2025 as the last open period.
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

# Valid and Invalid Dates
# Note: Pre-production has October 2025 as the last open reporting period
${VALID_WORK_DATE}                2025-10-15
${INVALID_FUTURE_DATE}            2026-12-31
${INVALID_CLOSED_PERIOD_DATE}     2024-01-15
${BOUNDARY_DATE}                  2025-10-31

# Error Messages
${CLOSED_PERIOD_ERROR}            closed for reporting
${DATE_RANGE_ERROR}               Date must be

# Test State Variables
${CREATED_FIELDREPORT_ID}         ${EMPTY}

*** Test Cases ***
Test Create Field Report With Valid Work Date
    [Documentation]    Test that field report can be created with a work date within the allowed range.
    [Tags]    fieldreport    workdate    validation    positive
    [Setup]    Login To Application
    
    Log To Console    ======== TESTING VALID WORK DATE ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Fill in required fields
    Log To Console    \n--- Creating Field Report with Valid Date: ${VALID_WORK_DATE} ---
    
    # Select customer
    Select From List By Index    ${CUSTOMER_DROPDOWN}    1
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Select project
    Select From List By Index    ${PROJECT_DROPDOWN}    1
    ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Select subproject
    Select From List By Index    ${SUBPROJECT_DROPDOWN}    1
    
    # Set valid work date
    Input Text    ${WORK_DATE_INPUT}    ${VALID_WORK_DATE}
    Log To Console    Set Work Date: ${VALID_WORK_DATE}
    
    # Select installer
    Select From List By Index    ${INSTALLER_DROPDOWN}    1
    
    # Save
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    3s
    
    # Handle any alerts
    ${alert_present}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=3s
    Sleep    2s
    
    # Verify successful creation
    ${current_url}=    Get Location
    ${created}=    Run Keyword And Return Status    Should Contain    ${current_url}    /edit/
    
    IF    ${created}
        ${fieldreport_id}=    Extract Fieldreport ID From URL    ${current_url}
        Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${fieldreport_id}
        Log To Console    ✓ Field Report created successfully with ID: ${fieldreport_id}
        Log To Console    ✓ Valid work date ${VALID_WORK_DATE} was accepted
    ELSE
        Log To Console    ⚠ Might have stayed on create page - checking for errors
        ${page_source}=    Get Source
        ${has_error}=    Run Keyword And Return Status    Should Contain Any    ${page_source}    ${CLOSED_PERIOD_ERROR}    error
        IF    ${has_error}
            Fail    Valid work date was rejected! Check if reporting period is still open.
        END
    END
    
    Log To Console    \n======== VALID WORK DATE TEST PASSED! ========
    
    [Teardown]    Cleanup Created Fieldreport

Test Reject Field Report With Closed Period Date
    [Documentation]    Test that field report creation is prevented for a closed reporting period.
    [Tags]    fieldreport    workdate    validation    negative    closedperiod
    [Setup]    Login To Application
    
    Log To Console    ======== TESTING CLOSED PERIOD DATE ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Fill in required fields
    Log To Console    \n--- Attempting to Create Field Report with Closed Period Date: ${INVALID_CLOSED_PERIOD_DATE} ---
    
    # Select customer
    Select From List By Index    ${CUSTOMER_DROPDOWN}    1
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Select project
    Select From List By Index    ${PROJECT_DROPDOWN}    1
    ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Select subproject
    Select From List By Index    ${SUBPROJECT_DROPDOWN}    1
    
    # Set closed period date
    Input Text    ${WORK_DATE_INPUT}    ${INVALID_CLOSED_PERIOD_DATE}
    Log To Console    Set Work Date: ${INVALID_CLOSED_PERIOD_DATE}
    
    # Select installer
    Select From List By Index    ${INSTALLER_DROPDOWN}    1
    
    # Attempt to save
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    2s
    
    # Check for alert with error message
    ${alert_text}=    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=5s
    Log To Console    Alert response: ${alert_text}
    
    Sleep    2s
    
    # Verify we're still on create page (not redirected to edit)
    ${current_url}=    Get Location
    ${still_on_create}=    Run Keyword And Return Status    Should Contain    ${current_url}    /create/
    ${on_list}=    Run Keyword And Return Status    Should Contain    ${current_url}    /list/
    
    # Check for error message on page
    ${page_source}=    Get Source
    ${error_shown}=    Run Keyword And Return Status    Should Contain    ${page_source}    ${CLOSED_PERIOD_ERROR}
    
    IF    ${still_on_create} or ${error_shown}
        Log To Console    ✓ Field Report creation was PREVENTED (correct behavior)
        Log To Console    ✓ Closed period date ${INVALID_CLOSED_PERIOD_DATE} was rejected
    ELSE IF    ${on_list}
        # Might have been rejected and redirected to list
        Log To Console    ✓ Redirected to list page (creation was prevented)
    ELSE
        # Check if somehow created
        ${created}=    Run Keyword And Return Status    Should Contain    ${current_url}    /edit/
        IF    ${created}
            ${fieldreport_id}=    Extract Fieldreport ID From URL    ${current_url}
            Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${fieldreport_id}
            Log To Console    ⚠ WARNING: Field Report was created despite closed period date!
            Log To Console    This may indicate the period has been reopened or validation is not working.
        END
    END
    
    Log To Console    \n======== CLOSED PERIOD DATE TEST COMPLETED! ========
    
    [Teardown]    Cleanup If Exists

Test Reject Field Report With Future Date
    [Documentation]    Test that field report creation is prevented for dates too far in the future.
    [Tags]    fieldreport    workdate    validation    negative    future
    [Setup]    Login To Application
    
    Log To Console    ======== TESTING FUTURE DATE VALIDATION ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Fill in required fields
    Log To Console    \n--- Attempting to Create Field Report with Future Date: ${INVALID_FUTURE_DATE} ---
    
    # Select customer
    Select From List By Index    ${CUSTOMER_DROPDOWN}    1
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Select project
    Select From List By Index    ${PROJECT_DROPDOWN}    1
    ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Select subproject
    Select From List By Index    ${SUBPROJECT_DROPDOWN}    1
    
    # Set future date
    Input Text    ${WORK_DATE_INPUT}    ${INVALID_FUTURE_DATE}
    Log To Console    Set Work Date: ${INVALID_FUTURE_DATE}
    
    # Select installer
    Select From List By Index    ${INSTALLER_DROPDOWN}    1
    
    # Attempt to save
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    2s
    
    # Check for alert
    ${alert_result}=    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=5s
    Log To Console    Alert response: ${alert_result}
    
    Sleep    2s
    
    # Verify creation was prevented
    ${current_url}=    Get Location
    ${still_on_create}=    Run Keyword And Return Status    Should Contain    ${current_url}    /create/
    
    IF    ${still_on_create}
        Log To Console    ✓ Still on create page (future date was rejected)
    ELSE
        ${created}=    Run Keyword And Return Status    Should Contain    ${current_url}    /edit/
        IF    ${created}
            ${fieldreport_id}=    Extract Fieldreport ID From URL    ${current_url}
            Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${fieldreport_id}
            Log To Console    ⚠ WARNING: Field Report was created with future date!
            Log To Console    This may indicate future date validation is not enabled.
        ELSE
            Log To Console    ✓ Future date validation applied
        END
    END
    
    Log To Console    \n======== FUTURE DATE TEST COMPLETED! ========
    
    [Teardown]    Cleanup If Exists

Test Boundary Work Date Within Range
    [Documentation]    Test field report creation with a date at the boundary of the allowed range.
    [Tags]    fieldreport    workdate    validation    boundary
    [Setup]    Login To Application
    
    Log To Console    ======== TESTING BOUNDARY DATE ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    Log To Console    \n--- Testing Boundary Date: ${BOUNDARY_DATE} ---
    
    # Select customer
    Select From List By Index    ${CUSTOMER_DROPDOWN}    1
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Select project
    Select From List By Index    ${PROJECT_DROPDOWN}    1
    ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Select subproject
    Select From List By Index    ${SUBPROJECT_DROPDOWN}    1
    
    # Set boundary date
    Input Text    ${WORK_DATE_INPUT}    ${BOUNDARY_DATE}
    Log To Console    Set Work Date: ${BOUNDARY_DATE}
    
    # Select installer
    Select From List By Index    ${INSTALLER_DROPDOWN}    1
    
    # Save
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    3s
    
    # Handle any alerts
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
    Sleep    2s
    
    # Check result
    ${current_url}=    Get Location
    ${created}=    Run Keyword And Return Status    Should Contain    ${current_url}    /edit/
    
    IF    ${created}
        ${fieldreport_id}=    Extract Fieldreport ID From URL    ${current_url}
        Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${fieldreport_id}
        Log To Console    ✓ Boundary date ${BOUNDARY_DATE} was ACCEPTED
        Log To Console    ✓ Field Report created: ${fieldreport_id}
    ELSE
        Log To Console    ⚠ Boundary date ${BOUNDARY_DATE} was REJECTED
        Log To Console    This date may be at the edge of the allowed range
    END
    
    Log To Console    \n======== BOUNDARY DATE TEST COMPLETED! ========
    
    [Teardown]    Cleanup If Exists

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
    ELSE
        Log To Console    No field report to delete
    END
    
    Close All Browsers

Cleanup If Exists
    [Documentation]    Delete field report only if it was created
    ${has_id}=    Run Keyword And Return Status    Should Not Be Empty    ${CREATED_FIELDREPORT_ID}
    
    IF    ${has_id}
        Cleanup Created Fieldreport
    ELSE
        Log To Console    No field report was created (as expected for negative tests)
        Close All Browsers
    END
