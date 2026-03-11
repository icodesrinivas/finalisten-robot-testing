*** Settings ***
Library          SeleniumLibrary
Library          Collections
Resource         ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}                  xpath=//*[@id="register"]
${SETTINGS_APP_MENU}             xpath=//*[@id="settings_app_menu"]
${PENCIL_ICONS_SELECTOR}         css=i.global-setting-pencil
${FORM_CONTAINER}                id=id_global_setting_data
${SAVE_BUTTON}                   css=#id_global_setting_data button.save
${LOADING_OVERLAY}               css=.loader # Wait for any loading spinner if present

*** Test Cases ***
Verify All Settings Forms Open Successfully
    [Documentation]    Iterates through all pencil icons in the Settings tree view 
    ...               and verifies that each opens a form on the right side.
    [Tags]            settings    validation    regression
    
    Open And Login
    Navigate To Settings App
    
    # Wait for the tree view to be loaded
    Wait Until Element Is Visible    ${PENCIL_ICONS_SELECTOR}    timeout=20s
    
    # Get all pencil icons
    ${pencils}=    Get WebElements    ${PENCIL_ICONS_SELECTOR}
    ${count}=    Get Length    ${pencils}
    Log To Console    Found ${count} settings options to verify.
    
    # Get all IDs of the pencil icons first for stability
    ${pencils}=    Get WebElements    ${PENCIL_ICONS_SELECTOR}
    ${ids}=    Create List
    FOR    ${pencil}    IN    @{pencils}
        ${id}=    Get Element Attribute    ${pencil}    id
        Append To List    ${ids}    ${id}
    END
    
    ${count}=    Get Length    ${ids}
    Log To Console    Found ${count} settings options to verify.
    
    # Iterate using IDs
    FOR    ${id}    IN    @{ids}
        Run Keyword And Continue On Failure    Verify Setting Option By ID    ${id}
    END
    
    Log To Console    Settings verification iteration completed.
    
    [Teardown]    Close Browser

*** Keywords ***
Verify Setting Option By ID
    [Arguments]    ${setting_id}
    [Documentation]    Verifies a single setting option by its ID, waiting for AJAX content to load.
    
    Log To Console    Checking setting: ${setting_id}
    
    # Get current content to detect when it changes
    ${old_content}=    Get Text    ${FORM_CONTAINER}
    
    # Wait for the specific element to be present (re-fetching)
    ${locator}=    Set Variable    id=${setting_id}
    Wait Until Page Contains Element    ${locator}    timeout=10s
    
    # Scroll element into view
    SeleniumLibrary.Scroll Element Into View    ${locator}
    
    # Click the pencil icon using JavaScript
    Execute Javascript    document.getElementById('${setting_id}').click();
    
    # Wait for AJAX load: content must be non-empty AND different from old content
    # (unless old content was empty, then just non-empty)
    Wait Until Keyword Succeeds    15x    1s    Verify Form Content Refresh    ${old_content}
    
    Log To Console    Result: Setting ${setting_id} opened correctly.
    Sleep    1s

Verify Form Content Refresh
    [Arguments]    ${previous_content}
    # First ensure loading buffer is not active (opacity should be 0)
    ${opacity}=    Execute Javascript    return window.getComputedStyle(document.getElementById('loading_buffer')).getPropertyValue('opacity');
    Should Be Equal As Numbers    ${opacity}    0    msg=Loading buffer is still visible
    
    ${current_content}=    Get Text    ${FORM_CONTAINER}
    Should Not Be Empty    ${current_content}    msg=Form container is empty
    Should Not Be Equal    ${current_content}    ${previous_content}    msg=Form content has not changed yet
Navigate To Settings App
    [Documentation]    Navigates to the Settings application via the Register menu.
    Wait Until Element Is Visible    ${REGISTER_MENU}    timeout=20s
    Mouse Over    ${REGISTER_MENU}
    Wait Until Element Is Visible    ${SETTINGS_APP_MENU}    timeout=10s
    Click Element    ${SETTINGS_APP_MENU}
    Wait Until Location Contains    /global_setting/    timeout=20s
    Wait Until Page Contains    Settings    timeout=20s
    Sleep    1s
