*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}               xpath=//*[@id="register"]
${SUPPLIER_MENU}               xpath=//*[@id="supplier_list_app_menu"]
${SUPPLIER_ROW}                css=tr.supplier_rows

*** Test Cases ***
Verify Supplier Edit Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Supplier Menu
    Wait Until Page Contains    Filters    timeout=10s
    Wait Until Element Is Visible    ${SUPPLIER_ROW}    timeout=10s
    Click Element    ${SUPPLIER_ROW}
    Wait Until Page Contains    SUPPLIER    timeout=10s
    Log To Console    "SUPPLIER text found. Supplier edit page opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Wait Until Element Is Visible    ${REGISTER_MENU}    timeout=15s
    Sleep    1s
    Mouse Over    ${REGISTER_MENU}

Click On Supplier Menu
    Click Element    ${SUPPLIER_MENU}
