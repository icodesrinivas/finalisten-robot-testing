*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_MENU}                     xpath=//*[@id="production"]
${FIELD_REPORT_MENU}                  xpath=//*[@id="field_reports_app_menu"]
${FIELD_REPORT_ADD_BUTTON}           xpath=//a[@href="/fieldreport/create/" and @title="Add New Fieldreport"]

*** Test Cases ***
Verify Field Report Create Page Opens Successfully
    Open And Login
    Hover Over Production Menu
    Click On Field Report Menu
    Click On Field Report Add Button
    Wait Until Page Contains    FIELD REPORT    timeout=10s
    Log To Console    "FIELD REPORT text found. Create view opened successfully."
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Mouse Over    ${PRODUCTION_MENU}

Click On Field Report Menu
    Click Element    ${FIELD_REPORT_MENU}

Click On Field Report Add Button
    Click Element    ${FIELD_REPORT_ADD_BUTTON}
