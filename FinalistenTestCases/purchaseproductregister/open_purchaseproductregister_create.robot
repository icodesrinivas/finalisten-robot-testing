*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}                               xpath=//*[@id="register"]
${PURCHASE_PRODUCT_REGISTER_MENU}             xpath=//*[@id="purchase_product_register_app_menu"]
${PURCHASE_PRODUCT_REGISTER_ADD_BUTTON}       xpath=//a[@href="/purchaseproductregister/create/" and @title="Add New Purchase Product"]

*** Test Cases ***
Verify Purchase Product Register Create Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Purchase Product Register Menu
    Click On Purchase Product Register Add Button
    Wait Until Page Contains    PURCHASE PRODUCT REGISTER    timeout=10s
    Log To Console    "PURCHASE PRODUCT REGISTER text found. Create view opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Purchase Product Register Menu
    Click Element    ${PURCHASE_PRODUCT_REGISTER_MENU}

Click On Purchase Product Register Add Button
    Click Element    ${PURCHASE_PRODUCT_REGISTER_ADD_BUTTON}
