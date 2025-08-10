*** Settings ***
Library    SeleniumLibrary
Library    DateTime
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
    Click Filter Frame
    ${invoice_element}=    Search For Invoice Records And Click First Edit Link
    Run Keyword If    ${invoice_element}    Click Element    ${invoice_element}
    ...    ELSE    Fail    No invoice records found for the last 2 months.
    Wait Until Page Contains    ${INVOICE_EDIT_TEXT}    timeout=10s
    Log To Console    "Invoice Report text found. Invoice Edit View opened successfully."
    Close Browser

*** Keywords ***
Hover Over Admin Menu
    Mouse Over    ${ADMIN_MENU}

Click On Invoice List Menu
    Click Element    ${INVOICE_LIST_MENU}

Click Completed Invoice Checkbox
    Click Element    xpath=//*[@id="id_invoice_status_input" and @value="completed"]
    Wait Until Element Is Enabled    xpath=//*[@id="invoicereport_list_search"]

Click Search Button
    ${element}=    Get Webelement    xpath=//*[@id="invoicereport_list_search"]
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${element}

Search For Invoice Records And Click First Edit Link
    ${initial_date_two_months_ago}=    Add Time To Date    ${{datetime.date.today()}}    -60 days    result_format=%Y-%m-%d

    Click Completed Invoice Checkbox
    Log To Console    Searching for invoices with start date: ${initial_date_two_months_ago}
    Input Text    id=start_work_date    ${initial_date_two_months_ago}
    Click Search Button
    Sleep    2s    # Give some time for the search results to load

    ${elements}=    Get WebElements    ${INVOICE_LINK}
    ${length}=    Get Length    ${elements}

    IF    ${length} > 0
        Log To Console    Found ${length} invoice records.
        Return From Keyword    ${elements[0]}
    ELSE
        Log To Console    No invoice records found for the last 2 months.
        Return From Keyword    ${None}
    END

Click Filter Frame
    Click Element    xpath=//*[@id="invoicereport_list_filter"]
    Sleep    3s
    Wait Until Element Is Visible    xpath=//*[@id="id_invoice_status_input"]



