*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}                        xpath=//*[@id="register"]
${PRODUCT_REGISTER_MENU}               xpath=//*[@id="product_register_app_menu"]

*** Test Cases ***
Verify Product Register List Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Product Register Menu
    Wait Until Page Contains    Filters    timeout=10s
    Log To Console    "Filters text found. Product Register list view opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Product Register Menu
    Click Element    ${PRODUCT_REGISTER_MENU}
