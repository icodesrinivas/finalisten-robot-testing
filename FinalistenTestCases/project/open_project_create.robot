*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_MENU}                xpath=//*[@id="production"]
${PROJECT_MENU}                   xpath=//*[@id="project_app_menu"]
${PROJECT_ADD_BUTTON}            xpath=//a[@href="/projects/create/" and @title="Add New Project"]
${PROJECT_CREATE_TEXT}           GENERAL DATA

*** Test Cases ***
Verify Project Create View Opens Successfully
    Open And Login
    Hover Over Production Menu
    Click On Project Menu
    Wait Until Page Contains    Filters    timeout=10s
    Click On Project Add Button
    Wait Until Page Contains    ${PROJECT_CREATE_TEXT}    timeout=10s
    Log To Console    "GENERAL DATA text found. Project Create view opened successfully."
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Mouse Over    ${PRODUCTION_MENU}

Click On Project Menu
    Click Element    ${PROJECT_MENU}

Click On Project Add Button
    Click Element    ${PROJECT_ADD_BUTTON}
