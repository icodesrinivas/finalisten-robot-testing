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
        Wait Until Keyword Succeeds    3x    5s    Verify Invoice Element And Click    ${invoice_element}
    ELSE
        Fail    No invoice records found.
    END
    Wait Until Keyword Succeeds    3x    10s    Wait Until Page Contains    ${INVOICE_EDIT_TEXT}    timeout=10s
    Log To Console    "Invoice Report text found. Invoice Edit View opened successfully."
    Close Browser

Verify Invoice Element And Click
    [Arguments]    ${element}
    # Wait for element to be in viewport and ready
    Execute Javascript    arguments[0].scrollIntoView({block: "center"});    ARGUMENTS    ${element}
    Sleep    3s
    
    # Wait for any overlays to disappear
    Execute Javascript    
    ...    var overlays = document.querySelectorAll('.modal-backdrop, .loading-overlay');
    ...    overlays.forEach(function(o) { o.style.display = 'none'; });
    
    # First try standard click with retry
    ${clicked}=    Run Keyword And Return Status    Wait Until Keyword Succeeds    3x    2s    Click Element    ${element}
    IF    not ${clicked}
        Log To Console    Standard click failed, trying JS click...
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${element}
    END
    Sleep    5s

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
    ${today}=    Get Current Date    result_format=%Y-%m-%d
    ${current_end_date}=    Set Variable    ${today}

    Click Completed Invoice Checkbox

    FOR    ${i}    IN RANGE    20    # Check up to 5 years
        ${current_start_date}=    Subtract Time From Date    ${current_end_date}    90 days    result_format=%Y-%m-%d
        Log To Console    Searching window: ${current_start_date} to ${current_end_date}
        
        Clear Element Text    id=start_work_date
        Input Text    id=start_work_date    ${current_start_date}
        Click Search Button
        Sleep    3s
        
        ${elements}=    Get WebElements    ${INVOICE_LINK}
        ${length}=    Get Length    ${elements}
        
        IF    ${length} > 0
            Log To Console    Found ${length} invoice records in window ${current_start_date} to ${current_end_date}
            RETURN    ${elements[0]}
        END
        
        ${current_end_date}=    Set Variable    ${current_start_date}
    END

    Log To Console    No invoice records found in last 5 years. Trying as a last resort to clear date filter...
    Clear Element Text    id=start_work_date
    Click Search Button
    Sleep    3s
    ${elements}=    Get WebElements    ${INVOICE_LINK}
    ${length}=    Get Length    ${elements}
    IF    ${length} > 0
        RETURN    ${elements[0]}
    END
    
    RETURN    ${None}

Click Filter Frame
    Click Element    xpath=//*[@id="invoicereport_list_filter"]
    Sleep    3s
    Wait Until Element Is Visible    xpath=//*[@id="id_invoice_status_input"]



