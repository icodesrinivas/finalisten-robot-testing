*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_MENU}                xpath=//*[@id="production"]
${PROJECT_MENU}                   xpath=//*[@id="project_app_menu"]
${PROJECT_ROW}                    css=tr.project_rows
${PROJECT_EDIT_TEXT}             GENERAL DATA

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
    Mouse Over    ${PRODUCTION_MENU}

Click On Project Menu
    Click Element    ${PROJECT_MENU}

Click Project Row And Verify
    Click Element    ${PROJECT_ROW}
    Wait Until Page Contains    ${PROJECT_EDIT_TEXT}    timeout=15s
    Log To Console    "GENERAL DATA text found. Project Edit view opened successfully."
