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
    Mouse Over    ${REGISTER_MENU}

Click On Customers Menu
    Click Element    ${CUSTOMERS_MENU}
