*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    DatabaseKeywords.py


*** Variables ***
${BROWSER}        chrome
${URL}           https://preproderp.finalisten.se/login/
${USERNAME}      erpadmin@finalisten.se
${PASSWORD}      Djangocrm123
${LOGIN_BUTTON}  xpath=//button[@type='submit' and contains(@class,'btn-primary') and contains(@class,'btn-block')]
${HOMEPAGE_URL}  https://preproderp.finalisten.se/homepage/
${CHROME_OPTIONS}    add_argument("--ignore-certificate-errors");add_argument("--disable-web-security");add_argument("--allow-running-insecure-content");add_argument("--window-size=1920,1080");add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage")

# Global Field Report Variables for cleanup
${FIELDREPORT_LIST_URL}           https://preproderp.finalisten.se/fieldreport/list/
${DELETE_BUTTON}                  id=remove_fieldreport
${CREATED_FIELDREPORT_ID}         ${EMPTY}

*** Keywords ***
Open And Login
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open Browser    ${URL}    ${BROWSER}    options=${CHROME_OPTIONS}
    Set Window Size    1920    1080
    Maximize Browser Window
    Set Selenium Implicit Wait    15s
    Set Selenium Timeout    60s
    Sleep    5s
    
    # Force Language to English via direct DB query as early as possible
    Force User Language To English    ${USERNAME}
    
    Handle SSL Warning
    
    # Wait for page to fully load

    Execute Javascript    return document.readyState === 'complete'
    Sleep    3s
    
    # Use Presence check first as it's more robust in headless mode
    Wait Until Page Contains Element    xpath=//input[@name='username']    timeout=30s
    Input Text    xpath=//input[@name='username']    ${USERNAME}
    Wait Until Page Contains Element    xpath=//input[@name='password']    timeout=20s
    Input Text    xpath=//input[@name='password']    ${PASSWORD}
    Click Button    ${LOGIN_BUTTON}
    Wait Until Location Contains    ${HOMEPAGE_URL}    timeout=30s
    
    # Wait for page to fully load after login
    Sleep    8s
    Execute Javascript    return document.readyState === 'complete'
    Execute Javascript    window.scrollTo(0, 0);
    Sleep    2s
    
    # MOBILE/HEADLESS FALLBACK: Try multiple approaches to ensure menu is accessible
    ${is_visible}=    Run Keyword And Return Status    Element Should Be Visible    id=register
    IF    not ${is_visible}
        Log To Console    Register menu not visible, trying fallback approaches...
        # Try clicking navbar toggler for mobile view
        ${toggler_exists}=    Run Keyword And Return Status    Page Should Contain Element    css=.navbar-toggler
        IF    ${toggler_exists}
            ${toggler_visible}=    Run Keyword And Return Status    Element Should Be Visible    css=.navbar-toggler
            IF    ${toggler_visible}
                Click Element    css=.navbar-toggler
                Sleep    3s
            END
        END
        # Try scrolling to make element visible
        Execute Javascript    var el = document.getElementById('register'); if(el) el.scrollIntoView({behavior: 'smooth', block: 'center'});
        Sleep    2s
    END
    
    # Final wait for navigation element with longer timeout
    Wait Until Page Contains Element    id=register    timeout=30s
    Sleep    3s

Select Customer And Project
    [Documentation]    Robustly select customer and project. 
    ...                If arguments are provided, it tries them first.
    ...                If not provided or if they fail, it fetches valid data from the DB.
    [Arguments]    ${customer}=${EMPTY}    ${project}=${EMPTY}
    
    # Initialize dynamic data if not already set or if we need fresh data
    IF    '${customer}' == '${EMPTY}' or '${project}' == '${EMPTY}'
        ${db_data}=    Get Valid Customer And Project
        ${customer}=    Set Variable If    '${customer}' == '${EMPTY}'    ${db_data['customer']}    ${customer}
        ${project}=    Set Variable If    '${project}' == '${EMPTY}'    ${db_data['project']}    ${project}
    END

    Log To Console    ======== DATA SELECTION: ${customer} / ${project} ========
    
    # 1. SELECT CUSTOMER
    Wait Until Element Is Visible    id=id_related_customer    timeout=20s
    
    # Try specified/fetched customer
    ${status}=    Run Keyword And Return Status    Select From List By Label    id=id_related_customer    ${customer}
    
    # Fallback: Dynamic Fetch (if provided one failed)
    IF    not ${status}
        Log To Console    ⚠ Specified customer '${customer}' not found, fetching valid one from DB...
        ${db_data_retry}=    Get Valid Customer And Project
        Log To Console    Fetched from DB: ${db_data_retry['customer']}
        ${status}=    Run Keyword And Return Status    Select From List By Label    id=id_related_customer    ${db_data_retry['customer']}
        ${project}=    Set Variable    ${db_data_retry['project']}
    END
    
    # Final fallback to index 1
    IF    not ${status}
        Log To Console    ⚠ DB fetching failed or selection failed, selecting customer at index 1...
        Wait Until Keyword Succeeds    5x    1s    List Should Have Options    id=id_related_customer
        Select From List By Index    id=id_related_customer    1
    END
    
    # Trigger AJAX for projects
    ${el}=    Get WebElement    id=id_related_customer
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${el}
    Sleep    5s
    
    # 2. SELECT PROJECT
    Wait Until Element Is Visible    id=id_related_project    timeout=20s
    
    # Try specified/fetched project
    ${p_status}=    Run Keyword And Return Status    Select From List By Label    id=id_related_project    ${project}
    
    # Fallback: Index 1
    IF    not ${p_status}
        Log To Console    ⚠ Project '${project}' not found, selecting project at index 1...
        Wait Until Keyword Succeeds    5x    2s    List Should Have Options    id=id_related_project
        Select From List By Index    id=id_related_project    1
    END
    
    # Trigger AJAX for subprojects
    ${el2}=    Get WebElement    id=id_related_project
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${el2}
    Sleep    3s
    
    # 3. SELECT SUBPROJECT
    Wait Until Element Is Visible    id=id_related_subproject    timeout=15s
    Wait Until Keyword Succeeds    5x    2s    List Should Have Options    id=id_related_subproject
    Select From List By Index    id=id_related_subproject    1
    
    Log To Console    ✓ Selection completed successfully.

Setup Dynamic Test Data
    [Documentation]    Fetches valid test data from DB and sets as suite variables.
    ${db_data}=    Get Valid Customer And Project
    ${installer}=    Get Valid Installer Name
    Set Suite Variable    ${DB_CUSTOMER}    ${db_data['customer']}
    Set Suite Variable    ${DB_PROJECT}     ${db_data['project']}
    Set Suite Variable    ${DB_INSTALLER}   ${installer}
    Log To Console    ✓ Setup Dynamic Data: ${DB_CUSTOMER} / ${DB_PROJECT} / ${DB_INSTALLER}

List Should Have Options
    [Arguments]    ${locator}
    ${options}=    Get List Items    ${locator}
    ${count}=    Get Length    ${options}
    # Count > 1 because typically there is a "Select..." or empty option at index 0
    Should Be True    ${count} > 1    msg=Dropdown ${locator} has no options to select.

Extract And Verify Fieldreport ID
    [Documentation]    Extract ID from current URL and verify it is not empty.
    ${current_url}=    Get Location
    ${id}=    Run Keyword If    '/edit/' in '${current_url}'    Evaluate    $current_url.split('/')[-3]
    ...    ELSE IF    '/list/' in '${current_url}' and '${current_url}'.endswith('/') == False    Evaluate    $current_url.split('/')[-2]
    ...    ELSE    Set Variable    ${EMPTY}
    
    IF    '${id}' == '${EMPTY}'
        Fatal Error    Failed to extract Field Report ID from URL: ${current_url}. Field Report was likely not created or saved successfully.
    END
    
    [Return]    ${id}

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
    
    # Check if we have an ID to delete
    ${has_id}=    Run Keyword And Return Status    Should Not Be Empty    ${CREATED_FIELDREPORT_ID}
    
    IF    ${has_id}
        Log To Console    ID to delete: ${CREATED_FIELDREPORT_ID}
        # Navigate directly to the edit page's delete functionality
        ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
        Go To    ${edit_url}
        Sleep    2s
        
        # Check if delete button exists (to avoid failure if already deleted or page error)
        ${delete_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${DELETE_BUTTON}    timeout=10s
        
        IF    ${delete_exists}
            Log To Console    Clicking delete button...
            # Use Javascript click for reliability
            ${del_btn}=    Get WebElement    ${DELETE_BUTTON}
            Execute Javascript    arguments[0].click();    ARGUMENTS    ${del_btn}
            Sleep    1s
            
            # Handle the confirmation alert
            ${alert_present}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=5s
            IF    ${alert_present}
                Log To Console    ✓ Alert accepted.
            ELSE
                Log To Console    ⚠ No alert appeared or could not be handled.
            END
            
            Sleep    2s
            Log To Console    ✓ Field Report ${CREATED_FIELDREPORT_ID} cleaned up.
        ELSE
            Log To Console    ⚠ Delete button not found for ID ${CREATED_FIELDREPORT_ID}. Already deleted?
        END
    ELSE
        Log To Console    No field report ID found for cleanup.
    END

    # Always close all browsers in teardown
    Close Browser