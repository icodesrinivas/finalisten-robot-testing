*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}                                      xpath=//*[@id="register"]
${PURCHASE_PRODUCT_REGISTER_MENU}                    xpath=//*[@id="purchase_product_register_app_menu"]
${PURCHASE_PRODUCT_REGISTER_ROW}                     css=tr.purchase_product_register_rows

*** Test Cases ***
Verify Purchase Product Register Edit Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Purchase Product Register Menu
    Wait Until Page Contains    Filters    timeout=15s
    Wait Until Element Is Visible    ${PURCHASE_PRODUCT_REGISTER_ROW}    timeout=15s
    Click Element    ${PURCHASE_PRODUCT_REGISTER_ROW}
    Wait Until Page Contains    PURCHASE PRODUCT REGISTER    timeout=10s
    Log To Console    "PURCHASE PRODUCT REGISTER text found. Edit view opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Wait Until Page Contains Element    ${REGISTER_MENU}    timeout=20s
    Execute Javascript    var el = document.getElementById('register'); if(el) el.scrollIntoView({behavior: 'smooth', block: 'center'});
    Sleep    2s
    Wait Until Element Is Visible    ${REGISTER_MENU}    timeout=15s
    Mouse Over    ${REGISTER_MENU}
    Sleep    1s

Click On Purchase Product Register Menu
    Wait Until Element Is Visible    ${PURCHASE_PRODUCT_REGISTER_MENU}    timeout=15s
    Click Element    ${PURCHASE_PRODUCT_REGISTER_MENU}
