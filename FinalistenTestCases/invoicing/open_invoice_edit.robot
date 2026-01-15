*** Settings ***
Library    SeleniumLibrary
Library    DateTime
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${INVOICE_LIST_URL}               https://preproderp.finalisten.se/invoicereport/list/
${INVOICE_LINK}                   xpath=//a[contains(@class, "open-invoice-edit")]
${INVOICE_EDIT_TEXT}              Invoice Report
${FILTER_FRAME}                   id=invoicereport_list_filter
${INVOICE_STATUS_CHECKBOX}        xpath=//*[@id="id_invoice_status_input" and @value="completed"]
${SEARCH_BUTTON}                  id=invoicereport_list_search

*** Test Cases ***
Verify Invoice Edit View Opens Successfully
    Open And Login
    # Navigate directly to invoice list (more reliable in headless)
    Go To    ${INVOICE_LIST_URL}
    Sleep    5s
    
    # Expand filter and search
    Wait Until Element Is Visible    ${FILTER_FRAME}    timeout=30s
    Execute Javascript    document.getElementById('invoicereport_list_filter').click();
    Sleep    3s
    
    # Check completed invoices
    Wait Until Element Is Visible    ${INVOICE_STATUS_CHECKBOX}    timeout=10s
    Execute Javascript    document.querySelector('#id_invoice_status_input[value="completed"]').click();
    Sleep    2s
    
    # Search for invoices with date range
    ${invoice_url}=    Search For Invoice And Get URL
    IF    '${invoice_url}' != 'None'
        Go To    ${invoice_url}
        Sleep    5s
        Wait Until Page Contains    ${INVOICE_EDIT_TEXT}    timeout=15s
        Log To Console    ✓ Invoice Report text found. Invoice Edit View opened successfully.
    ELSE
        Fail    No invoice records found.
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
        
        # Set date and search
        ${start_input}=    Run Keyword And Return Status    Wait Until Element Is Visible    id=start_work_date    timeout=5s
        IF    ${start_input}
            Clear Element Text    id=start_work_date
            Input Text    id=start_work_date    ${current_start_date}
        END
        
        # Click search using JS
        Execute Javascript    var btn = document.getElementById('invoicereport_list_search'); if(btn) btn.click();
        Sleep    3s
        
        ${elements}=    Get WebElements    ${INVOICE_LINK}
        ${length}=    Get Length    ${elements}
        
        IF    ${length} > 0
            Log To Console    Found ${length} invoice records
            ${href}=    Get Element Attribute    ${elements[0]}    href
            RETURN    ${href}
        END
        
        ${current_end_date}=    Set Variable    ${current_start_date}
    END

    # Final attempt - clear date filter
    Log To Console    No records found. Clearing date filter...
    ${start_input}=    Run Keyword And Return Status    Wait Until Element Is Visible    id=start_work_date    timeout=5s
    IF    ${start_input}
        Clear Element Text    id=start_work_date
    END
    Execute Javascript    var btn = document.getElementById('invoicereport_list_search'); if(btn) btn.click();
    Sleep    3s
    
    ${elements}=    Get WebElements    ${INVOICE_LINK}
    ${length}=    Get Length    ${elements}
    IF    ${length} > 0
        ${href}=    Get Element Attribute    ${elements[0]}    href
        RETURN    ${href}
    END
    
    RETURN    None




