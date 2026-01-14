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
    IF    $invoice_element
        Execute Javascript    arguments[0].scrollIntoView({block: "center"});    ARGUMENTS    ${invoice_element}
        Sleep    1s
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${invoice_element}
    ELSE
        Fail    No invoice records found.
    END
    Wait Until Page Contains    ${INVOICE_EDIT_TEXT}    timeout=10s
    Log To Console    "Invoice Report text found. Invoice Edit View opened successfully."
    Close Browser

*** Keywords ***
Hover Over Admin Menu
    Wait Until Page Contains Element    ${ADMIN_MENU}    timeout=20s
    Execute Javascript    var el = document.getElementById('admin'); if(el) el.scrollIntoView({behavior: 'smooth', block: 'center'});
    Sleep    2s
    Wait Until Element Is Visible    ${ADMIN_MENU}    timeout=15s
    Mouse Over    ${ADMIN_MENU}
    Sleep    1s

Click On Invoice List Menu
    Wait Until Element Is Visible    ${INVOICE_LIST_MENU}    timeout=10s
    Click Element    ${INVOICE_LIST_MENU}
    Sleep    3s

Click Completed Invoice Checkbox
    Click Element    xpath=//*[@id="id_invoice_status_input" and @value="completed"]
    Wait Until Element Is Enabled    xpath=//*[@id="invoicereport_list_search"]

Click Search Button
    ${element}=    Get Webelement    xpath=//*[@id="invoicereport_list_search"]
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${element}

Search For Invoice Records And Click First Edit Link
    ${initial_date_one_year_ago}=    Add Time To Date    ${{datetime.date.today()}}    -365 days    result_format=%Y-%m-%d

    Click Completed Invoice Checkbox
    Log To Console    Searching for invoices with start date: ${initial_date_one_year_ago}
    Input Text    id=start_work_date    ${initial_date_one_year_ago}
    Click Search Button
    Sleep    2s    # Give some time for the search results to load

    ${elements}=    Get WebElements    ${INVOICE_LINK}
    ${length}=    Get Length    ${elements}

    IF    ${length} > 0
        Log To Console    Found ${length} invoice records.
        Return From Keyword    ${elements[0]}
    ELSE
        Log To Console    No invoice records found for the last 1 year. Trying to clear date filter and search again...
        Clear Element Text    id=start_work_date
        Click Search Button
        Sleep    3s
        ${elements}=    Get WebElements    ${INVOICE_LINK}
        ${length}=    Get Length    ${elements}
        IF    ${length} > 0
            Log To Console    Found ${length} invoice records after clearing date filter.
            Return From Keyword    ${elements[0]}
        ELSE
            Log To Console    No invoice records found at all.
            Return From Keyword    ${None}
        END
    END

Click Filter Frame
    Click Element    xpath=//*[@id="invoicereport_list_filter"]
    Sleep    3s
    Wait Until Element Is Visible    xpath=//*[@id="id_invoice_status_input"]



