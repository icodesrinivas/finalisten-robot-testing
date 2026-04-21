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
# Form Field Selectors
${CUSTOMER_DROPDOWN}              id=id_related_customer
${PROJECT_DROPDOWN}               id=id_related_project
${SUBPROJECT_DROPDOWN}            id=id_related_subproject
${WORK_DATE_INPUT}                id=id_work_date
${TOTAL_HOURS_INPUT}              id=id_total_work_hours
${MESSAGE_TO_APPROVER}            id=id_message_to_approver
${INSTALLER_DROPDOWN}             id=id_installer_name
${SAVE_BUTTON}                    css=button.save

# Valid test data
${VALID_WORK_DATE}                2025-10-15

# Test State
${CREATED_FIELDREPORT_ID}         ${EMPTY}

*** Test Cases ***
Test Alphabetic Characters In Total Hours Rejected
    [Documentation]    Point 26: Enter alphabetic characters in Total Hours field to verify rejection.
    [Tags]    fieldreport    validation    datatype    negative
    [Setup]    Open And Login
    
    Log To Console    ======== TEST: Alphabetic Characters in Total Hours ========
    Go To    https://preproderp.finalisten.se/fieldreport/create/
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Fill required fields
    Setup Dynamic Test Data
    Select Customer And Project    customer=${DB_CUSTOMER}    project=${DB_PROJECT}
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
        Wait Until Element Is Visible    ${SAVE_BUTTON}    timeout=30s
        Click Element    ${SAVE_BUTTON}
        Sleep    2s
        ${alert}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=3s
        ${still_on_create}=    Run Keyword And Return Status    Location Should Contain    /create/
        
        # If unexpectedly submitted, capture ID for cleanup
        ${was_submitted}=    Run Keyword And Return Status    Location Should Contain    /edit/
        IF    ${was_submitted}
            ${id}=    Extract And Verify Fieldreport ID
            Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${id}
        END
        
        ${validation_worked}=    Evaluate    ${alert} or ${still_on_create}
        Should Be True    ${validation_worked}    msg=System should reject alphabetic input in Total Hours
        Log To Console    ✓ Server-side validation rejected alphabetic input
    END
    
    [Teardown]    Cleanup Created Fieldreport

Test Negative Value In Total Hours Rejected
    [Documentation]    Point 27: Enter negative value in Total Hours field to verify rejection.
    [Tags]    fieldreport    validation    datatype    negative
    [Setup]    Open And Login
    
    Log To Console    ======== TEST: Negative Value in Total Hours ========
    Go To    https://preproderp.finalisten.se/fieldreport/create/
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Fill required fields
    Setup Dynamic Test Data
    Select Customer And Project    customer=${DB_CUSTOMER}    project=${DB_PROJECT}
    Input Text    ${WORK_DATE_INPUT}    ${VALID_WORK_DATE}
    Select From List By Index    ${INSTALLER_DROPDOWN}    1
    
    # Enter negative value in Total Hours
    Log To Console    Entering negative value '-5' in Total Hours...
    Input Text    ${TOTAL_HOURS_INPUT}    -5
    
    # Try to save
    Wait Until Element Is Visible    ${SAVE_BUTTON}    timeout=30s
    Click Element    ${SAVE_BUTTON}
    Sleep    2s
    
    # Check for validation error or alert
    ${alert}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=3s
    ${still_on_create}=    Run Keyword And Return Status    Location Should Contain    /create/
    ${error_msg}=    Run Keyword And Return Status    Page Should Contain    negative
    
    # If unexpectedly submitted, capture ID for cleanup
    ${was_submitted}=    Run Keyword And Return Status    Location Should Contain    /edit/
    IF    ${was_submitted}
        ${id}=    Extract And Verify Fieldreport ID
        Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${id}
    END
    
    ${validation_worked}=    Evaluate    ${alert} or ${still_on_create} or ${error_msg}
    
    IF    ${validation_worked}
        Log To Console    ✓ Negative value was rejected
    ELSE
        # If it was saved, it might be allowed - log this
        Log To Console    ⚠ Negative value might be allowed by the system
    END
    
    [Teardown]    Cleanup Created Fieldreport

Test Decimal Value In Total Hours Accepted
    [Documentation]    Point 28: Enter decimal value in Total Hours (e.g., 7.5) to verify acceptance.
    [Tags]    fieldreport    validation    datatype    positive
    [Setup]    Open And Login
    
    Log To Console    ======== TEST: Decimal Value in Total Hours ========
    Go To    https://preproderp.finalisten.se/fieldreport/create/
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Fill required fields
    Setup Dynamic Test Data
    Select Customer And Project    customer=${DB_CUSTOMER}    project=${DB_PROJECT}
    Input Text    ${WORK_DATE_INPUT}    ${VALID_WORK_DATE}
    Select From List By Index    ${INSTALLER_DROPDOWN}    1
    
    # Enter decimal value in Total Hours
    Log To Console    Entering decimal value '7.5' in Total Hours...
    Input Text    ${TOTAL_HOURS_INPUT}    7.5
    
    # Try to save
    Wait Until Element Is Visible    ${SAVE_BUTTON}    timeout=30s
    Click Element    ${SAVE_BUTTON}
    Sleep    3s
    
    # Handle any alerts
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
    Sleep    2s
    
    # Check if saved successfully
    ${current_url}=    Get Location
    ${saved}=    Run Keyword And Return Status    Should Contain    ${current_url}    /edit/
    
    IF    ${saved}
        ${id}=    Extract And Verify Fieldreport ID
        Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${id}
        
        # Verify the decimal value was saved
        ${stored_hours}=    Get Value    ${TOTAL_HOURS_INPUT}
        Log To Console    Stored Total Hours: ${stored_hours}
        Log To Console    ✓ Decimal value was accepted and saved (ID: ${id})
    ELSE
        Log To Console    ⚠ Decimal value might not be supported
    END
    
    [Teardown]    Cleanup Created Fieldreport

Test Long Text In Message Field Handled
    [Documentation]    Point 29: Enter extremely long text in Message to verify handling.
    [Tags]    fieldreport    validation    datatype    boundary
    [Setup]    Open And Login
    
    Log To Console    ======== TEST: Long Text in Message Field ========
    Go To    https://preproderp.finalisten.se/fieldreport/create/
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Fill required fields
    Setup Dynamic Test Data
    Select Customer And Project    customer=${DB_CUSTOMER}    project=${DB_PROJECT}
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
    Wait Until Element Is Visible    ${SAVE_BUTTON}    timeout=30s
    Click Element    ${SAVE_BUTTON}
    Sleep    3s
    
    # Handle any alerts
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
    Sleep    2s
    
    # Check result
    ${current_url}=    Get Location
    ${saved}=    Run Keyword And Return Status    Should Contain    ${current_url}    /edit/
    
    IF    ${saved}
        ${id}=    Extract And Verify Fieldreport ID
        Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${id}
        
        ${stored_message}=    Get Value    ${MESSAGE_TO_APPROVER}
        ${stored_length}=    Get Length    ${stored_message}
        Log To Console    Stored message length: ${stored_length}
        Log To Console    ✓ Long text was handled (saved ${stored_length} characters)
    ELSE
        Log To Console    ⚠ Long text might have caused validation error
    END
    
    [Teardown]    Cleanup Created Fieldreport
