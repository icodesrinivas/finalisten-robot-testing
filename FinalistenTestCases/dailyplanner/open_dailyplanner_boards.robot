*** Settings ***
Library    SeleniumLibrary
Library    Collections
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Variables ***
${BOARD_LINK}                css=.board_container a
${NOT_PLANNED_TASKS_TEXT}    Not Planned Tasks

*** Test Cases ***
Verify All Daily Planner Boards Open Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Daily Planner Home
    Wait Until Page Contains Element    ${BOARD_LINK}    timeout=30s
    ${boards}=    Get WebElements    ${BOARD_LINK}
    ${count}=    Get Length    ${boards}
    Should Be True    ${count} > 0    msg=No kanban boards found on daily planner home
    FOR    ${index}    IN RANGE    ${count}
        Navigate To Daily Planner Home
        ${boards}=    Get WebElements    ${BOARD_LINK}
        ${board}=    Get From List    ${boards}    ${index}
        ${board_name}=    Get Text    ${board}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${board}
        Wait Until Page Contains    ${NOT_PLANNED_TASKS_TEXT}    timeout=30s
        Log To Console    "${board_name}" board opened successfully and contains 'Not Planned Tasks'."
    END
    Close Browser
