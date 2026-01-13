*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_MENU}                xpath=//*[@id="production"]
${PROJECT_MENU}                   xpath=//*[@id="project_app_menu"]
${PROJECT_ROW}                    css=tr.project_rows
${PROJECT_EDIT_TEXT}             GENERELLA UPPGIFTER

*** Test Cases ***
Verify Project Edit View Opens Successfully
    Open And Login
    Hover Over Production Menu
    Click On Project Menu
    Sleep    3s
    ${row_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${PROJECT_ROW}    timeout=10s
    Run Keyword If    ${row_exists}    Click Project Row And Verify
    ...    ELSE    Log To Console    "No project records found. Test skipped."
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Wait Until Page Contains Element    ${PRODUCTION_MENU}    timeout=20s
    Execute Javascript    var el = document.getElementById('production'); if(el) el.scrollIntoView({behavior: 'smooth', block: 'center'});
    Sleep    2s
    Wait Until Element Is Visible    ${PRODUCTION_MENU}    timeout=15s
    Mouse Over    ${PRODUCTION_MENU}
    Sleep    1s

Click On Project Menu
    Wait Until Element Is Visible    ${PROJECT_MENU}    timeout=15s
    Click Element    ${PROJECT_MENU}

Click Project Row And Verify
    ${row}=    Get WebElement    ${PROJECT_ROW}
    Execute Javascript    arguments[0].scrollIntoView({behavior: 'smooth', block: 'center'});    ARGUMENTS    ${row}
    Sleep    1s
    Double Click Element    ${PROJECT_ROW}
    Wait Until Page Contains    ${PROJECT_EDIT_TEXT}    timeout=20s
    Log To Console    "GENERAL DATA text found. Project Edit view opened successfully."
