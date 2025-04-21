*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}               xpath=//*[@id="register"]
${SUBCONTRACTOR_MENU}          xpath=//*[@id="subcontractor_app_menu"]
${EDIT_BUTTON}                 xpath=//a[contains(@class, 'btn-success-small') and contains(@title, 'Edit')]

*** Test Cases ***
Verify Subcontractor Edit Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Subcontractor Menu
    Wait Until Page Contains    Filters    timeout=10s
    Click First Edit Button
    Wait Until Page Contains    SUBCONTRACTOR    timeout=10s
    Log To Console    "SUBCONTRACTOR text found. Subcontractor edit page opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Subcontractor Menu
    Click Element    ${SUBCONTRACTOR_MENU}

Click First Edit Button
    Wait Until Element Is Visible    ${EDIT_BUTTON}    5s
    Click Element    ${EDIT_BUTTON}
