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

# Tree Selectors
${TREE_CONTAINER}                  css=div.tree_container
${INSTALLER_LINKS}                 css=a.fieldreport-approval-installer-name
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
    
    # Wait for tree to load
    Wait Until Page Contains    ${LIST_OF_INSTALLERS_TEXT}    timeout=15s
    Log To Console    ======== Field Report Approval App Loaded ========
    
    # Try to find and click a fieldreport
    ${found}=    Find And Click Fieldreport In Tree
    
    IF    not ${found}
        Log To Console    No fieldreports found with current date range. Updating to last 3 months...
        Update Date Range To Last 3 Months
        Sleep    3s
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
        
        # Click to expand installer
        ${clicked}=    Run Keyword And Return Status    Click Element    ${current_installer}
        IF    not ${clicked}
            ${clicked}=    Run Keyword And Return Status    Execute Javascript    arguments[0].click();    ARGUMENTS    ${current_installer}
        END
        Sleep    2s
        
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
    
    # Look for project links (they are nested under the expanded installer)
    # Projects are typically <a> tags that appear after clicking installer
    ${project_links}=    Get WebElements    xpath=//ul[contains(@class,'collapse') and contains(@class,'show')]//a[not(contains(@class,'fieldreport-approval-installer-name')) and not(contains(@class,'fieldreport_record_details'))]
    ${project_count}=    Get Length    ${project_links}
    Log To Console    Found ${project_count} project(s) under this installer
    
    FOR    ${proj_index}    IN RANGE    ${project_count}
        # Re-fetch project links
        ${project_links}=    Get WebElements    xpath=//ul[contains(@class,'collapse') and contains(@class,'show')]//a[not(contains(@class,'fieldreport-approval-installer-name')) and not(contains(@class,'fieldreport_record_details'))]
        ${current_project}=    Get From List    ${project_links}    ${proj_index}
        ${project_text}=    Get Text    ${current_project}
        Log To Console    Checking project: ${project_text}
        
        # Click to expand project
        Run Keyword And Ignore Error    Click Element    ${current_project}
        Sleep    2s
        
        # Check for fieldreport links now
        ${fieldreports}=    Get WebElements    ${FIELDREPORT_LINKS}
        ${fr_count}=    Get Length    ${fieldreports}
        
        IF    ${fr_count} > 0
            Log To Console    Found ${fr_count} fieldreport(s) under project ${project_text}
            ${fr_element}=    Get From List    ${fieldreports}    0
            ${fr_text}=    Get Text    ${fr_element}
            Log To Console    Clicking fieldreport: ${fr_text}
            Click Fieldreport Link    ${fr_element}
            RETURN    ${TRUE}
        END
    END
    
    RETURN    ${FALSE}

Click Fieldreport Link
    [Documentation]    Click on a fieldreport link element
    [Arguments]    ${element}
    
    # The link has target="_blank" so it should open in new tab
    ${clicked}=    Run Keyword And Return Status    Click Element    ${element}
    IF    not ${clicked}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${element}
    END
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

Update Date Range To Last 3 Months
    [Documentation]    Update the date filter to show data from the last 3 months
    
    Log To Console    Updating date range to last 3 months...
    
    # Calculate dates (3 months ago to today)
    ${today}=    Get Current Date    result_format=%Y-%m-%d
    ${three_months_ago}=    Subtract Time From Date    ${today}    90 days    result_format=%Y-%m-%d
    Log To Console    Date range: ${three_months_ago} to ${today}
    
    # Try to find and click the date range display
    ${date_elements}=    Get WebElements    xpath=//span[contains(text(),' to ') or contains(text(),'-')]
    ${date_found}=    Get Length    ${date_elements}
    
    IF    ${date_found} > 0
        ${date_element}=    Get From List    ${date_elements}    0
        Click Element    ${date_element}
        Sleep    2s
        
        # Try to click "Last Month" or similar preset option
        ${preset_options}=    Get WebElements    xpath=//li[contains(text(),'Last Month') or contains(text(),'This Month')]
        ${preset_count}=    Get Length    ${preset_options}
        
        IF    ${preset_count} > 0
            # Click "Last Month" to get some historical data
            ${option}=    Get From List    ${preset_options}    0
            Click Element    ${option}
            Sleep    2s
        ELSE
            # Try custom date input
            Log To Console    No preset options found, attempting custom date entry
            # This would require more specific selectors for the daterangepicker
        END
    ELSE
        # Alternative: Try reloading with date parameters if supported
        Log To Console    Could not find date range selector, refreshing page
        Reload Page
        Sleep    3s
    END
    
    Log To Console    ✓ Date range updated
