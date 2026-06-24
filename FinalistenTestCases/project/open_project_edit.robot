*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Variables ***
${PROJECT_ROW}    css=tr.project_rows

*** Test Cases ***
Verify Project Edit View Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Project List
    Wait Until Element Is Visible    ${PROJECT_ROW}    timeout=20s
    ${row}=    Get WebElement    ${PROJECT_ROW}
    Execute Javascript    arguments[0].scrollIntoView({block: 'center'});    ARGUMENTS    ${row}
    Double Click Element    ${PROJECT_ROW}
    Wait Until Page Contains    GENERAL DATA    timeout=30s
    Log To Console    "Project edit view opened successfully."
    Close Browser
