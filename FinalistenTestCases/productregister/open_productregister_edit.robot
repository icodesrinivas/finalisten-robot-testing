*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}                        xpath=//*[@id="register"]
${PRODUCT_REGISTER_MENU}               xpath=//*[@id="product_register_app_menu"]
${PRODUCT_REGISTER_EDIT_LINK}          xpath=//a[contains(@class, "open-product-register-edit")]

*** Test Cases ***
Verify Product Register Edit Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Product Register Menu
    Click On Product Register Edit Link
    Wait Until Page Contains    SALES PRODUCT    timeout=10s
    Log To Console    "SALES PRODUCT text found. Edit view opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Product Register Menu
    Click Element    ${PRODUCT_REGISTER_MENU}

Click On Product Register Edit Link
    Wait Until Element Is Visible    ${PRODUCT_REGISTER_EDIT_LINK}    timeout=10s
    Click Element    ${PRODUCT_REGISTER_EDIT_LINK}
