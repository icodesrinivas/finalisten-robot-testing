*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}             xpath=//*[@id="register"]
${SUBCONTRACTOR_MENU}        xpath=//*[@id="subcontractor_app_menu"]
${ADD_SUBCONTRACTOR_BUTTON}  xpath=//*[@id="id_add_subcontractor"]

*** Test Cases ***
Verify Subcontractor Create Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Subcontractor Menu
    Wait Until Page Contains    Filters    timeout=10s
    Click Element    ${ADD_SUBCONTRACTOR_BUTTON}
    Wait Until Page Contains    SUBCONTRACTOR    timeout=10s
    Log To Console    "Subcontractor create page opened and SUBCONTRACTOR text found."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Subcontractor Menu
    Click Element    ${SUBCONTRACTOR_MENU}
