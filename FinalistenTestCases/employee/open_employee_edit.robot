*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}      xpath=//*[@id="register"]
${EMPLOYEES_MENU}     xpath=//*[@id="employee_app_menu"]
${EMPLOYEE_ROW}       css=tr.employee_rows

*** Test Cases ***
Verify Employee Edit Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Employees Menu
    Wait Until Page Contains    Filters    timeout=10s
    Wait Until Element Is Visible    ${EMPLOYEE_ROW}    timeout=10s
    Click Element    ${EMPLOYEE_ROW}
    Wait Until Page Contains    PERSONAL DATA    timeout=10s
    Log To Console    "PERSONAL DATA found. Employee edit page opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Wait Until Element Is Visible    ${REGISTER_MENU}    timeout=15s
    Sleep    1s
    Mouse Over    ${REGISTER_MENU}

Click On Employees Menu
    Wait Until Element Is Visible    ${EMPLOYEES_MENU}    timeout=10s
    Click Element    ${EMPLOYEES_MENU}
    Sleep    2s
