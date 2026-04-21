*** Settings ***
Documentation    Test case for navigating the Fieldreport Approval tree structure.
...              
...              This test verifies that:
...              - The Fieldreport Approval app can be opened
...              - An installer can be expanded to show projects
...              - A project can be expanded to show fieldreports
...              - Clicking a fieldreport record opens the edit page in a new tab
...              
...              Fallback logic:
...              - If no fieldreport in a project, try the next project
...              - If no more projects in installer, try the next installer
...              - If no installers have data, update date range to last 3 months
Library          SeleniumLibrary
Library          Collections
Library          DateTime
Library          String
Resource         ../keywords/LoginKeyword.robot

*** Variables ***
# URLs
${BASE_URL}                        https://preproderp.finalisten.se
${FIELDREPORT_APPROVAL_URL}        ${BASE_URL}/fieldreport/fieldreport_approval/
${FIELDREPORT_EDIT_URL_PATTERN}    ${BASE_URL}/fieldreport/list/

# Menu Selectors
${PRODUCTION_MENU}                 id=production
${FIELDREPORT_APPROVAL_MENU}       id=field_report_approval_app_menu

# Tree Selectors (exclude "List Of Installers" / greyed installers — only real branches)
${TREE_CONTAINER}                  css=div.tree_container
${INSTALLER_LINKS}                 css=#tree2 li.installer-branch > a.fieldreport-approval-installer-name
${PROJECT_NAME_LINKS}             css=#tree2 li.project-branch > a
${FIELDREPORT_LINKS}               css=a.fieldreport_record_details

# Date Filter
${DATE_RANGE_DISPLAY}              xpath=//span[contains(@class,'daterangepicker-input') or contains(text(),' to ')]
${DATE_PICKER_CUSTOM}              xpath=//li[contains(text(),'Custom') or contains(text(),'Last Month')]
${DATE_PICKER_APPLY}               xpath=//button[contains(text(),'Apply') or @class='applyBtn']

# Verification
${LIST_OF_INSTALLERS_TEXT}         List Of Installers
${FIELDREPORT_EDIT_PAGE_MARKER}    id=EditGeneralDataButton

*** Test Cases ***
Verify Fieldreport Opens From Approval Tree
    [Documentation]    Navigate through the approval tree (Installer -> Project -> Fieldreport)
    ...                and verify that clicking a fieldreport record opens its edit page in a new tab.
    [Tags]    fieldreportapproval    tree    navigation    smoke
    [Setup]    Open And Login
    
    # Navigate to Fieldreport Approval app
    Navigate To Fieldreport Approval App
    
    # PRE-PROD STABILIZATION: Pre-emptively update to a wide range to ensure data is found
    Log To Console    Pre-emptively updating date range for pre-prod stability...
    Update Date Range To Last 200 Days
    Sleep    5s
    
    # Wait for tree to load
    Wait Until Page Contains    ${LIST_OF_INSTALLERS_TEXT}    timeout=30s
    Log To Console    ======== Field Report Approval App Loaded with Wide Date Range ========
    
    # Try to find and click a fieldreport
    ${found}=    Find And Click Fieldreport In Tree
    
    IF    not ${found}
        Log To Console    No fieldreports found even with wide date range. Retrying one last time...
        Update Date Range To Last 200 Days
        Sleep    5s
        ${found}=    Find And Click Fieldreport In Tree
    END
    
    Should Be True    ${found}    msg=No fieldreport record found in the approval tree even after updating date range
    
    # Verify new tab opened with fieldreport edit page
    Verify Fieldreport Edit Page Opened In New Tab
    
    Log To Console    ======== TEST PASSED: Fieldreport edit page opened successfully ========
    
    [Teardown]    Close All Browsers

*** Keywords ***
Navigate To Fieldreport Approval App
    [Documentation]    Navigate to the Field Report Approval app via Production menu
    
    # Try direct navigation first (more reliable)
    Go To    ${FIELDREPORT_APPROVAL_URL}
    Sleep    2s
    
    # Expand collapsed filter panel so Search / date controls are usable in CI
    Run Keyword And Ignore Error    Click Element    id=fr_approval_filter
    Sleep    2s
    
    ${page_loaded}=    Run Keyword And Return Status    Wait Until Page Contains    ${LIST_OF_INSTALLERS_TEXT}    timeout=10s
    IF    not ${page_loaded}
        # Fallback to menu navigation
        Log To Console    Direct navigation failed, trying menu navigation...
        Go To    ${BASE_URL}/homepage/
        Sleep    2s
        Mouse Over    ${PRODUCTION_MENU}
        Sleep    1s
        Wait Until Element Is Visible    ${FIELDREPORT_APPROVAL_MENU}    timeout=5s
        Click Element    ${FIELDREPORT_APPROVAL_MENU}
        Wait Until Page Contains    ${LIST_OF_INSTALLERS_TEXT}    timeout=15s
    END
    
    Log To Console    ✓ Field Report Approval app loaded

Find And Click Fieldreport In Tree
    [Documentation]    Iterate through installers and projects to find a fieldreport record.
    ...                Returns True if a fieldreport was found and clicked, False otherwise.
    
    # Get all installers
    ${installers}=    Get WebElements    ${INSTALLER_LINKS}
    ${installer_count}=    Get Length    ${installers}
    Log To Console    Found ${installer_count} installers in tree
    
    IF    ${installer_count} == 0
        Log To Console    No installers found in tree
        RETURN    ${FALSE}
    END
    
    # Iterate through installers
    FOR    ${index}    IN RANGE    ${installer_count}
        # Re-fetch installers each iteration (DOM may have changed)
        ${installers}=    Get WebElements    ${INSTALLER_LINKS}
        ${current_installer}=    Get From List    ${installers}    ${index}
        ${installer_text}=    Get Text    ${current_installer}
        Log To Console    Checking installer ${index + 1}: ${installer_text}
        
        # Click to expand installer (lazy-loads projects via AJAX)
        Robust Click    ${current_installer}
        Sleep    4s

        # Check for fieldreport links under this installer
        ${found}=    Try Find Fieldreport Under Expanded Installer
        IF    ${found}
            RETURN    ${TRUE}
        END
        
        # Collapse installer before moving to next (optional - might help with DOM)
        Run Keyword And Ignore Error    Click Element    ${current_installer}
        Sleep    1s
    END
    
    RETURN    ${FALSE}

Try Find Fieldreport Under Expanded Installer
    [Documentation]    After expanding an installer, look for projects and fieldreports.
    ...                Returns True if a fieldreport was clicked, False otherwise.
    
    # First check if any fieldreport links are directly visible
    ${direct_fieldreports}=    Get WebElements    ${FIELDREPORT_LINKS}
    ${direct_count}=    Get Length    ${direct_fieldreports}
    
    IF    ${direct_count} > 0
        Log To Console    Found ${direct_count} fieldreport(s) under installer
        ${fr_element}=    Get From List    ${direct_fieldreports}    0
        ${fr_text}=    Get Text    ${fr_element}
        Log To Console    Clicking fieldreport: ${fr_text}
        Click Fieldreport Link    ${fr_element}
        RETURN    ${TRUE}
    END
    
    # Project rows use li.project-branch; allow a short window for lazy-load after expand
    ${project_count}=    Set Variable    0
    FOR    ${_}    IN RANGE    16
        ${project_links}=    Get WebElements    ${PROJECT_NAME_LINKS}
        ${project_count}=    Get Length    ${project_links}
        Exit For Loop If    ${project_count} > 0
        Sleep    0.5s
    END
    Log To Console    Found ${project_count} project(s) under this installer
    
    FOR    ${proj_index}    IN RANGE    ${project_count}
        # Re-fetch project links
        ${project_links}=    Get WebElements    ${PROJECT_NAME_LINKS}
        ${current_project}=    Get From List    ${project_links}    ${proj_index}
        ${project_text}=    Get Text    ${current_project}
        Log To Console    Checking project: ${project_text}
        
        # Click to expand project with retry
        FOR    ${retry_idx}    IN RANGE    3
            Robust Click    ${current_project}
            Sleep    3s
            # Check for fieldreport links now
            ${fieldreports}=    Get WebElements    ${FIELDREPORT_LINKS}
            ${fr_count}=    Get Length    ${fieldreports}
            
            IF    ${fr_count} > 0
                Log To Console    Found ${fr_count} fieldreport(s) under project ${project_text} (Attempt ${retry_idx + 1})
                ${fr_element}=    Get From List    ${fieldreports}    0
                ${fr_text}=    Get Text    ${fr_element}
                Log To Console    Clicking fieldreport: ${fr_text}
                Click Fieldreport Link    ${fr_element}
                RETURN    ${TRUE}
            END
            Log To Console    ⚠ No fieldreports visible after expansion attempt ${retry_idx + 1}, retrying...
        END
    END
    
    RETURN    ${FALSE}

Click Fieldreport Link
    [Documentation]    Click on a fieldreport link element
    [Arguments]    ${element}
    
    # The link has target="_blank" so it should open in new tab
    Robust Click    ${element}
    Sleep    2s
    Log To Console    ✓ Clicked fieldreport link

Verify Fieldreport Edit Page Opened In New Tab
    [Documentation]    Switch to the new tab and verify it's the fieldreport edit page
    
    # Get all window handles
    @{handles}=    Get Window Handles
    ${handle_count}=    Get Length    ${handles}
    Log To Console    Number of browser tabs/windows: ${handle_count}
    
    Should Be True    ${handle_count} >= 2    msg=Expected new tab to open but only ${handle_count} tab(s) found
    
    # Switch to the new tab (last one in the list)
    ${new_tab}=    Get From List    ${handles}    -1
    Switch Window    ${new_tab}
    Sleep    3s
    
    # Wait for page to load
    Wait Until Page Contains Element    ${FIELDREPORT_EDIT_PAGE_MARKER}    timeout=20s
    
    # Verify URL pattern
    ${current_url}=    Get Location
    Log To Console    New tab URL: ${current_url}
    Should Contain    ${current_url}    /fieldreport/list/    msg=URL should contain fieldreport list pattern
    Should Contain    ${current_url}    /edit/    msg=URL should contain /edit/ indicating edit page
    
    Log To Console    ✓ Fieldreport edit page verified in new tab

Update Date Range To Last 200 Days
    [Documentation]    Widen the approval window via the embedded daterangepicker (#reportrange).
    ...                Changing the span triggers a MutationObserver that reloads the installer tree.
    
    Log To Console    Updating date range...
    
    ${opened}=    Run Keyword And Return Status    Wait Until Element Is Visible    id=reportrange    15s
    IF    ${opened}
        # Use JS click to avoid ElementClickInterceptedException in CI/headless
        Robust Click    id=reportrange
        Sleep    1s
        # Preset labels are English when tests use Open And Login DB language fix
        ${picked}=    Run Keyword And Return Status    Robust Click    xpath=//div[contains(@class,'daterangepicker')]//li[contains(.,'This Month')]
        IF    not ${picked}
            Run Keyword And Ignore Error    Robust Click    xpath=//div[contains(@class,'daterangepicker')]//li[contains(.,'Last Month')]
        END
        Sleep    2s
        Run Keyword And Ignore Error    Press Key    tag=body    ESCAPE
        Sleep    3s
    ELSE
        Log To Console    Could not find #reportrange, reloading page
        Reload Page
        Sleep    3s
    END
    
    Run Keyword And Ignore Error    Click Element    id=id_fr_approval_search_btn
    Sleep    3s
    Wait For Loading Buffer
    # Tree is re-fetched asynchronously after span text updates
    Wait Until Element Is Visible    css=#tree2 li.installer-branch    timeout=45s
    
    Log To Console    ✓ Date range updated
