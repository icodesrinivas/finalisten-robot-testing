*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}       xpath=//*[@id="register"]
${CONTACTS_MENU}       xpath=//*[@id="contacts_app_menu"]
${ADD_CONTACT_BTN}     xpath=//*[@id="id_add_contact"]

*** Test Cases ***
Verify Contact Create Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Contacts Menu
    Wait Until Page Contains    Filters    timeout=10s
    Log To Console    "Filters text found. Contact list opened successfully."
    Click Element    ${ADD_CONTACT_BTN}
    Wait Until Page Contains    CONTACT DATA    timeout=10s
    Log To Console    "CONTACT DATA found. Contact Create page opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Contacts Menu
    Click Element    ${CONTACTS_MENU}
