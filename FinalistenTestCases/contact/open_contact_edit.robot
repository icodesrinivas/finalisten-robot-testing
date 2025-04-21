*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}         xpath=//*[@id="register"]
${CONTACTS_MENU}         xpath=//*[@id="contacts_app_menu"]
${EDIT_CONTACT_BUTTON}   xpath=//*[@id="DataTables_Table_0"]/tbody/tr/td[7]/a

*** Test Cases ***
Verify Edit Contact Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Contacts Menu
    Wait Until Page Contains    Filters    timeout=10s
    Log To Console    "Filters text found. Contact list opened successfully."
    Click Element    ${EDIT_CONTACT_BUTTON}
    Wait Until Page Contains    CONTACT DATA    timeout=10s
    Log To Console    "CONTACT DATA text found. Edit Contact page opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Contacts Menu
    Click Element    ${CONTACTS_MENU}
