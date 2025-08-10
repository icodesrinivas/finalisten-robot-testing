*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}        xpath=//*[@id="register"]
${GUEST_USER_MENU}      xpath=//*[@id="guestuser_app_menu"]

*** Test Cases ***
Verify Guest User List Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Guest User Menu
    Wait Until Page Contains    Filters    timeout=10s
    Log To Console    "Filters text found. Guest user list opened successfully."

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Guest User Menu
    Click Element    ${GUEST_USER_MENU}