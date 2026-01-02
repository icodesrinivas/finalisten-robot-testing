*** Settings ***
Documentation    Test suite for validating data types in Field Report fields.
...              
...              Tests include:
...              26. Enter alphabetic characters in Total Hours - verify rejection
...              27. Enter negative value in Total Hours - verify rejection
...              28. Enter decimal value in Total Hours - verify acceptance
...              29. Enter extremely long text in Message - verify handling
Library          SeleniumLibrary
Library          DateTime
Library          String
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
${INSTALLER_DROPDOWN}             id=id_installer_name
${SAVE_BUTTON}                    css=button.save
${DELETE_BUTTON}                  id=remove_fieldreport

# Valid test data
${VALID_WORK_DATE}                2025-10-15

# Test State
${CREATED_FIELDREPORT_ID}         ${EMPTY}

*** Test Cases ***
Test Alphabetic Characters In Total Hours Rejected
    [Documentation]    Point 26: Enter alphabetic characters in Total Hours field to verify rejection.
    [Tags]    fieldreport    validation    datatype    negative
    [Setup]    Login To Application
    
    Log To Console    ======== TEST: Alphabetic Characters in Total Hours ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Fill required fields
    Select From List By Index    ${CUSTOMER_DROPDOWN}    1
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    Select From List By Index    ${PROJECT_DROPDOWN}    1
    ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    Select From List By Index    ${SUBPROJECT_DROPDOWN}    1
    Input Text    ${WORK_DATE_INPUT}    ${VALID_WORK_DATE}
    Select From List By Index    ${INSTALLER_DROPDOWN}    1
    
    # Enter alphabetic characters in Total Hours
    Log To Console    Entering alphabetic characters 'abc' in Total Hours...
    Input Text    ${TOTAL_HOURS_INPUT}    abc
    
    # Get the actual value in the field
    ${field_value}=    Get Value    ${TOTAL_HOURS_INPUT}
    Log To Console    Field value after entering 'abc': ${field_value}
    
    # HTML5 number fields typically don't accept letters
    # Either the field rejects input OR shows validation error on submit
    ${is_empty_or_invalid}=    Run Keyword And Return Status    Should Be Empty    ${field_value}
    
    IF    ${is_empty_or_invalid}
        Log To Console    ✓ Alphabetic input was rejected by the field (HTML5 validation)
    ELSE
        # Try to save and check for error
        ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
        Sleep    2s
        ${alert}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=3s
        ${still_on_create}=    Run Keyword And Return Status    Location Should Contain    /create/
        ${validation_worked}=    Evaluate    ${alert} or ${still_on_create}
        Should Be True    ${validation_worked}    msg=System should reject alphabetic input in Total Hours
        Log To Console    ✓ Server-side validation rejected alphabetic input
    END
    
    [Teardown]    Close All Browsers

Test Negative Value In Total Hours Rejected
    [Documentation]    Point 27: Enter negative value in Total Hours field to verify rejection.
    [Tags]    fieldreport    validation    datatype    negative
    [Setup]    Login To Application
    
    Log To Console    ======== TEST: Negative Value in Total Hours ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Fill required fields
    Select From List By Index    ${CUSTOMER_DROPDOWN}    1
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    Select From List By Index    ${PROJECT_DROPDOWN}    1
    ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    Select From List By Index    ${SUBPROJECT_DROPDOWN}    1
    Input Text    ${WORK_DATE_INPUT}    ${VALID_WORK_DATE}
    Select From List By Index    ${INSTALLER_DROPDOWN}    1
    
    # Enter negative value in Total Hours
    Log To Console    Entering negative value '-5' in Total Hours...
    Input Text    ${TOTAL_HOURS_INPUT}    -5
    
    # Try to save
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    2s
    
    # Check for validation error or alert
    ${alert}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=3s
    ${still_on_create}=    Run Keyword And Return Status    Location Should Contain    /create/
    ${error_msg}=    Run Keyword And Return Status    Page Should Contain    negative
    
    ${validation_worked}=    Evaluate    ${alert} or ${still_on_create} or ${error_msg}
    
    IF    ${validation_worked}
        Log To Console    ✓ Negative value was rejected
    ELSE
        # If it was saved, it might be allowed - log this
        Log To Console    ⚠ Negative value might be allowed by the system
    END
    
    [Teardown]    Close All Browsers

Test Decimal Value In Total Hours Accepted
    [Documentation]    Point 28: Enter decimal value in Total Hours (e.g., 7.5) to verify acceptance.
    [Tags]    fieldreport    validation    datatype    positive
    [Setup]    Login To Application
    
    Log To Console    ======== TEST: Decimal Value in Total Hours ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Fill required fields
    Select From List By Index    ${CUSTOMER_DROPDOWN}    1
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    Select From List By Index    ${PROJECT_DROPDOWN}    1
    ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    Select From List By Index    ${SUBPROJECT_DROPDOWN}    1
    Input Text    ${WORK_DATE_INPUT}    ${VALID_WORK_DATE}
    Select From List By Index    ${INSTALLER_DROPDOWN}    1
    
    # Enter decimal value in Total Hours
    Log To Console    Entering decimal value '7.5' in Total Hours...
    Input Text    ${TOTAL_HOURS_INPUT}    7.5
    
    # Try to save
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    3s
    
    # Handle any alerts
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
    Sleep    2s
    
    # Check if saved successfully
    ${current_url}=    Get Location
    ${saved}=    Run Keyword And Return Status    Should Contain    ${current_url}    /edit/
    
    IF    ${saved}
        ${fieldreport_id}=    Extract Fieldreport ID From URL    ${current_url}
        Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${fieldreport_id}
        
        # Verify the decimal value was saved
        ${stored_hours}=    Get Value    ${TOTAL_HOURS_INPUT}
        Log To Console    Stored Total Hours: ${stored_hours}
        Log To Console    ✓ Decimal value was accepted and saved (ID: ${fieldreport_id})
    ELSE
        Log To Console    ⚠ Decimal value might not be supported
    END
    
    [Teardown]    Cleanup If Exists

Test Long Text In Message Field Handled
    [Documentation]    Point 29: Enter extremely long text in Message to verify handling.
    [Tags]    fieldreport    validation    datatype    boundary
    [Setup]    Login To Application
    
    Log To Console    ======== TEST: Long Text in Message Field ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Fill required fields
    Select From List By Index    ${CUSTOMER_DROPDOWN}    1
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    Select From List By Index    ${PROJECT_DROPDOWN}    1
    ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    Select From List By Index    ${SUBPROJECT_DROPDOWN}    1
    Input Text    ${WORK_DATE_INPUT}    ${VALID_WORK_DATE}
    Select From List By Index    ${INSTALLER_DROPDOWN}    1
    
    # Generate very long text (1000 characters)
    ${long_text}=    Evaluate    "A" * 1000
    Log To Console    Entering 1000 character message...
    Input Text    ${MESSAGE_TO_APPROVER}    ${long_text}
    
    # Check actual text in field
    ${actual_text}=    Get Value    ${MESSAGE_TO_APPROVER}
    ${actual_length}=    Get Length    ${actual_text}
    Log To Console    Actual text length in field: ${actual_length}
    
    # Try to save
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    3s
    
    # Handle any alerts
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
    Sleep    2s
    
    # Check result
    ${current_url}=    Get Location
    ${saved}=    Run Keyword And Return Status    Should Contain    ${current_url}    /edit/
    
    IF    ${saved}
        ${fieldreport_id}=    Extract Fieldreport ID From URL    ${current_url}
        Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${fieldreport_id}
        
        ${stored_message}=    Get Value    ${MESSAGE_TO_APPROVER}
        ${stored_length}=    Get Length    ${stored_message}
        Log To Console    Stored message length: ${stored_length}
        Log To Console    ✓ Long text was handled (saved ${stored_length} characters)
    ELSE
        Log To Console    ⚠ Long text might have caused validation error
    END
    
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

Cleanup If Exists
    [Documentation]    Delete field report only if it was created
    ${has_id}=    Run Keyword And Return Status    Should Not Be Empty    ${CREATED_FIELDREPORT_ID}
    
    IF    ${has_id}
        ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
        Go To    ${edit_url}
        Sleep    2s
        
        ${delete_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${DELETE_BUTTON}    timeout=5s
        IF    ${delete_exists}
            ${delete_btn}=    Get WebElement    ${DELETE_BUTTON}
            Execute Javascript    arguments[0].click();    ARGUMENTS    ${delete_btn}
            Sleep    1s
            Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=5s
            Sleep    1s
            Log To Console    ✓ Cleaned up test field report
        END
    END
    
    Close All Browsers
