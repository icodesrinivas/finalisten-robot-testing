*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}               xpath=//*[@id="register"]
${SUBCONTRACTOR_MENU}          xpath=//*[@id="subcontractor_app_menu"]
${SUBCONTRACTOR_ROW}           css=tr.subcontractor_rows

*** Test Cases ***
Verify Subcontractor Edit Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Subcontractor Menu
    Wait Until Page Contains    Filters    timeout=10s
    Wait Until Element Is Visible    ${SUBCONTRACTOR_ROW}    timeout=10s
    Click Element    ${SUBCONTRACTOR_ROW}
    Wait Until Page Contains    SUBCONTRACTOR    timeout=10s
    Log To Console    "SUBCONTRACTOR text found. Subcontractor edit page opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Subcontractor Menu
    Click Element    ${SUBCONTRACTOR_MENU}
