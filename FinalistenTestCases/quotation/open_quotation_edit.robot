*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${ADMIN_MENU}                      xpath=//*[@id="admin"]
${QUOTATION_LIST_MENU}            xpath=//*[@id="quotation_list_app_menu"]
${QUOTATION_EDIT_LINKS}           xpath=//a[@class="open-quotation-edit"]
${QUOTATION_EDIT_TEXT}            QUOTATION

*** Test Cases ***
Verify Quotation Edit Page Opens Successfully
    Open And Login
    Hover Over Admin Menu
    Click On Quotation List Menu
    Wait Until Page Contains    Filters    timeout=10s
    Click First Available Quotation Edit Link
    Wait Until Page Contains    ${QUOTATION_EDIT_TEXT}    timeout=10s
    Log To Console    "QUOTATION text found. Quotation edit page opened successfully."
    Close Browser

*** Keywords ***
Hover Over Admin Menu
    Mouse Over    ${ADMIN_MENU}

Click On Quotation List Menu
    Click Element    ${QUOTATION_LIST_MENU}

Click First Available Quotation Edit Link
    Wait Until Element Is Visible    ${QUOTATION_EDIT_LINKS}    timeout=15s
    Sleep    1s
    Scroll Element Into View    ${QUOTATION_EDIT_LINKS}
    Wait Until Element Is Enabled    ${QUOTATION_EDIT_LINKS}    timeout=5s
    Click Element    xpath=(//a[@class="open-quotation-edit"])[1]
