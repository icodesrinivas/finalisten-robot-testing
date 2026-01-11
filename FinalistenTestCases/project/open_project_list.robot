*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_MENU}                xpath=//*[@id="production"]
${PROJECT_MENU}                   xpath=//*[@id="project_app_menu"]

*** Test Cases ***
Verify Project List View Opens Successfully
    Open And Login
    Hover Over Production Menu
    Click On Project Menu
    Sleep    2s
    Wait Until Page Contains Element    xpath=//*[@id="project_list_filter"]    timeout=10s
    Log To Console    "Project list page loaded successfully."
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Mouse Over    ${PRODUCTION_MENU}

Click On Project Menu
    Click Element    ${PROJECT_MENU}
