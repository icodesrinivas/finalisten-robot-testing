*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}                        xpath=//*[@id="register"]
${PRODUCT_REGISTER_MENU}               xpath=//*[@id="product_register_app_menu"]
${PRODUCT_REGISTER_ADD_BUTTON}         xpath=//a[@href="/products/create/" and @title="Add New Product"]

*** Test Cases ***
Verify Product Register Create Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Product Register Menu
    Click On Product Register Add Button
    Wait Until Page Contains    SALES PRODUCT    timeout=10s
    Log To Console    "SALES PRODUCT text found. Create view opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Product Register Menu
    Click Element    ${PRODUCT_REGISTER_MENU}

Click On Product Register Add Button
    Click Element    ${PRODUCT_REGISTER_ADD_BUTTON}
