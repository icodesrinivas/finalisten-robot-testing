*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    DatabaseKeywords.py
Resource   NavigationKeyword.robot


*** Variables ***
${BROWSER}        chrome
${URL}           https://preproderp.finalisten.se/login/
${USERNAME}      erpadmin@finalisten.se
${PASSWORD}      Djangocrm123
${LOGIN_BUTTON}  xpath=//button[@type='submit' and contains(@class,'btn-primary') and contains(@class,'btn-block')]
${HOMEPAGE_URL}  https://preproderp.finalisten.se/homepage/
${CHROME_OPTIONS}    add_argument("--ignore-certificate-errors");add_argument("--disable-web-security");add_argument("--allow-running-insecure-content");add_argument("--window-size=1920,1080");add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage")
${EXECUTABLE_PATH}    ${EMPTY}

# Global Field Report Variables for cleanup
${FIELDREPORT_LIST_URL}           https://preproderp.finalisten.se/fieldreport/list/
${DELETE_BUTTON}                  id=remove_fieldreport
${APPROVE_BUTTON}                 id=id_fieldreport_approve_btn
${CREATED_FIELDREPORT_ID}         ${EMPTY}

*** Keywords ***
Open And Login
    Register Keyword To Run On Failure    Capture Page Screenshot
    Sanitize ChromeDriver Path
    ${path}=    Setup ChromeDriver Path
    Open Browser    ${URL}    ${BROWSER}    options=${CHROME_OPTIONS}    executable_path=${path}
    Set Window Size    1920    1080
    Maximize Browser Window
    Set Selenium Implicit Wait    10s
    Set Selenium Timeout    60s
    
    # Force Language to English via direct DB query as early as possible
    Force User Language To English    ${USERNAME}
    
    Handle SSL Warning
    
    Wait Until Page Contains Element    xpath=//input[@name='username']    timeout=30s
    Input Text    xpath=//input[@name='username']    ${USERNAME}
    Input Text    xpath=//input[@name='password']    ${PASSWORD}
    Click Button    ${LOGIN_BUTTON}
    Wait Until Location Contains    ${HOMEPAGE_URL}    timeout=45s
    Wait For Erp Shell Ready

Select Customer And Project
    [Documentation]    Select customer/project using labels that exist in the form dropdown,
    ...                cross-checked against the database when DATABASE_URL is available.
    [Arguments]    ${customer}=${EMPTY}    ${project}=${EMPTY}

    Wait Until Element Is Visible    id=id_related_customer    timeout=30s
    Wait Until Keyword Succeeds    10x    1s    List Should Have Options    id=id_related_customer

    ${customer_options}=    Get List Items    id=id_related_customer
    ${pair}=    Get Valid Customer And Project From Options    ${customer_options}
    ${chosen_customer}=    Set Variable    ${pair['customer']}
    ${chosen_project}=    Set Variable    ${pair['project']}

    IF    '${customer}' != '${EMPTY}'
        ${hint_in_options}=    Run Keyword And Return Status    List Should Contain Value    ${customer_options}    ${customer}
        IF    ${hint_in_options}
            ${chosen_customer}=    Set Variable    ${customer}
            IF    '${project}' != '${EMPTY}'
                ${chosen_project}=    Set Variable    ${project}
            END
        END
    END

    IF    '${chosen_customer}' == '${NONE}' or '${chosen_customer}' == 'None' or '${chosen_customer}' == '${EMPTY}'
        Log To Console    ⚠ No customer options found, selecting index 1
        Robust Select From List By Index    id=id_related_customer    1
        ${chosen_customer}=    Get Selected List Label    id=id_related_customer
    ELSE
        Log To Console    ======== DATA SELECTION: ${chosen_customer} / ${chosen_project} ========
        Robust Select From List By Label    id=id_related_customer    ${chosen_customer}
    END

    ${el}=    Get WebElement    id=id_related_customer
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${el}
    Wait Until Keyword Succeeds    15x    1s    Project Dropdown Ready

    ${project_options}=    Get List Items    id=id_related_project
    ${resolved_project}=    Get Project For Customer From Options    ${chosen_customer}    ${project_options}
    IF    '${chosen_project}' != '${NONE}' and '${chosen_project}' != 'None' and '${chosen_project}' != '${EMPTY}'
        ${project_in_options}=    Run Keyword And Return Status    List Should Contain Value    ${project_options}    ${chosen_project}
        IF    ${project_in_options}
            ${resolved_project}=    Set Variable    ${chosen_project}
        END
    END

    IF    '${resolved_project}' == '${NONE}' or '${resolved_project}' == 'None' or '${resolved_project}' == '${EMPTY}'
        Log To Console    ⚠ No matching project label, selecting project index 1
        Robust Select From List By Index    id=id_related_project    1
        ${resolved_project}=    Get Selected List Label    id=id_related_project
    ELSE
        Robust Select From List By Label    id=id_related_project    ${resolved_project}
    END

    ${el2}=    Get WebElement    id=id_related_project
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${el2}
    Wait Until Keyword Succeeds    10x    1s    Subproject Dropdown Ready

    Robust Select From List By Index    id=id_related_subproject    1
    Set Suite Variable    ${DB_CUSTOMER}    ${chosen_customer}
    Set Suite Variable    ${DB_PROJECT}     ${resolved_project}
    Log To Console    ✓ Selection completed: ${DB_CUSTOMER} / ${DB_PROJECT}

Project Dropdown Ready
    Wait Until Element Is Visible    id=id_related_project    timeout=5s
    List Should Have Options    id=id_related_project

Subproject Dropdown Ready
    Wait Until Element Is Visible    id=id_related_subproject    timeout=5s
    List Should Have Options    id=id_related_subproject

Setup Dynamic Test Data
    [Documentation]    Fetches installer from DB. Customer/project are resolved from form dropdown at selection time.
    ${installer}=    Get Valid Installer Name
    Set Suite Variable    ${DB_INSTALLER}    ${installer}
    Log To Console    ✓ Setup Dynamic Data: installer=${DB_INSTALLER} (customer/project resolved from dropdown)

Ensure Fieldreport Product Note Filled And Saved
    [Documentation]    Some FR products require a reporting note. Enable product edit mode, set a note on the first row, and save to avoid blocking alerts on later actions.
    Wait For Loading Buffer
    ${has_table}=    Run Keyword And Return Status    Page Should Contain Element    css=#prodInFieldReportTable
    IF    not ${has_table}
        RETURN
    END
    Run Keyword And Ignore Error    Execute Javascript    var b=document.querySelector('#product_in_fieldreport_edit:not([disabled])'); if(b){b.click();}
    Sleep    2s
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=2s
    ${r}=    Execute Javascript
    ...    var ta=document.querySelector('#prodInFieldReportTable textarea[id^="id_note_"]');
    ...    if(!ta){return 'no_textarea';}
    ...    ta.removeAttribute('disabled'); ta.removeAttribute('readonly');
    ...    ta.value='Robot test note';
    ...    ta.dispatchEvent(new Event('input')); ta.dispatchEvent(new Event('change'));
    ...    return 'ok';
    Log To Console    Product note prerequisite: ${r}
    ${row_save}=    Execute Javascript
    ...    var b=document.querySelector('#prodInFieldReportTable button[id^="product_general_data_save_"]');
    ...    if(!b){return 'no_row_save';}
    ...    b.removeAttribute('hidden');
    ...    b.style.display='inline-block';
    ...    b.click();
    ...    return 'row_save_clicked';
    Log To Console    Per-row product save: ${row_save}
    Sleep    4s
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=5s
    ${save_exists}=    Run Keyword And Return Status    Page Should Contain Element    id=product_in_fieldreport_save
    IF    ${save_exists}
        ${el}=    Get WebElement    id=product_in_fieldreport_save
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${el}
        Sleep    4s
        Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=5s
    END

List Should Have Options
    [Arguments]    ${locator}
    ${options}=    Get List Items    ${locator}
    ${count}=    Get Length    ${options}
    # Count > 1 because typically there is a "Select..." or empty option at index 0
    Should Be True    ${count} > 1    msg=Dropdown ${locator} has no options to select.

Extract And Verify Fieldreport ID
    [Documentation]    Extract ID from current URL and verify it is not empty.
    ${current_url}=    Get Location
    ${id}=    Extract Fieldreport Id From Url    ${current_url}
    IF    '${id}' == '${EMPTY}'
        Select Legacy Content Frame
        ${iframe_url}=    Execute Javascript    return window.location.href
        Unselect Frame
        ${id}=    Extract Fieldreport Id From Url    ${iframe_url}
    END
    IF    '${id}' == '${EMPTY}'
        Fail    Failed to extract Field Report ID from URL: ${current_url}. Field Report was likely not created or saved successfully.
    END
    RETURN    ${id}

Extract Fieldreport Id From Url
    [Arguments]    ${current_url}
    ${id}=    Run Keyword If    '/edit/' in '${current_url}'    Evaluate    $current_url.split('/')[-3]
    ...    ELSE IF    '/list/' in '${current_url}' and not '${current_url}'.endswith('/')    Evaluate    $current_url.split('/')[-2]
    ...    ELSE    Set Variable    ${EMPTY}
    RETURN    ${id}

Handle SSL Warning
    ${advanced_button}=    Get WebElements    xpath=//button[contains(text(),'Advanced')]
    Run Keyword If    ${advanced_button}    Click Button    xpath=//button[contains(text(),'Advanced')]

    ${proceed_link}=    Get WebElements    xpath=//a[contains(text(),'Proceed')]
    Run Keyword If    ${proceed_link}    Click Element    xpath=//a[contains(text(),'Proceed')]

Close Browser
    ${browsers}=    SeleniumLibrary.Get Browser Ids
    IF    ${browsers}
        SeleniumLibrary.Close All Browsers
    END

Cleanup Created Fieldreport
    [Documentation]    Deletes the field report created during the test.
    ...                Ensures cleanup even if the test fails.
    Log To Console    \n======== CLEANUP: Deleting Field Report ========
    
    # Check if we have an active browser session
    ${browser_ids}=    Get Browser Ids
    IF    not ${browser_ids}
        Log To Console    No active browser session found. Skipping cleanup navigation.
        RETURN
    END

    # Check if we have an ID to delete
    ${has_id}=    Run Keyword And Return Status    Should Not Be Empty    ${CREATED_FIELDREPORT_ID}
    
    IF    ${has_id}
        Log To Console    ID to delete: ${CREATED_FIELDREPORT_ID}
        # Use Run Keyword And Ignore Error for the entire navigation and delete process
        Run Keyword And Ignore Error    Perform Deletion For ID    ${CREATED_FIELDREPORT_ID}

        # DB fallback (covers cases where UI delete button is missing or teardown happens mid-failure)
        Run Keyword And Ignore Error    Delete Fieldreport By Slug    ${CREATED_FIELDREPORT_ID}
    ELSE
        Log To Console    No field report ID found for cleanup. Running DB safety cleanup by message prefix...
        Run Keyword And Ignore Error    Delete Robot Fieldreports By Message Prefix    Robot Framework    25
    END

    # Always close all browsers in teardown
    Run Keyword And Ignore Error    SeleniumLibrary.Close All Browsers

Perform Deletion For ID
    [Arguments]    ${id}
    # Navigate directly to the edit page's delete functionality
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${id}/edit/
    Navigate To Legacy Full Url    ${edit_url}
    
    # Check if report is approved (delete button is disabled/hidden for approved reports)
    ${approve_btn_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${APPROVE_BUTTON}    timeout=5s
    IF    ${approve_btn_exists}
        ${btn_value}=    Get Element Attribute    ${APPROVE_BUTTON}    value
        ${is_approved}=    Run Keyword And Return Status    Should Contain    ${btn_value}    Unapprove
        IF    ${is_approved}
            Log To Console    Field Report is approved - unapproving first...
            Click Element    ${APPROVE_BUTTON}
            Sleep    1s
            Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=5s
            Sleep    2s
        END
    END

    # Check if delete button exists (to avoid failure if already deleted or page error)
    ${delete_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${DELETE_BUTTON}    timeout=10s
    
    IF    ${delete_exists}
        Log To Console    Clicking delete button for ID: ${id}
        # Use Javascript click for reliability
        ${del_btn}=    Get WebElement    ${DELETE_BUTTON}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${del_btn}
        Sleep    1s
        
        # Handle the confirmation alert
        ${alert_present}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=10s
        IF    ${alert_present}
            Log To Console    ✓ Alert accepted.
        ELSE
            Log To Console    ⚠ No alert appeared or could not be handled.
        END
        
        Sleep    2s
        Log To Console    ✓ Field Report ${id} cleaned up.
    ELSE
        Log To Console    ⚠ Delete button not found for ID ${id}. Already deleted?
    END

    Close Browser

Wait Until Page Loaded
    [Documentation]    Wait for the page to be fully loaded and steady.
    Wait Until Keyword Succeeds    5x    2s    Execute Javascript    return document.readyState === 'complete'
    Sleep    2s

Wait For Loading Buffer
    [Documentation]    Wait for the AJAX loading buffer to disappear (opacity 0 or display none).
    Wait Until Keyword Succeeds    30x    1s    Check Loading Buffer Invisible

Check Loading Buffer Invisible
    ${exists}=    Run Keyword And Return Status    Page Should Contain Element    id=loading_buffer
    IF    not ${exists}    RETURN
    ${opacity}=    Execute Javascript    var el = document.getElementById('loading_buffer'); return el ? window.getComputedStyle(el).getPropertyValue('opacity') : '0';
    ${display}=    Execute Javascript    var el = document.getElementById('loading_buffer'); return el ? window.getComputedStyle(el).getPropertyValue('display') : 'none';
    # If opacity is 1 but it's not actually there, or if it's 0, we consider it invisible
    Should Be True    '${opacity}' == '0' or '${display}' == 'none'    msg=Loading buffer is still visible (opacity: ${opacity}, display: ${display})

Robust Click
    [Arguments]    ${locator}    ${timeout}=30s
    [Documentation]    Wait for buffer, scroll to element, wait for visibility, and JS click.
    Wait For Loading Buffer
    Wait Until Page Contains Element    ${locator}    timeout=${timeout}
    # Scroll center to avoid floating headers
    ${el}=    Get WebElement    ${locator}
    Execute Javascript    arguments[0].scrollIntoView({block: "center", behavior: "instant"});    ARGUMENTS    ${el}
    Sleep    1s
    
    # Fallback visibility check via JS if Selenium fails to see it
    ${visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${locator}    timeout=5s
    IF    not ${visible}
        Log To Console    ⚠ Selenium visibility check failed for ${locator}, checking via JS...
        ${js_visible}=    Execute Javascript    var el = arguments[0]; var style = window.getComputedStyle(el); return (style.display !== 'none' && style.visibility !== 'hidden' && style.opacity !== '0');    ARGUMENTS    ${el}
        IF    not ${js_visible}
            Log To Console    ⚠ JS visibility check also failed. Attempting final 10s wait...
            Wait Until Element Is Visible    ${locator}    timeout=10s
        END
    END
    
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${el}
    Wait For Loading Buffer

Setup ChromeDriver Path
    [Documentation]    Dynamically determines the correct ChromeDriver path.
    ...                Returns the path to the bundled Mac driver if running locally,
    ...                otherwise returns None to rely on the system PATH (CI).
    ...                
    ...                NOTE: Local Chrome auto-updates frequently; default to Selenium-managed
    ...                driver unless USE_BUNDLED_CHROMEDRIVER=true is explicitly set.
    
    # Check if running in GitHub Actions
    ${is_github_actions}=    Get Environment Variable    GITHUB_ACTIONS    default=false
    
    IF    '${is_github_actions}' == 'true'
        Log To Console    \n--- CI DETECTED (GitHub Actions) ---
        Log To Console    Bypassing local driver, relying on system PATH.
        RETURN    ${None}
    END
    
    # Local default: rely on Selenium Manager / system PATH (more robust with auto-updating Chrome)
    ${use_bundled}=    Get Environment Variable    USE_BUNDLED_CHROMEDRIVER    default=false
    IF    '${use_bundled}' != 'true'
        Log To Console    \n--- LOCAL MAC DETECTED ---
        Log To Console    Using Selenium-managed driver (bundled ChromeDriver disabled).
        RETURN    ${None}
    END
    
    # Opt-in: Use bundled Mac driver
    ${local_driver}=    Normalize Path    ${CURDIR}/../../chromedriver-mac-x64/chromedriver
    
    ${exists}=    Run Keyword And Return Status    File Should Exist    ${local_driver}
    
    IF    ${exists}
        Log To Console    \n--- LOCAL MAC DETECTED ---
        Log To Console    Using bundled driver: ${local_driver}
        RETURN    ${local_driver}
    ELSE
        Log To Console    \n--- LOCAL ENVIRONMENT DETECTED (Driver Not Found) ---
        Log To Console    ⚠ Bundled driver not found at ${local_driver}. Falling back to system PATH.
        RETURN    ${None}
    END

Sanitize ChromeDriver Path
    [Documentation]    Removes stale /usr/local/bin chromedriver from PATH so Selenium Manager can match Chrome.
    Evaluate    __import__('os').environ.update({'PATH': ':'.join([p for p in __import__('os').environ.get('PATH', '').split(':') if p not in ('/usr/local/bin',)])})

Robust Select From List By Label
    [Arguments]    ${locator}    ${label}
    Wait Until Element Is Visible    ${locator}    timeout=10s
    ${el}=    Get WebElement    ${locator}
    Execute Javascript    
    ...    var select = arguments[0];
    ...    var label = arguments[1];
    ...    for (var i = 0; i < select.options.length; i++) {
    ...        if (select.options[i].text === label) {
    ...            select.selectedIndex = i;
    ...            select.dispatchEvent(new Event('change'));
    ...            break;
    ...        }
    ...    }
    ...    ARGUMENTS    ${el}    ${label}

Robust Select From List By Index
    [Arguments]    ${locator}    ${index}
    Wait Until Element Is Visible    ${locator}    timeout=10s
    ${el}=    Get WebElement    ${locator}
    Execute Javascript    
    ...    var select = arguments[0];
    ...    var idx = parseInt(arguments[1]);
    ...    if (idx >= 0 && idx < select.options.length) {
    ...        select.selectedIndex = idx;
    ...        select.dispatchEvent(new Event('change'));
    ...    }
    ...    ARGUMENTS    ${el}    ${index}