*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_MENU}                xpath=//*[@id="production"]
${FIELD_REPORT_MENU}              xpath=//*[@id="field_reports_app_menu"]

*** Test Cases ***
Verify Field Report List View Opens Successfully
    Open And Login
    Hover Over Production Menu
    Click On Field Report Menu
    Wait Until Page Contains    Filters    timeout=10s
    Log To Console    "Filters text found. Field Report list view opened successfully."
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Mouse Over    ${PRODUCTION_MENU}

Click On Field Report Menu
    Click Element    ${FIELD_REPORT_MENU}
