*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}     xpath=//*[@id="register"]
${CUSTOMERS_MENU}    xpath=//*[@id="customers_app_menu"]

*** Test Cases ***
Verify Customer List Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Customers Menu
    Wait Until Page Contains    Filters    timeout=10s
    Log To Console    "Filters text found. Customer list opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Wait Until Element Is Visible    ${REGISTER_MENU}    timeout=15s
    Sleep    1s
    Mouse Over    ${REGISTER_MENU}

Click On Customers Menu
    Wait Until Element Is Visible    ${CUSTOMERS_MENU}    timeout=10s
    Click Element    ${CUSTOMERS_MENU}
    Sleep    2s
