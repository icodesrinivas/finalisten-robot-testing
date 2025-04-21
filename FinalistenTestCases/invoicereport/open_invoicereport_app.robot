*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REPORTS_MENU}                  xpath=//*[@id="reports"]
${INVOICE_REPORT_MENU}          xpath=//*[@id="invoice_report_app_menu"]
${INVOICE_REPORT_TEXT}          List Of Projects

*** Test Cases ***
Verify Project Report App Opens Successfully
    Open And Login
    Hover Over Reports Menu
    Click On Invoice Report Menu
    Wait Until Page Contains    ${INVOICE_REPORT_TEXT}    timeout=10s
    Log To Console    "List Of Projects found. Invoice Report App opened successfully."
    Close Browser

*** Keywords ***
Hover Over Reports Menu
    Mouse Over    ${REPORTS_MENU}

Click On Invoice Report Menu
    Click Element    ${INVOICE_REPORT_MENU}
