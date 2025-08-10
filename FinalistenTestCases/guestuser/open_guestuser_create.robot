*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}            xpath=//*[@id="register"]
${GUEST_USER_MENU}          xpath=//*[@id="guestuser_app_menu"]
${ADD_GUEST_USER_BTN}       xpath=//a[@title="Add New Subcontractor"]

*** Test Cases ***
Verify Guest User Create Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Guest User Menu
    Click On Add Guest User Button
    Wait Until Page Contains    PERSONAL DATA    timeout=10s
    Log To Console    "PERSONAL DATA found. Guest user create page opened successfully."

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Guest User Menu
    Click Element    ${GUEST_USER_MENU}

Click On Add Guest User Button
    Click Element    ${ADD_GUEST_USER_BTN}