*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}                  xpath=//*[@id="register"]
${SETTINGS_APP_MENU}             xpath=//*[@id="settings_app_menu"]

*** Test Cases ***
Verify Settings App Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Settings App Menu
    Wait Until Page Contains    Settings       timeout=15s
    Wait Until Page Contains    Fieldreport    timeout=15s
    Log To Console    "Settings and Fieldreport texts found. Settings app opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Settings App Menu
    Click Element    ${SETTINGS_APP_MENU}
