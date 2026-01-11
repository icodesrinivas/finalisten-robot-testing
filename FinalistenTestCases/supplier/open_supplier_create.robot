*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}               xpath=//*[@id="register"]
${SUPPLIER_MENU}               xpath=//*[@id="supplier_list_app_menu"]
${ADD_SUPPLIER_BUTTON}         xpath=//*[@id="id_add_supplier"]

*** Test Cases ***
Verify Supplier Create Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Supplier Menu
    Wait Until Page Contains    Filters    timeout=10s
    Click Add Supplier Button
    Wait Until Page Contains    SUPPLIER    timeout=10s
    Log To Console    "SUPPLIER text found. Supplier create page opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Wait Until Element Is Visible    ${REGISTER_MENU}    timeout=30s
    Sleep    1s
    Mouse Over    ${REGISTER_MENU}

Click On Supplier Menu
    Click Element    ${SUPPLIER_MENU}

Click Add Supplier Button
    Click Element    ${ADD_SUPPLIER_BUTTON}
