*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${ADMIN_MENU}                      xpath=//*[@id="admin"]
${QUOTATION_LIST_MENU}            xpath=//*[@id="quotation_list_app_menu"]
${QUOTATION_ROW}                  css=tr.quotation_rows
${QUOTATION_EDIT_TEXT}            QUOTATION

*** Test Cases ***
Verify Quotation Edit Page Opens Successfully
    Open And Login
    Hover Over Admin Menu
    Click On Quotation List Menu
    Wait Until Page Contains    Filters    timeout=10s
    Log To Console    "Filters text found. Quotation list opened successfully."
    ${row_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${QUOTATION_ROW}    timeout=5s
    Run Keyword If    ${row_exists}    Click Quotation Row And Verify
    ...    ELSE    Log To Console    "No quotation records found. Skipping edit test."
    Close Browser

*** Keywords ***
Hover Over Admin Menu
    Mouse Over    ${ADMIN_MENU}

Click On Quotation List Menu
    Click Element    ${QUOTATION_LIST_MENU}

Click Quotation Row And Verify
    Click Element    ${QUOTATION_ROW}
    Wait Until Page Contains    ${QUOTATION_EDIT_TEXT}    timeout=10s
    Log To Console    "QUOTATION text found. Quotation edit page opened successfully."
