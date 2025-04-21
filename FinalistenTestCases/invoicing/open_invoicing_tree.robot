*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${ADMIN_MENU}                    xpath=//*[@id="admin"]
${INVOICING_MENU}               xpath=//*[@id="invoicing_app_menu"]
${FILTERS_TEXT}                 Filters

*** Test Cases ***
Verify Invoicing App Opens Successfully
    Open And Login
    Hover Over Admin Menu
    Click On Invoicing Menu
    Wait Until Page Contains    ${FILTERS_TEXT}    timeout=10s
    Log To Console    "Filters text found. Invoicing app opened successfully."
    Close Browser

*** Keywords ***
Hover Over Admin Menu
    Mouse Over    ${ADMIN_MENU}

Click On Invoicing Menu
    Click Element    ${INVOICING_MENU}
