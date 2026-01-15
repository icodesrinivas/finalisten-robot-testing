*** Settings ***
Library    SeleniumLibrary
Library    DateTime
Library    String
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${FIELDREPORT_LIST_URL}      https://preproderp.finalisten.se/fieldreport/list/
${FILTER_FRAME_HEADER}       id=fieldreport_list_filter
${START_WORK_DATE_INPUT}     id=start_work_date
${END_WORK_DATE_INPUT}       id=end_work_date
${SEARCH_BUTTON_XPATH}       xpath=//*[@id='fieldreport_list_search']
${FIELD_REPORT_ROW}          css=.fieldreport_rows
${FIELD_REPORT_LINK}         xpath=//tr[contains(@class, 'fieldreport_rows')]//a[contains(@href, '/edit/')]

*** Test Cases ***
Verify Field Report Edit Page Opens Successfully
    Open And Login
    # Navigate directly to field report list (more reliable in headless)
    Go To    ${FIELDREPORT_LIST_URL}
    Sleep    5s
    Open Field Report Edit Page
    Verify Field Report Edit Page Content
    Close Browser

*** Keywords ***
Open Field Report Edit Page
    [Documentation]    Find a field report and open its edit page
    Wait Until Element Is Visible    ${FILTER_FRAME_HEADER}    timeout=30s
    Execute Javascript    document.getElementById('fieldreport_list_filter').click();
    Sleep    3s
    Wait Until Page Contains Element    ${SEARCH_BUTTON_XPATH}    timeout=15s
    
    ${today}=    Get Current Date    result_format=%Y-%m-%d
    ${current_end_date}=    Set Variable    ${today}

    FOR    ${i}    IN RANGE    20    # Check up to 5 years (20 * 90 days)
        ${is_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${FIELD_REPORT_ROW}    timeout=5s
        IF    ${is_visible}
            Log To Console    Found field report rows
            Exit For Loop
        END

        ${current_start_date}=    Subtract Time From Date    ${current_end_date}    90 days    result_format=%Y-%m-%d
        Log To Console    Searching for records between ${current_start_date} and ${current_end_date} (Iteration: ${i})
        
        # Ensure filter is expanded
        ${filter_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${START_WORK_DATE_INPUT}
        IF    not ${filter_visible}
            Execute Javascript    document.getElementById('fieldreport_list_filter').click();
            Sleep    2s
        END
        
        Clear Element Text    ${START_WORK_DATE_INPUT}
        Input Text    ${START_WORK_DATE_INPUT}    ${current_start_date}
        Clear Element Text    ${END_WORK_DATE_INPUT}
        Input Text    ${END_WORK_DATE_INPUT}    ${current_end_date}
        
        ${search_btn}=    Get WebElement    ${SEARCH_BUTTON_XPATH}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${search_btn}
        Sleep    3s
        
        # Prepare for next window if this one fails
        ${current_end_date}=    Set Variable    ${current_start_date}
    END

    Wait Until Element Is Visible    ${FIELD_REPORT_LINK}    timeout=10s
    
    # Get the href to navigate directly instead of relying on new tab
    ${link_elem}=    Get WebElement    ${FIELD_REPORT_LINK}
    ${edit_url}=    Get Element Attribute    ${link_elem}    href
    Log To Console    Found edit URL: ${edit_url}
    
    # Navigate directly to the edit URL
    Go To    ${edit_url}
    Sleep    5s

Verify Field Report Edit Page Content
    [Documentation]    Verify we are on the field report edit page
    Wait Until Page Contains Element    id=id_related_customer    timeout=20s
    
    # Check for FIELD REPORT text in page
    ${source}=    Get Source
    ${has_text}=    Run Keyword And Return Status    Should Contain    ${source}    FIELD REPORT
    IF    ${has_text}
        Log To Console    ✓ FIELD REPORT text found. Edit page opened successfully.
    ELSE
        # Check for other indicators that we're on the edit page
        ${has_customer}=    Run Keyword And Return Status    Page Should Contain Element    id=id_related_customer
        ${has_project}=    Run Keyword And Return Status    Page Should Contain Element    id=id_related_project
        ${has_save}=    Run Keyword And Return Status    Page Should Contain Element    css=button.save
        
        ${on_edit_page}=    Evaluate    ${has_customer} and ${has_project}
        Should Be True    ${on_edit_page}    msg=Edit page elements not found
        Log To Console    ✓ Field Report Edit page verified via form elements.
    END

