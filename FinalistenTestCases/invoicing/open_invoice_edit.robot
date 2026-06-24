*** Settings ***
Library    SeleniumLibrary
Library    DateTime
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Variables ***
${INVOICE_LINK}                   xpath=//a[contains(@class, "open-invoice-edit")]
${INVOICE_EDIT_TEXT}              Invoice Report
${FILTER_FRAME}                   id=invoicereport_list_filter
${INVOICE_STATUS_CHECKBOX}        xpath=//*[@id="id_invoice_status_input" and @value="completed"]

*** Test Cases ***
Verify Invoice Edit View Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Invoice List
    Wait Until Page Contains Element    ${FILTER_FRAME}    timeout=30s
    ${filter_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${FILTER_FRAME}    timeout=15s
    IF    ${filter_visible}
        Execute Javascript    document.getElementById('invoicereport_list_filter').click();
        Wait Until Page Contains Element    id=start_work_date    timeout=15s
    END
    ${checkbox_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${INVOICE_STATUS_CHECKBOX}    timeout=10s
    IF    ${checkbox_visible}
        Execute Javascript    document.querySelector('#id_invoice_status_input[value="completed"]').click();
    ELSE
        Execute Javascript    var cb = document.querySelector('input[name="invoice_status"]'); if(cb) cb.click();
    END
    ${invoice_url}=    Search For Invoice And Get URL
    IF    '${invoice_url}' != 'None'
        Navigate To Legacy Full Url    ${invoice_url}
        Wait Until Page Contains    ${INVOICE_EDIT_TEXT}    timeout=30s
        Log To Console    ✓ Invoice Report text found. Invoice Edit View opened successfully.
    ELSE
        Log To Console    ⚠ No invoice records found in database. Test requires invoice data to exist.
        Skip    No invoice records found in database. Test requires completed invoices to exist.
    END
    Close Browser

*** Keywords ***
Search For Invoice And Get URL
    [Documentation]    Search for invoices and return the first edit link URL
    ${today}=    Get Current Date    result_format=%Y-%m-%d
    ${current_end_date}=    Set Variable    ${today}

    FOR    ${i}    IN RANGE    20
        ${current_start_date}=    Subtract Time From Date    ${current_end_date}    90 days    result_format=%Y-%m-%d
        Log To Console    Searching window: ${current_start_date} to ${current_end_date}
        ${start_input}=    Run Keyword And Return Status    Wait Until Element Is Visible    id=start_work_date    timeout=5s
        IF    ${start_input}
            Clear Element Text    id=start_work_date
            Input Text    id=start_work_date    ${current_start_date}
        END
        Execute Javascript    var btn = document.getElementById('invoicereport_list_search'); if(btn) btn.click();
        Wait Until Keyword Succeeds    10x    1s    Invoice Links Loaded Or Empty
        ${elements}=    Get WebElements    ${INVOICE_LINK}
        ${length}=    Get Length    ${elements}
        IF    ${length} > 0
            ${href}=    Get Element Attribute    ${elements[0]}    href
            RETURN    ${href}
        END
        ${current_end_date}=    Set Variable    ${current_start_date}
    END

    ${start_input}=    Run Keyword And Return Status    Wait Until Element Is Visible    id=start_work_date    timeout=5s
    IF    ${start_input}
        Clear Element Text    id=start_work_date
    END
    Execute Javascript    var btn = document.getElementById('invoicereport_list_search'); if(btn) btn.click();
    Wait Until Keyword Succeeds    10x    1s    Invoice Links Loaded Or Empty
    ${elements}=    Get WebElements    ${INVOICE_LINK}
    ${length}=    Get Length    ${elements}
    IF    ${length} > 0
        ${href}=    Get Element Attribute    ${elements[0]}    href
        RETURN    ${href}
    END
    RETURN    None

Invoice Links Loaded Or Empty
    ${count}=    Get Element Count    ${INVOICE_LINK}
    ${empty}=    Run Keyword And Return Status    Page Should Contain Element    css=td.dataTables_empty
    IF    ${count} == 0 and not ${empty}    Fail    Search still running
