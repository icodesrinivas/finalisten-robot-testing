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
    Sleep    3s
    Wait Until Element Is Visible    ${FIELD_REPORT_ADD_BUTTON}    timeout=20s
    ${btn_found}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${FIELD_REPORT_ADD_BUTTON}    timeout=5s
    IF    ${btn_found}
        Click On Field Report Add Button
    ELSE
        Log To Console    ⚠ Add button not found. Navigating directly to create URL.
        Go To    https://preproderp.finalisten.se/fieldreport/create/
    END
    Wait Until Page Contains    FIELD REPORT    timeout=15s
    Log To Console    "FIELD REPORT text found. Create view opened successfully."
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

Click On Field Report Add Button
    Wait Until Element Is Visible    ${FIELD_REPORT_ADD_BUTTON}    timeout=15s
    Click Element    ${FIELD_REPORT_ADD_BUTTON}
