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
    Sleep    3s
    Wait Until Page Contains    Filters    timeout=15s
    Log To Console    "Filters text found. Field Report list view opened successfully."
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Wait Until Page Contains Element    ${PRODUCTION_MENU}    timeout=20s
    Execute Javascript    var el = document.getElementById('production'); if(el) el.scrollIntoView({behavior: 'smooth', block: 'center'});
    Sleep    2s
    Wait Until Element Is Visible    ${PRODUCTION_MENU}    timeout=15s
    Mouse Over    ${PRODUCTION_MENU}
    Sleep    1s

Click On Field Report Menu
    Wait Until Element Is Visible    ${FIELD_REPORT_MENU}    timeout=15s
    Click Element    ${FIELD_REPORT_MENU}
