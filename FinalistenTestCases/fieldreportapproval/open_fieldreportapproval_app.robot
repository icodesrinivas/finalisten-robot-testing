*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_MENU}                   xpath=//*[@id="production"]
${FIELD_REPORT_APPROVAL_MENU}        xpath=//*[@id="field_report_approval_app_menu"]

*** Test Cases ***
Verify Field Report Approval App Opens Successfully
    Open And Login
    Hover Over Production Menu
    Click On Field Report Approval Menu
    Wait Until Page Contains    List Of Installers    timeout=10s
    Log To Console    "List Of Installers text found. Field Report Approval app opened successfully."
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Mouse Over    ${PRODUCTION_MENU}

Click On Field Report Approval Menu
    Click Element    ${FIELD_REPORT_APPROVAL_MENU}
