*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}               xpath=//*[@id="register"]
${SUPPLIER_MENU}               xpath=//*[@id="supplier_list_app_menu"]

*** Test Cases ***
Verify Supplier List Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Supplier Menu
    Wait Until Page Contains    Filters    timeout=10s
    Log To Console    "Filters text found. Supplier list page opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Supplier Menu
    Click Element    ${SUPPLIER_MENU}
