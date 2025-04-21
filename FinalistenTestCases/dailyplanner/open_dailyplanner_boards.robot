*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_MENU}                xpath=//*[@id="production"]
${DAILY_PLANNER_MENU}            xpath=//*[@id="daily_planner_app_menu"]
${SUBBOARD_MENU_PATTERN}         xpath=//a[starts-with(@id, "board_")]
${NOT_PLANNED_TASKS_TEXT}        Not Planned Tasks

*** Test Cases ***
Verify All Daily Planner Boards Open Successfully
    Open And Login
    Hover Over Production Menu
    Hover Over Daily Planner Menu
    ${boards}=    Get WebElements    ${SUBBOARD_MENU_PATTERN}
    FOR    ${board}    IN    @{boards}
        ${board_name}=    Get Element Attribute    ${board}    id
        Hover Over Production Menu
        Hover Over Daily Planner Menu
        Click Element    xpath=//*[@id="${board_name}"]
        Wait Until Page Contains    ${NOT_PLANNED_TASKS_TEXT}    timeout=10s
        Log To Console    "${board_name} board opened successfully and contains 'Not Planned Tasks'."
        Go Back
        Sleep    1s
    END
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Mouse Over    ${PRODUCTION_MENU}

Hover Over Daily Planner Menu
    Mouse Over    ${DAILY_PLANNER_MENU}
