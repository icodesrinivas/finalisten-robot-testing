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
    Wait Until Page Contains    ${PERFORMANCE_REPORT_TEXT}    timeout=20s
    Log To Console    "Filters found. Performance Report App opened successfully."
    Close Browser

*** Keywords ***
Hover Over Reports Menu
    Wait Until Page Contains Element    ${REPORTS_MENU}    timeout=20s
    Execute Javascript    var el = document.getElementById('reports'); if(el) el.scrollIntoView({behavior: 'smooth', block: 'center'});
    Sleep    2s
    Wait Until Element Is Visible    ${REPORTS_MENU}    timeout=15s
    Mouse Over    ${REPORTS_MENU}
    Sleep    1s

Click On Performance Report Menu
    Wait Until Element Is Visible    ${PERFORMANCE_REPORT_MENU}    timeout=15s
    Click Element    ${PERFORMANCE_REPORT_MENU}
