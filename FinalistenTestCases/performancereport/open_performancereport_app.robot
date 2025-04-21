*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REPORTS_MENU}                     xpath=//*[@id="reports"]
${PERFORMANCE_REPORT_MENU}         xpath=//*[@id="performance_report_app_menu"]
${PERFORMANCE_REPORT_TEXT}         Filters

*** Test Cases ***
Verify Performance Report App Opens Successfully
    Open And Login
    Hover Over Reports Menu
    Click On Performance Report Menu
    Wait Until Page Contains    ${PERFORMANCE_REPORT_TEXT}    timeout=10s
    Log To Console    "Filters found. Performance Report App opened successfully."
    Close Browser

*** Keywords ***
Hover Over Reports Menu
    Mouse Over    ${REPORTS_MENU}

Click On Performance Report Menu
    Click Element    ${PERFORMANCE_REPORT_MENU}
