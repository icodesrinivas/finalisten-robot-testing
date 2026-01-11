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
    Wait Until Page Contains    Filters    timeout=10s
    Wait Until Element Is Visible    ${PROJECT_ROW}    timeout=10s
    Click Element    ${PROJECT_ROW}
    Wait Until Page Contains    ${PROJECT_EDIT_TEXT}    timeout=10s
    Log To Console    "GENERAL DATA text found. Project Edit view opened successfully."
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Mouse Over    ${PRODUCTION_MENU}

Click On Project Menu
    Click Element    ${PROJECT_MENU}
