*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}      xpath=//*[@id="register"]
${EMPLOYEES_MENU}     xpath=//*[@id="employee_app_menu"]

*** Test Cases ***
Verify Employee List Opens Successfully
    Open And Login
    Click Element    ${REGISTER_MENU}
    Click Element    ${EMPLOYEES_MENU}
    Wait Until Page Contains    Filters    timeout=10s
    Log To Console    "Filters text found. Employee list opened successfully."
    Close Browser
