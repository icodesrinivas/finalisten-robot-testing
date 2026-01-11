*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
*** Variables ***
${REGISTER_MENU}      id=register
${EMPLOYEES_MENU}     id=employee_app_menu

*** Test Cases ***
Verify Employee List Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    # Wait for Presence (id=register) which is more robust in headless
    Wait Until Page Contains Element    ${REGISTER_MENU}    timeout=45s
    Sleep    2s
    Click Element    ${REGISTER_MENU}
    # Wait for Presence (submenu)
    Wait Until Page Contains Element    ${EMPLOYEES_MENU}    timeout=20s
    Sleep    1s
    Click Element    ${EMPLOYEES_MENU}
    Sleep    3s
    Wait Until Page Contains    Filters    timeout=15s
    Log To Console    "Filters text found. Employee list opened successfully."
    Close Browser
