*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_MENU}                   xpath=//*[@id="production"]
${RESOURCE_PLANNING_MENU}            xpath=//*[@id="resourceplanning_app_menu"]

*** Test Cases ***
Verify Resource Planning Board Opens Successfully
    Open And Login
    Hover Over Production Menu
    Click On Resource Planning Menu
    Wait Until Page Contains    Sales Week    timeout=10s
    Log To Console    "Sales Week text found. Resource Planning Board opened successfully."
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Mouse Over    ${PRODUCTION_MENU}

Click On Resource Planning Menu
    Click Element    ${RESOURCE_PLANNING_MENU}
