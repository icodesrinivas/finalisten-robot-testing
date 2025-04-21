*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}               xpath=//*[@id="register"]
${SUPPLIER_MENU}               xpath=//*[@id="supplier_list_app_menu"]
${SUPPLIER_EDIT_LINK}          xpath=//a[contains(@class, 'open-supplier-edit')]

*** Test Cases ***
Verify Supplier Edit Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Supplier Menu
    Wait Until Page Contains Element    ${SUPPLIER_EDIT_LINK}    timeout=10s
    Click Element    ${SUPPLIER_EDIT_LINK}
    Wait Until Page Contains    SUPPLIER    timeout=10s
    Log To Console    "SUPPLIER text found. Supplier edit page opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Supplier Menu
    Click Element    ${SUPPLIER_MENU}
