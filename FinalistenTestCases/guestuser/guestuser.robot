*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}             xpath=//*[@id="register"]
${SUBCONTRACTOR_MENU}        xpath=//*[@id="subcontractor_app_menu"]
${SUBCONTRACTOR_LINKS}       xpath=//a[contains(@href, '/subcontractor/list/') and contains(@href, '/edit/')]

*** Test Cases ***
Verify Subcontractor Edit Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Subcontractor Menu
    Wait Until Page Contains    Filters    timeout=10s
    Click First Subcontractor Edit Link
    Wait Until Page Contains    SUBCONTRACTOR    timeout=10s
    Log To Console    "SUBCONTRACTOR text found. Subcontractor edit page opened successfully."

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Subcontractor Menu
    Click Element    ${SUBCONTRACTOR_MENU}

Click First Subcontractor Edit Link
    ${elements}=    Get WebElements    ${SUBCONTRACTOR_LINKS}
    ${length}=    Get Length    ${elements}
    Run Keyword If    ${length} == 0    Fail    No subcontractors found to edit.
    ${element}=    Set Variable    ${elements[0]}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${element}