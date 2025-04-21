*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_MENU}                   xpath=//*[@id="production"]
${DOOR_PLANNING_MENU}               xpath=//*[@id="doorplanning_app_menu"]

*** Test Cases ***
Verify Door Planning Board Opens Successfully
    Open And Login
    Hover Over Production Menu
    Click On Door Planning Menu
    Wait Until Page Contains    Sales Week    timeout=10s
    Log To Console    "Sales Week text found. Door Planning Board opened successfully."
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Mouse Over    ${PRODUCTION_MENU}

Click On Door Planning Menu
    Click Element    ${DOOR_PLANNING_MENU}
