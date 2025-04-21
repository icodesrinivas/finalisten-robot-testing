*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${ADMIN_MENU}                      xpath=//*[@id="admin"]
${INVOICE_LIST_MENU}              xpath=//*[@id="invoice_list_app_menu"]
${INVOICE_LINK}                   xpath=//a[contains(@class, "open-invoice-edit")]
${INVOICE_EDIT_TEXT}             Invoice Report

*** Test Cases ***
Verify Invoice Edit View Opens Successfully
    Open And Login
    Hover Over Admin Menu
    Click On Invoice List Menu
    Wait Until Element Is Visible    ${INVOICE_LINK}    timeout=10s
    Click Element    ${INVOICE_LINK}
    Wait Until Page Contains    ${INVOICE_EDIT_TEXT}    timeout=10s
    Log To Console    "Invoice Report text found. Invoice Edit View opened successfully."
    Close Browser

*** Keywords ***
Hover Over Admin Menu
    Mouse Over    ${ADMIN_MENU}

Click On Invoice List Menu
    Click Element    ${INVOICE_LIST_MENU}
