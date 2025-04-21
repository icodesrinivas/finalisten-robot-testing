*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}             xpath=//*[@id="register"]
${SUBCONTRACTOR_MENU}        xpath=//*[@id="subcontractor_app_menu"]

*** Test Cases ***
Verify Subcontractor List Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Subcontractor Menu
    Wait Until Page Contains    Filters    timeout=10s
    Log To Console    "Filters text found. Subcontractor list opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Subcontractor Menu
    Click Element    ${SUBCONTRACTOR_MENU}
