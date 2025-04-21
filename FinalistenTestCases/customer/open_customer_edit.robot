*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}      xpath=//*[@id="register"]
${CUSTOMERS_MENU}     xpath=//*[@id="customers_app_menu"]
${EDIT_CUSTOMER_BTN}  xpath=//a[contains(@href, "/account/customers/") and contains(@href, "/edit/")]

*** Test Cases ***
Verify Customer Edit Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Customers Menu
    Wait Until Page Contains    Filters    timeout=10s
    Click On Edit Customer Button
    Wait Until Page Contains    CUSTOMER DATA    timeout=10s
    Log To Console    "CUSTOMER DATA found. Customer edit page opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Customers Menu
    Click Element    ${CUSTOMERS_MENU}

Click On Edit Customer Button
    Click Element    ${EDIT_CUSTOMER_BTN}
