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
        Sleep    1s
        ${board_element}=    Get WebElement    xpath=//*[@id="${board_name}"]
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${board_element}
        Wait Until Page Contains    ${NOT_PLANNED_TASKS_TEXT}    timeout=15s
        Log To Console    "${board_name} board opened successfully and contains 'Not Planned Tasks'."
        Go Back
        Sleep    2s
    END
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Wait Until Page Contains Element    ${PRODUCTION_MENU}    timeout=20s
    Execute Javascript    var el = document.getElementById('production'); if(el) el.scrollIntoView({behavior: 'smooth', block: 'center'});
    Sleep    2s
    Wait Until Element Is Visible    ${PRODUCTION_MENU}    timeout=15s
    Mouse Over    ${PRODUCTION_MENU}
    Sleep    1s

Hover Over Daily Planner Menu
    Wait Until Element Is Visible    ${DAILY_PLANNER_MENU}    timeout=15s
    Mouse Over    ${DAILY_PLANNER_MENU}
    Sleep    1s
