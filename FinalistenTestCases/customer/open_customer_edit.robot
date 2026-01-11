*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}      xpath=//*[@id="register"]
${CUSTOMERS_MENU}     xpath=//*[@id="customers_app_menu"]
${CUSTOMER_ROW}       css=tr.customer_rows

*** Test Cases ***
Verify Customer Edit Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Customers Menu
    Wait Until Page Contains    Filters    timeout=10s
    Wait Until Element Is Visible    ${CUSTOMER_ROW}    timeout=10s
    Click Element    ${CUSTOMER_ROW}
    Wait Until Page Contains    CUSTOMER DATA    timeout=10s
    Log To Console    "CUSTOMER DATA found. Customer edit page opened successfully."
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
