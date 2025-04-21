*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_MENU}                xpath=//*[@id="production"]
${DAILY_PLANNER_MENU}            xpath=//*[@id="daily_planner_app_menu"]
${DAILY_PLANNER_TEXT}           Kanban Board

*** Test Cases ***
Verify Daily Planner Board Opens Successfully
    Open And Login
    Hover Over Production Menu
    Double Click On Daily Planner Menu
    Wait Until Page Contains    ${DAILY_PLANNER_TEXT}    timeout=10s
    Log To Console    "Kanban Board text found. Daily Planner board opened successfully."
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Mouse Over    ${PRODUCTION_MENU}

Double Click On Daily Planner Menu
    Double Click Element    ${DAILY_PLANNER_MENU}
