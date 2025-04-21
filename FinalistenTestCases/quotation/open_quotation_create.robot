*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${ADMIN_MENU}                      xpath=//*[@id="admin"]
${QUOTATION_LIST_MENU}            xpath=//*[@id="quotation_list_app_menu"]
${ADD_QUOTATION_BUTTON}           xpath=//*[@id="id_add_quotation"]
${QUOTATION_CREATE_TEXT}          QUOTATION

*** Test Cases ***
Verify Quotation Create Page Opens Successfully
    Open And Login
    Hover Over Admin Menu
    Click On Quotation List Menu
    Wait Until Page Contains    Filters    timeout=10s
    Click On Add Quotation Button
    Wait Until Page Contains    ${QUOTATION_CREATE_TEXT}    timeout=10s
    Log To Console    "QUOTATION text found. Quotation create page opened successfully."
    Close Browser

*** Keywords ***
Hover Over Admin Menu
    Mouse Over    ${ADMIN_MENU}

Click On Quotation List Menu
    Click Element    ${QUOTATION_LIST_MENU}

Click On Add Quotation Button
    Click Element    ${ADD_QUOTATION_BUTTON}
