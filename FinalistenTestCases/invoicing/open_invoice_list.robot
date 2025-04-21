*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${ADMIN_MENU}                      xpath=//*[@id="admin"]
${INVOICE_LIST_MENU}              xpath=//*[@id="invoice_list_app_menu"]
${FILTERS_TEXT}                   Filters

*** Test Cases ***
Verify Invoice List View Opens Successfully
    Open And Login
    Hover Over Admin Menu
    Click On Invoice List Menu
    Wait Until Page Contains    ${FILTERS_TEXT}    timeout=10s
    Log To Console    "Filters text found. Invoice List View opened successfully."
    Close Browser

*** Keywords ***
Hover Over Admin Menu
    Mouse Over    ${ADMIN_MENU}

Click On Invoice List Menu
    Click Element    ${INVOICE_LIST_MENU}
