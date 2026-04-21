*** Settings ***
Library    SeleniumLibrary
Library    String
Library    ../keywords/DatabaseKeywords.py
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_MENU}                xpath=//*[@id="production"]
${PROJECT_MENU}                   xpath=//*[@id="project_app_menu"]
${PROJECT_LIST_URL}               /projects/list/
${PROJECT_ROW}                    css=tr.project_rows
${PROJECT_EDIT_TEXT}              GENERAL DATA

# Selectors for Fixed Agreements
${FIXED_AGREEMENTS_TAB}           id=id_fixed_agreement_frame_header
${FIXED_AGREEMENT_ROW}            xpath=//table[contains(@id, 'fixedagreement')]//tr[contains(@class, 'row')] | //tr[contains(@class, 'fixedagreement')] | //tr[td[contains(text(), 'Auto Test Agreement')]]

*** Test Cases ***
Verify Fixed Agreement Delete Functionality
    [Documentation]    Verifies that a fixed agreement row can be successfully deleted from the project edit page.
    Open And Login
    Navigate To Project Edit Page
    # 1. Open the Fixed Agreements tab/frame
    Open Fixed Agreements Tab
    
    # 2. Ensure at least one row exists (create via UI if empty).
    Ensure Fixed Agreement Row Exists

    # 3. Find the row and click delete (prefer the auto-created test row if present).
    ${row_locator}=    Set Variable    xpath=//table[@id='fixed_agreement_table']//tr[td[contains(., 'Auto Test Agreement')]]
    ${present}=    Run Keyword And Return Status    Page Should Contain Element    ${row_locator}
    IF    not ${present}
        ${row_locator}=    Set Variable    xpath=(//table[@id='fixed_agreement_table']//tbody//tr)[1]
    END

    ${delete_btn_locator}=    Set Variable    ${row_locator}//button[starts-with(@id,'fixed_agreement_remove_') or contains(@title, 'Delete') or contains(@title, 'Ta bort')]

    # Capture the fixed agreement id so we can verify correct deletion
    ${row_id_attr}=    Get Element Attribute    ${row_locator}    id
    ${fa_id}=    Evaluate    '${row_id_attr}'.replace('fixed_agreement_details_', '') if '${row_id_attr}' else ''
    IF    '${fa_id}' == '' or '${fa_id}' == '${row_id_attr}'
        ${del_btn_id}=    Get Element Attribute    ${delete_btn_locator}    id
        ${fa_id}=    Evaluate    '${del_btn_id}'.replace('fixed_agreement_remove_', '') if '${del_btn_id}' else ''
    END
    Should Not Be Equal    ${fa_id}    ${EMPTY}    msg=Could not determine fixed agreement id for deletion.

    Wait Until Element Is Visible    ${delete_btn_locator}    timeout=30s
    ${del_btn}=    Get WebElement    ${delete_btn_locator}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${del_btn}
    Sleep    1s

    # 6. Handle alert
    Handle Alert    action=ACCEPT    timeout=5s
    Log To Console    ✓ Delete confirmation alert accepted.

    # 7. Wait for deletion to complete (Ajax/Server sync)
    Sleep    3s
    # Wait for loading buffer if it appears
    ${buffer_visible}=    Run Keyword And Return Status    Element Should Be Visible    id=loading_buffer
    IF    ${buffer_visible}
        Wait Until Keyword Succeeds    30x    1s    Element Should Not Be Visible    id=loading_buffer
    END
    
    # Reload page to confirm server-side deletion
    Log To Console    Reloading page for server-side verification...
    Reload Page
    Wait Until Page Contains    ${PROJECT_EDIT_TEXT}    timeout=30s
    Open Fixed Agreements Tab
    
    # 8. Verify deletion in expanded section
    ${row_exists}=    Run Keyword And Return Status    Page Should Contain Element    id=fixed_agreement_details_${fa_id}
    IF    ${row_exists}
        Log To Console    ❌ Failure: Fixed agreement still found in DOM!
        Capture Page Screenshot
        Fail    The fixed agreement row was NOT deleted.
    ELSE
        Log To Console    ✓ Fixed agreement row successfully deleted and verified from server.
    END

    [Teardown]    Close Browser

*** Keywords ***
Navigate To Project Edit Page
    Hover Over Production Menu
    Click On Project Menu
    
    Wait Until Location Contains    ${PROJECT_LIST_URL}    timeout=15s
    ${row_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${PROJECT_ROW}    timeout=15s
    
    IF    ${row_exists}
        ${row}=    Get WebElement    ${PROJECT_ROW}
        Execute Javascript    arguments[0].scrollIntoView({behavior: 'smooth', block: 'center'});    ARGUMENTS    ${row}
        Sleep    1s
        Double Click Element    ${PROJECT_ROW}
        # Handle the possible "EditGeneralDataButton" or simple load
        Wait Until Page Contains    ${PROJECT_EDIT_TEXT}    timeout=30s
    ELSE
        Fail    Failed to find project records on the project list page (${PROJECT_LIST_URL}).
    END

Hover Over Production Menu
    Wait Until Page Contains Element    ${PRODUCTION_MENU}    timeout=20s
    Execute Javascript    var el = document.getElementById('production'); if(el) el.scrollIntoView({behavior: 'smooth', block: 'center'});
    Sleep    2s
    Wait Until Element Is Visible    ${PRODUCTION_MENU}    timeout=15s
    Click Element    ${PRODUCTION_MENU}
    Sleep    1s

Click On Project Menu
    Wait Until Element Is Visible    ${PROJECT_MENU}    timeout=15s
    Click Element    ${PROJECT_MENU}
    
    ${status}=    Run Keyword And Return Status    Wait Until Location Contains    ${PROJECT_LIST_URL}    timeout=5s
    IF    not ${status}
        Execute Javascript    document.getElementById('project_app_menu').click();
    END

Extract Project ID From URL
    [Arguments]    ${url}
    ${id}=    Evaluate    [p for p in '${url}'.split('/') if p.isdigit()][-1]
    RETURN    ${id}

Open Fixed Agreements Tab
    Wait Until Element Is Visible    ${FIXED_AGREEMENTS_TAB}    timeout=20s
    ${tab_el}=    Get WebElement    ${FIXED_AGREEMENTS_TAB}
    Execute Javascript    arguments[0].scrollIntoView({behavior: 'smooth', block: 'center'});    ARGUMENTS    ${tab_el}
    Sleep    1s
    
    # Check if already expanded (agreements container visible)
    ${is_expanded}=    Run Keyword And Return Status    Element Should Be Visible    css=#fixed-agreements-table-container
    IF    not ${is_expanded}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${tab_el}
        # Wait for either the table to become visible OR for the animation to finish
        Sleep    3s
    END
    
    # Final check — table is loaded into #fixed-agreements-table-container via AJAX
    Wait Until Keyword Succeeds    40x    2s    Page Should Contain Element    css=#fixed_agreement_table
    Log To Console    ✓ Fixed Agreements section expanded.

Ensure Fixed Agreement Row Exists
    [Documentation]    If the fixed agreement table is empty, create a minimal agreement via UI.
    ${row_count}=    Get Element Count    css=#fixed_agreement_table tbody tr
    IF    ${row_count} > 0
        RETURN
    END

    Log To Console    No fixed agreement rows found. Creating one via UI...
    ${add_btn}=    Set Variable    xpath=//div[@id='id_fixed_agreement_frame_header']//button[contains(.,'ADD')]
    Wait Until Element Is Visible    ${add_btn}    timeout=20s
    Click Element    ${add_btn}
    Wait Until Element Is Visible    id=myModal4    timeout=20s

    # Required fields
    Select From List By Index    id=id_fixed_agreement_type    1
    Select From List By Index    id=id_fixed_agreement_category    1
    Input Text    id=id_agreement_name    Auto Test Agreement
    Input Text    id=id_agreement_amount    5000

    Click Element    xpath=//div[@id='myModal4']//button[contains(.,'Save')]
    Wait Until Element Is Not Visible    id=myModal4    timeout=30s

    # Row is inserted into DOM via AJAX; wait for it to appear.
    Wait Until Keyword Succeeds    30x    1s    Page Should Contain Element    xpath=//table[@id='fixed_agreement_table']//tr[td[contains(., 'Auto Test Agreement')]]

