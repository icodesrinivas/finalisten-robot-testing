*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}       xpath=//*[@id="register"]
${EMPLOYEES_MENU}      xpath=//*[@id="employee_app_menu"]
${ADD_EMPLOYEE_BTN}     xpath=//a[@href="/employees/employee/create/" and @title="Add New Employee"]

*** Test Cases ***
Verify Employee Create Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Employees Menu
    Wait Until Page Contains    Filters    timeout=10s
    Click On Add Employee Button
    Wait Until Page Contains    PERSONAL DATA    timeout=10s
    Log To Console    "PERSONAL DATA found. Employee create page opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Wait Until Element Is Visible    ${REGISTER_MENU}    timeout=30s
    Sleep    1s
    Mouse Over    ${REGISTER_MENU}

Click On Employees Menu
    Wait Until Element Is Visible    ${EMPLOYEES_MENU}    timeout=10s
    Click Element    ${EMPLOYEES_MENU}
    Sleep    2s

Click On Add Employee Button
    Click Element    ${ADD_EMPLOYEE_BTN}
