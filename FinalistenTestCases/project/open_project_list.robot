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
    Wait Until Page Contains    Filters    timeout=10s
    Log To Console    "Filters text found. Project list view opened successfully."
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Mouse Over    ${PRODUCTION_MENU}

Click On Project Menu
    Click Element    ${PROJECT_MENU}
