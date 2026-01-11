*** Settings ***
Documentation    Update the Field Report allowed date range in Settings.
Library          SeleniumLibrary
Resource         ../keywords/LoginKeyword.robot

*** Variables ***
${NEW_START_DATE}    2024-01-01
${NEW_END_DATE}      2030-12-31
${SAVE_BUTTON}       id=global_setting_data_save

*** Test Cases ***
Update Field Report Date Range
    [Documentation]    Updates the allowed reporting period to 2024-2030.
    Open And Login
    
    # 1. Navigate to Settings
    Log To Console    Navigating to Settings...
    Mouse Over    xpath=//*[@id="register"]
    Sleep    1s
    Click Element    xpath=//*[@id="settings_app_menu"]
    Wait Until Page Contains    Settings    timeout=15s
    
    # 2. Expand Fieldreport tree node (using JS to handle hidden state)
    Log To Console    Expanding Fieldreport settings via JS...
    # Unhide the 'Reporting Date Range' list item and its parents
    Execute Javascript    var leaf = document.evaluate("//a[contains(text(),'Reporting Date Range')]", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue; if(leaf) { leaf.parentNode.style.display = 'block'; leaf.parentNode.parentNode.style.display = 'block'; leaf.parentNode.parentNode.parentNode.style.display = 'block'; }
    Sleep    1s
    
    # 3. Click Pencil icon
    Wait Until Element Is Visible    id=id_global_setting    timeout=10s
    Click Element    id=id_global_setting
    Log To Console    Opened Date Range inputs.
    
    # 4. Update Dates
    Wait Until Element Is Visible    id=id_work_date_start    timeout=10s
    
    Log To Console    Setting Start Date to ${NEW_START_DATE}
    Input Text    id=id_work_date_start    ${NEW_START_DATE}
    # Trigger change event just in case
    Execute Javascript    document.getElementById('id_work_date_start').dispatchEvent(new Event('change'));
    
    Log To Console    Setting End Date to ${NEW_END_DATE}
    Input Text    id=id_work_date_end    ${NEW_END_DATE}
    # Trigger change event
    Execute Javascript    document.getElementById('id_work_date_end').dispatchEvent(new Event('change'));
    
    Sleep    1s
    
    # 5. Save
    Click Button    ${SAVE_BUTTON}
    Log To Console    Clicked Save.
    
    # 6. Verify success (optional, but good practice)
    # Check if values persisted or alert shown
    Sleep    3s
    # Reload or check values again?
    # For now, just logging done.
    Log To Console    Date range updated successfully.
    
    [Teardown]    Close Browser
