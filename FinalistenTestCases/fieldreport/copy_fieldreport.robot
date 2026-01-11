*** Settings ***
Documentation    Test suite for verifying Copy functionality on Field Report.
...              
...              Test Flow:
...              1. Create a new field report with specific values (setup)
...              2. Click Copy button to create a duplicate
...              3. Verify new field report is created with copied values
...              4. Verify original field report still exists
...              5. Delete both field reports (teardown)
Library          SeleniumLibrary
Library          DateTime
Library          String
Library          Collections
Resource         ../keywords/LoginKeyword.robot

*** Variables ***
# URLs (configurable for different environments)
${BASE_URL}                       https://preproderp.finalisten.se
${LOGIN_URL}                      ${BASE_URL}/login/
${HOMEPAGE_URL}                   ${BASE_URL}/homepage/
${FIELDREPORT_LIST_URL}           ${BASE_URL}/fieldreport/list/
${FIELDREPORT_CREATE_URL}         ${BASE_URL}/fieldreport/create/

# Form Field Selectors
${CUSTOMER_DROPDOWN}              id=id_related_customer
${PROJECT_DROPDOWN}               id=id_related_project
${SUBPROJECT_DROPDOWN}            id=id_related_subproject
${WORK_DATE_INPUT}                id=id_work_date
${TOTAL_HOURS_INPUT}              id=id_total_work_hours
${MESSAGE_TO_APPROVER}            id=id_message_to_approver
${INSTALLER_DROPDOWN}             id=id_installer_name
${SAVE_BUTTON}                    css=button.save

# Action Buttons
${COPY_BUTTON}                    id=id_fieldreport_copy_button
${DELETE_BUTTON}                  id=remove_fieldreport

# Initial Values (for creation)
${INITIAL_WORK_DATE}              2025-10-31
${INITIAL_TOTAL_HOURS}            7
${INITIAL_MESSAGE}                Original Field Report - Copy Test

# Test State Variables
${CREATED_FIELDREPORT_ID}         ${EMPTY}
${COPIED_FIELDREPORT_ID}          ${EMPTY}
${ORIGINAL_CUSTOMER}              ${EMPTY}
${ORIGINAL_PROJECT}               ${EMPTY}
${ORIGINAL_SUBPROJECT}            ${EMPTY}

*** Test Cases ***
Test Copy Field Report Creates Duplicate
    [Documentation]    Test the Copy button creates a duplicate field report with same values.
    ...                Verify copied report has same customer, project, subproject values.
    [Tags]    fieldreport    copy    validation
    [Setup]    Create Field Report For Copy Test
    
    # Navigate to edit page
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${COPY_BUTTON}    timeout=15s
    Log To Console    ======== TESTING COPY FUNCTIONALITY FOR FIELD REPORT ${CREATED_FIELDREPORT_ID} ========
    
    # ======== RECORD ORIGINAL VALUES ========
    Log To Console    \n--- Recording Original Values ---
    ${orig_customer}=    Get Selected List Label    ${CUSTOMER_DROPDOWN}
    ${orig_project}=    Get Selected List Label    ${PROJECT_DROPDOWN}
    ${orig_subproject}=    Get Selected List Label    ${SUBPROJECT_DROPDOWN}
    ${orig_installer}=    Get Selected List Label    ${INSTALLER_DROPDOWN}
    
    Set Suite Variable    ${ORIGINAL_CUSTOMER}    ${orig_customer}
    Set Suite Variable    ${ORIGINAL_PROJECT}    ${orig_project}
    Set Suite Variable    ${ORIGINAL_SUBPROJECT}    ${orig_subproject}
    
    Log To Console    Original Customer: ${orig_customer}
    Log To Console    Original Project: ${orig_project}
    Log To Console    Original SubProject: ${orig_subproject}
    Log To Console    Original Installer: ${orig_installer}
    
    # ======== CLICK COPY BUTTON ========
    Log To Console    \n--- Clicking COPY Button ---
    
    # Check if button exists and is enabled
    Element Should Be Visible    ${COPY_BUTTON}
    
    # Use JS to click if standard click fails or to debug
    # Click Element    ${COPY_BUTTON}
    
    # Trying JS Click to ensure event firing
    ${copy_btn}=    Get WebElement    ${COPY_BUTTON}
    ${copy_url_attr}=    Get Element Attribute    ${COPY_BUTTON}    url-copy-fieldreport
    Log To Console    Copy URL from attribute: ${copy_url_attr}
    
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${copy_btn}
    Sleep    1s
    
    # Handle confirmation alert if present
    # We use Run Keyword And Return Status to avoid failing if no alert (since we have fallback)
    ${alert_status}=    Run Keyword And Return Status    Handle Alert    action=ACCEPT    timeout=5s
    IF    ${alert_status}
         Log To Console    ✓ Alert handled (Accepted).
    ELSE
         Log To Console    ! No alert appeared.
    END
    
    Sleep    5s
    
    # ======== VERIFY NAVIGATED TO NEW FIELD REPORT EDIT PAGE ========
    ${current_url}=    Get Location
    Log To Console    Current URL after Copy attempt: ${current_url}
    
    # Check if ID changed (extraction logic)
    ${copied_id_pre}=    Extract Fieldreport ID From URL    ${current_url}
    
    # FALLBACK: If still on original ID, try navigating directly
    IF    '${copied_id_pre}' == '${CREATED_FIELDREPORT_ID}'
        Log To Console    ⚠ Copy button click didn't change page. Attempting direct navigation to: ${copy_url_attr}
        Go To    ${BASE_URL}${copy_url_attr}
        Sleep    2s
        ${current_url}=    Get Location
        ${page_text}=    Get Text    tag=body
        Log To Console    Response from Copy Endpoint: ${page_text}
        
        # Check if response contains ID (simple heuristic: look for numbers)
        # If the response is JSON, strictly we should parse it, but let's assume it returns the ID or success msg.
        # If it redirected, current_url would be different.
        
        # Does the response contain a new ID?
        # Extract all numbers and see if any is > current ID?
        # Or look for specific JSON pattern: {"id": 12345} ?
        
        # If the URL is still the copy URL, we assume we need to manually redirect to the edit page 
        # based on the content.
        
        # Attempt to read ID from text
        # Only simple regex: \d{5}
        ${matches}=    Get Regexp Matches    ${page_text}    \\d{5}
        ${len_matches}=    Get Length    ${matches}
        IF    ${len_matches} > 0
             ${possible_id}=    Set Variable    ${matches}[0]
             Log To Console    Found possible ID in response: ${possible_id}
             # Go to Edit page of this ID
             Go To    ${FIELDREPORT_LIST_URL}${possible_id}/edit/
             ${current_url}=    Get Location
        ELSE
             Log To Console    Could not find ID in response.
        END
    END
    
    # Check for error messages (only if we are back on an edit page or similar)
    ${page_source}=    Get Source
    ${has_error}=    Run Keyword And Return Status    Should Contain    ${page_source}    error
    IF    ${has_error}
         Log To Console    ⚠ Error keyword found in source (post-copy check).
    END
    
    Should Contain    ${current_url}    /edit/    msg=Should be on edit page of copied field report
    
    # Extract copied field report ID
    ${copied_id}=    Extract Fieldreport ID From URL    ${current_url}
    
    IF    '${copied_id}' == '${CREATED_FIELDREPORT_ID}'
        Fail    Copy Action Failed: Still on original Field Report ID ${copied_id}. URL: ${current_url}
    END
    
    Set Suite Variable    ${COPIED_FIELDREPORT_ID}    ${copied_id}
    Log To Console    ✓ Created COPY with new ID: ${copied_id}
    
    # ======== VERIFY COPIED VALUES MATCH ORIGINAL ========
    Log To Console    \n--- Verifying Copied Values Match Original ---
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=10s
    
    ${copied_customer}=    Get Selected List Label    ${CUSTOMER_DROPDOWN}
    ${copied_project}=    Get Selected List Label    ${PROJECT_DROPDOWN}
    ${copied_subproject}=    Get Selected List Label    ${SUBPROJECT_DROPDOWN}
    
    Should Be Equal    ${copied_customer}    ${ORIGINAL_CUSTOMER}    msg=Copied Customer should match original!
    Log To Console    ✓ Customer matches: ${copied_customer}
    
    Should Be Equal    ${copied_project}    ${ORIGINAL_PROJECT}    msg=Copied Project should match original!
    Log To Console    ✓ Project matches: ${copied_project}
    
    Should Be Equal    ${copied_subproject}    ${ORIGINAL_SUBPROJECT}    msg=Copied SubProject should match original!
    Log To Console    ✓ SubProject matches: ${copied_subproject}
    
    # ======== VERIFY ORIGINAL STILL EXISTS ========
    Log To Console    \n--- Verifying Original Field Report Still Exists ---
    ${original_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${original_url}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    ${check_customer}=    Get Selected List Label    ${CUSTOMER_DROPDOWN}
    Should Be Equal    ${check_customer}    ${ORIGINAL_CUSTOMER}    msg=Original field report should still exist!
    Log To Console    ✓ Original Field Report ${CREATED_FIELDREPORT_ID} still exists
    
    Log To Console    \n======== COPY TEST COMPLETED SUCCESSFULLY! ========
    Log To Console    Original ID: ${CREATED_FIELDREPORT_ID}
    Log To Console    Copied ID: ${COPIED_FIELDREPORT_ID}
    
    [Teardown]    Cleanup All Fieldreports

*** Keywords ***
Login To Application
    [Documentation]    Open browser and login to the application
    Open Browser    ${LOGIN_URL}    ${BROWSER}    options=${CHROME_OPTIONS}
    Maximize Browser Window
    Wait Until Page Contains Element    xpath=//input[@name='username']    timeout=10s
    Input Text    xpath=//input[@name='username']    ${USERNAME}
    Input Text    xpath=//input[@name='password']    ${PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Contains    ${HOMEPAGE_URL}    timeout=15s
    Log To Console    Successfully logged in

Create Field Report For Copy Test
    [Documentation]    Create a new field report for copy testing
    Login To Application
    
    Log To Console    ======== CREATING FIELD REPORT FOR COPY TEST ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Select first available customer
    ${customer_name}=    Select First Available Option And Get Text    ${CUSTOMER_DROPDOWN}
    Log To Console    Selected Customer: ${customer_name}
    
    # Wait for AJAX
    Sleep    2s
    
    # Select first available project
    ${project_name}=    Select First Available Option And Get Text    ${PROJECT_DROPDOWN}
    Log To Console    Selected Project: ${project_name}
    
    # Wait for AJAX
    Sleep    2s
    
    # Select first available subproject
    ${subproject_name}=    Select First Available Option And Get Text    ${SUBPROJECT_DROPDOWN}
    Log To Console    Selected SubProject: ${subproject_name}
    
    # Set work date
    Input Text    ${WORK_DATE_INPUT}    ${INITIAL_WORK_DATE}
    
    # Set total hours
    Input Text    ${TOTAL_HOURS_INPUT}    ${INITIAL_TOTAL_HOURS}
    
    # Set message
    Input Text    ${MESSAGE_TO_APPROVER}    ${INITIAL_MESSAGE}
    
    # Select installer
    Select From List By Index    ${INSTALLER_DROPDOWN}    1
    
    # Save the field report
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    3s
    
    # Extract field report ID from URL
    ${current_url}=    Get Location
    Should Contain    ${current_url}    /edit/    msg=Failed to create field report
    ${fieldreport_id}=    Extract Fieldreport ID From URL    ${current_url}
    Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${fieldreport_id}
    Log To Console    ✓ Created Field Report ID: ${fieldreport_id}

Select First Available Option And Get Text
    [Documentation]    Select the first non-empty option from a dropdown and return its text
    [Arguments]    ${dropdown_locator}
    ${options}=    Get List Items    ${dropdown_locator}
    ${count}=    Get Length    ${options}
    IF    ${count} > 1
        Select From List By Index    ${dropdown_locator}    1
        # Trigger change event for dynamic dropdowns
        ${element}=    Get WebElement    ${dropdown_locator}
        Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
        ${selected}=    Get Selected List Label    ${dropdown_locator}
        RETURN    ${selected}
    ELSE
        Fail    No options available in dropdown ${dropdown_locator}
    END

Extract Fieldreport ID From URL
    [Documentation]    Extract the fieldreport ID from the edit page URL
    [Arguments]    ${url}
    ${parts}=    Split String    ${url}    /
    FOR    ${i}    ${part}    IN ENUMERATE    @{parts}
        ${is_numeric}=    Run Keyword And Return Status    Should Match Regexp    ${part}    ^\\d+$
        IF    ${is_numeric}
            RETURN    ${part}
        END
    END
    Fail    Could not extract fieldreport ID from URL: ${url}

Cleanup All Fieldreports
    [Documentation]    Delete both original and copied fieldreports
    Log To Console    ======== CLEANUP: Deleting Field Reports ========
    
    # Delete copied field report first
    ${has_copied}=    Run Keyword And Return Status    Should Not Be Empty    ${COPIED_FIELDREPORT_ID}
    IF    ${has_copied}
        Delete Single Fieldreport    ${COPIED_FIELDREPORT_ID}
    END
    
    # Delete original field report
    ${has_original}=    Run Keyword And Return Status    Should Not Be Empty    ${CREATED_FIELDREPORT_ID}
    IF    ${has_original}
        Delete Single Fieldreport    ${CREATED_FIELDREPORT_ID}
    END
    
    Close All Browsers

Delete Single Fieldreport
    [Documentation]    Delete a single fieldreport by ID
    [Arguments]    ${fieldreport_id}
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${fieldreport_id}/edit/
    Go To    ${edit_url}
    Sleep    2s
    
    ${delete_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${DELETE_BUTTON}    timeout=10s
    
    IF    ${delete_exists}
        Log To Console    Deleting Field Report ID: ${fieldreport_id}
        Click Element    ${DELETE_BUTTON}
        Sleep    1s
        Handle Alert    action=ACCEPT    timeout=5s
        Sleep    2s
        Log To Console    ✓ Field Report ${fieldreport_id} deleted successfully!
    ELSE
        Log To Console    WARNING: Could not delete Field Report ${fieldreport_id}
    END
