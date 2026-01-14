*** Settings ***
Documentation    Test suite for validating required fields in Field Report creation.
...              
...              Tests include:
...              21. Submit without Customer - verify error
...              22. Submit without Project - verify error
...              23. Submit without SubProject - verify error
...              24. Submit without Work Date - verify error
...              25. Submit without Installer - verify error
Library          SeleniumLibrary
Library          DateTime
Library          String
Resource         ../keywords/LoginKeyword.robot

*** Variables ***
# URLs (configurable for different environments)
${BASE_URL}                       https://preproderp.finalisten.se
${LOGIN_URL}                      ${BASE_URL}/login/
${HOMEPAGE_URL}                   ${BASE_URL}/homepage/
${FIELDREPORT_CREATE_URL}         ${BASE_URL}/fieldreport/create/

# Form Field Selectors
${CUSTOMER_DROPDOWN}              id=id_related_customer
${PROJECT_DROPDOWN}               id=id_related_project
${SUBPROJECT_DROPDOWN}            id=id_related_subproject
${WORK_DATE_INPUT}                id=id_work_date
${INSTALLER_DROPDOWN}             id=id_installer_name
${SAVE_BUTTON}                    css=button.save

# Valid test data
${VALID_WORK_DATE}                2025-10-15

*** Test Cases ***
Test Submit Without Customer Shows Error
    [Documentation]    Point 21: Submit Field Report without selecting Customer to verify error.
    [Tags]    fieldreport    validation    required    negative
    [Setup]    Login To Application
    
    Log To Console    ======== TEST: Submit Without Customer ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Fill all fields EXCEPT Customer
    Input Text    ${WORK_DATE_INPUT}    ${VALID_WORK_DATE}
    
    # Try to save
    Log To Console    Attempting to save without Customer...
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    2s
    
    # Check for error - either alert, error message, or still on create page
    ${alert_present}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=3s
    ${still_on_create}=    Run Keyword And Return Status    Location Should Contain    /create/
    ${error_on_page}=    Run Keyword And Return Status    Page Should Contain    required
    
    ${validation_worked}=    Evaluate    ${alert_present} or ${still_on_create} or ${error_on_page}
    Should Be True    ${validation_worked}    msg=System should prevent submission without Customer
    Log To Console    ✓ Customer required field validation working
    
    [Teardown]    Close All Browsers

Test Submit Without Project Shows Error
    [Documentation]    Point 22: Submit Field Report without selecting Project to verify error.
    [Tags]    fieldreport    validation    required    negative
    [Setup]    Login To Application
    
    Log To Console    ======== TEST: Submit Without Project ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Select Customer but NOT Project
    Select From List By Index    ${CUSTOMER_DROPDOWN}    1
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Fill other fields
    Input Text    ${WORK_DATE_INPUT}    ${VALID_WORK_DATE}
    
    # Try to save without Project
    Log To Console    Attempting to save without Project...
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    2s
    
    # Check for validation
    ${alert_present}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=3s
    ${still_on_create}=    Run Keyword And Return Status    Location Should Contain    /create/
    
    ${validation_worked}=    Evaluate    ${alert_present} or ${still_on_create}
    Should Be True    ${validation_worked}    msg=System should prevent submission without Project
    Log To Console    ✓ Project required field validation working
    
    [Teardown]    Close All Browsers

Test Submit Without SubProject Shows Error
    [Documentation]    Point 23: Submit Field Report without selecting SubProject to verify error.
    [Tags]    fieldreport    validation    required    negative
    [Setup]    Login To Application
    
    Log To Console    ======== TEST: Submit Without SubProject ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Select Customer and Project but NOT SubProject
    Select From List By Index    ${CUSTOMER_DROPDOWN}    1
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    Select From List By Index    ${PROJECT_DROPDOWN}    1
    ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Fill other fields but NOT SubProject
    Input Text    ${WORK_DATE_INPUT}    ${VALID_WORK_DATE}
    
    # Try to save without SubProject
    Log To Console    Attempting to save without SubProject...
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    2s
    
    # Check for validation
    ${alert_present}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=3s
    ${still_on_create}=    Run Keyword And Return Status    Location Should Contain    /create/
    
    ${validation_worked}=    Evaluate    ${alert_present} or ${still_on_create}
    Should Be True    ${validation_worked}    msg=System should prevent submission without SubProject
    Log To Console    ✓ SubProject required field validation working
    
    [Teardown]    Close All Browsers

Test Submit Without Work Date Shows Error
    [Documentation]    Point 24: Submit Field Report without entering Work Date to verify error.
    [Tags]    fieldreport    validation    required    negative
    [Setup]    Login To Application
    
    Log To Console    ======== TEST: Submit Without Work Date ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Fill all fields EXCEPT Work Date
    Select From List By Index    ${CUSTOMER_DROPDOWN}    1
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    Select From List By Index    ${PROJECT_DROPDOWN}    1
    ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    Select From List By Index    ${SUBPROJECT_DROPDOWN}    1
    Select From List By Index    ${INSTALLER_DROPDOWN}    1
    
    # Clear Work Date if it has default value
    Clear Element Text    ${WORK_DATE_INPUT}
    
    # Try to save without Work Date
    Log To Console    Attempting to save without Work Date...
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    2s
    
    # Check for validation
    ${alert_present}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=3s
    ${still_on_create}=    Run Keyword And Return Status    Location Should Contain    /create/
    
    ${validation_worked}=    Evaluate    ${alert_present} or ${still_on_create}
    Should Be True    ${validation_worked}    msg=System should prevent submission without Work Date
    Log To Console    ✓ Work Date required field validation working
    
    [Teardown]    Close All Browsers

Test Submit Without Installer Shows Error
    [Documentation]    Point 25: Submit Field Report without selecting Installer to verify error.
    [Tags]    fieldreport    validation    required    negative
    [Setup]    Login To Application
    
    Log To Console    ======== TEST: Submit Without Installer ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Fill all fields EXCEPT Installer
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
    
    # Do NOT select Installer (explicitly set to index 0/empty if needed)
    Select From List By Index    ${INSTALLER_DROPDOWN}    0
    
    # Try to save without Installer
    Log To Console    Attempting to save without Installer...
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    2s
    
    # Check for validation
    ${alert_present}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=3s
    ${still_on_create}=    Run Keyword And Return Status    Location Should Contain    /create/
    
    ${validation_worked}=    Evaluate    ${alert_present} or ${still_on_create}
    Should Be True    ${validation_worked}    msg=System should prevent submission without Installer
    Log To Console    ✓ Installer required field validation working
    
    [Teardown]    Close All Browsers

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
