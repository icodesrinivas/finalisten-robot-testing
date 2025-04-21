*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}      xpath=//*[@id="register"]
${EMPLOYEES_MENU}     xpath=//*[@id="employee_app_menu"]

*** Test Cases ***
Verify Employee List Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Employees Menu
    Wait Until Page Contains    Filters    timeout=10s
    Log To Console    "Filters text found. Employee list opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Employees Menu
    Click Element    ${EMPLOYEES_MENU}
