*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}      xpath=//*[@id="register"]
${EMPLOYEES_MENU}     xpath=//*[@id="employee_app_menu"]

*** Test Cases ***
Verify Employee List Opens Successfully
    Open And Login
    Wait Until Element Is Visible    ${REGISTER_MENU}    timeout=30s
    Sleep    1s
    Click Element    ${REGISTER_MENU}
    Wait Until Element Is Visible    ${EMPLOYEES_MENU}    timeout=10s
    Sleep    1s
    Click Element    ${EMPLOYEES_MENU}
    Sleep    2s
    Wait Until Page Contains    Filters    timeout=10s
    Log To Console    "Filters text found. Employee list opened successfully."
    Close Browser
