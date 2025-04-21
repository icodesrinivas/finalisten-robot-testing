*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}                            xpath=//*[@id="register"]
${PURCHASE_PRODUCT_REGISTER_MENU}          xpath=//*[@id="purchase_product_register_app_menu"]

*** Test Cases ***
Verify Purchase Product Register List View Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Purchase Product Register Menu
    Wait Until Page Contains    Filters    timeout=10s
    Log To Console    "Filters text found. Purchase Product Register list view opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Purchase Product Register Menu
    Click Element    ${PURCHASE_PRODUCT_REGISTER_MENU}
