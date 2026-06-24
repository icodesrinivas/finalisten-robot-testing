*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Daily Planner Board Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Daily Planner Home
    Wait Until Page Contains    Kanban Board    timeout=20s
    Log To Console    "Daily planner home opened successfully."
    Close Browser
