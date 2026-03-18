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


    # 2. Extract Project ID from DOM (since URL might contain alphanumeric hashids)
    ${project_id}=    Execute Javascript    return document.getElementById('formid').getAttribute('project-record-id');
    IF    not '${project_id}'
        # Fallback to URL parsing if DOM check fails
        ${current_url}=    Get Location
        ${project_id}=    Extract Project ID From URL    ${current_url}
    END

    # 3. Create a fixed agreement via DB to ensure we have one to delete
    Log To Console    \nCreating a test fixed agreement for project ID ${project_id} via DB...
    ${agreement_id}=    Create Fixed Agreement    ${project_id}
    Run Keyword If    not '${agreement_id}'    Fail    Failed to create fixed agreement in DB.

    # 4. Reload page to see the new agreement
    Reload Page
    Wait Until Page Contains    ${PROJECT_EDIT_TEXT}    timeout=30s
    Sleep    3s
    
    # Open tab again after reload
    Open Fixed Agreements Tab


    # 5. Find the row and click delete
    # Look specifically for our Auto Test Agreement
    ${row_locator}=    Set Variable    xpath=//tr[td[contains(., 'Auto Test Agreement')]]
    ${delete_btn_locator}=    Set Variable    ${row_locator}//button[contains(@id, 'fixed_agreement_remove') or contains(@title, 'Delete') or contains(@title, 'Ta bort')]
    
    # Debug: Check if row exists even if not visible
    ${present}=    Run Keyword And Return Status    Page Should Contain Element    ${row_locator}
    IF    not ${present}
        Log To Console    ⚠ Row for 'Auto Test Agreement' not found in DOM!
        Capture Page Screenshot
        Fail    Fixed agreement row not found in DOM after creation.
    END

    Wait Until Element Is Visible    ${delete_btn_locator}    timeout=20s
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
    ${row_exists}=    Run Keyword And Return Status    Page Should Contain Element    ${row_locator}
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
    
    # Check if already expanded (table div visible)
    ${is_expanded}=    Run Keyword And Return Status    Element Should Be Visible    id=fixed_agreement_table_div
    IF    not ${is_expanded}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${tab_el}
        # Wait for either the table to become visible OR for the animation to finish
        Sleep    3s
    END
    
    # Final check
    Wait Until Element Is Visible    id=fixed_agreement_table_div    timeout=10s
    Log To Console    ✓ Fixed Agreements section expanded.

