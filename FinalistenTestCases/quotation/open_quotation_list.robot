*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${ADMIN_MENU}                      xpath=//*[@id="admin"]
${QUOTATION_LIST_MENU}            xpath=//*[@id="quotation_list_app_menu"]
${QUOTATION_LIST_TEXT}            Filters

*** Test Cases ***
Verify Quotation List View Opens Successfully
    Open And Login
    Hover Over Admin Menu
    Click On Quotation List Menu
    Wait Until Page Contains    ${QUOTATION_LIST_TEXT}    timeout=10s
    Log To Console    "Filters text found. Quotation list view opened successfully."
    Close Browser

*** Keywords ***
Hover Over Admin Menu
    Mouse Over    ${ADMIN_MENU}

Click On Quotation List Menu
    Click Element    ${QUOTATION_LIST_MENU}
