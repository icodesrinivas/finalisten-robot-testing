*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}                                      xpath=//*[@id="register"]
${PURCHASE_PRODUCT_REGISTER_MENU}                    xpath=//*[@id="purchase_product_register_app_menu"]
${PURCHASE_PRODUCT_REGISTER_FIRST_EDIT_LINK}         xpath=//a[contains(@class, "open-purchase-product-register-edit")]

*** Test Cases ***
Verify Purchase Product Register Edit Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Purchase Product Register Menu
    Click On First Purchase Product Register Edit Link
    Wait Until Page Contains    PURCHASE PRODUCT REGISTER    timeout=10s
    Log To Console    "PURCHASE PRODUCT REGISTER text found. Edit view opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Purchase Product Register Menu
    Click Element    ${PURCHASE_PRODUCT_REGISTER_MENU}

Click On First Purchase Product Register Edit Link
    Click Element    ${PURCHASE_PRODUCT_REGISTER_FIRST_EDIT_LINK}
