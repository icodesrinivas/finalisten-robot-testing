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
    
    Wait Until Element Is Visible    ${COPY_BUTTON}    timeout=10s
    ${copy_url_attr}=    Get Element Attribute    ${COPY_BUTTON}    url-copy-fieldreport
    Log To Console    Copy URL from attribute: ${copy_url_attr}
    
    ${copy_el}=    Get WebElement    ${COPY_BUTTON}
    Execute Javascript    arguments[0].scrollIntoView({block: "center", behavior: "instant"});    ARGUMENTS    ${copy_el}
    Sleep    1s
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${copy_el}
    Sleep    2s
    
    # Handle confirmation alert
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=5s
    
    # ======== VERIFY NAVIGATED TO NEW FIELD REPORT EDIT PAGE ========
    ${current_url}=    Get Location
    Log To Console    Current URL after Copy attempt: ${current_url}
    
    # Check if ID changed
    ${copied_id_pre}=    Run Keyword And Ignore Error    Extract And Verify Fieldreport ID
    
    # FALLBACK: If still on original ID or on list page, try navigating directly
    IF    'copy_fieldreport' in '${current_url}' or '${current_url}' == '${FIELDREPORT_LIST_URL}' or '${copied_id_pre}[1]' == '${CREATED_FIELDREPORT_ID}'
        Log To Console    ⚠ Copy action redirected to list or stayed on same ID. Attempting direct navigation...
        Go To    https://preproderp.finalisten.se${copy_url_attr}
        Sleep    3s
    END

    # The copy endpoint may not redirect; extract new ID from response and open edit page
    ${copy_location}=    Get Location
    IF    'copy_fieldreport' in '${copy_location}'
        ${copy_src}=    Get Source
        ${id_matches}=    Get Regexp Matches    ${copy_src}    /fieldreport/list/([A-Za-z0-9]{6})/edit/    1
        ${has_match}=    Run Keyword And Return Status    Should Not Be Empty    ${id_matches}
        IF    ${has_match}
            ${copied_id}=    Set Variable    ${id_matches}[0]
            Go To    ${FIELDREPORT_LIST_URL}${copied_id}/edit/
            Wait Until Keyword Succeeds    10x    3s    Location Should Contain    /edit/
        ELSE
            Fail    Copy Action Failed: Could not extract new Field Report ID from copy response.
        END
    ELSE
        ${copied_id}=    Extract And Verify Fieldreport ID
    END
    
    IF    '${copied_id}' == '${CREATED_FIELDREPORT_ID}'
        Fail    Copy Action Failed: Still on original Field Report ID ${copied_id}.
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
    
    [Teardown]    Cleanup All Fieldreports

*** Keywords ***
Create Field Report For Copy Test
    [Documentation]    Create a new field report for copy testing
    Open And Login
    Setup Dynamic Test Data
    
    Log To Console    ======== CREATING FIELD REPORT FOR COPY TEST ========
    Go To    https://preproderp.finalisten.se/fieldreport/create/
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    Select Customer And Project    customer=${DB_CUSTOMER}    project=${DB_PROJECT}
    
    # Set work date
    Input Text    ${WORK_DATE_INPUT}    ${INITIAL_WORK_DATE}
    
    # Set total hours
    Input Text    ${TOTAL_HOURS_INPUT}    ${INITIAL_TOTAL_HOURS}
    
    # Set message
    Input Text    ${MESSAGE_TO_APPROVER}    ${INITIAL_MESSAGE}
    
    # Select installer
    Select From List By Index    ${INSTALLER_DROPDOWN}    1
    
    # Save the field report
    Wait Until Element Is Visible    ${SAVE_BUTTON}    timeout=30s
    Click Element    ${SAVE_BUTTON}
    
    # Extract field report ID from URL
    Wait Until Keyword Succeeds    5x    5s    Location Should Contain    /edit/
    ${id}=    Extract And Verify Fieldreport ID
    Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${id}
    Log To Console    ✓ Created Field Report ID: ${id}

Cleanup All Fieldreports
    [Documentation]    Delete both original and copied fieldreports
    Log To Console    ======== CLEANUP: Deleting Field Reports ========
    
    # Delete copied field report first
    IF    '${COPIED_FIELDREPORT_ID}' != '${EMPTY}'
        Log To Console    Cleaning up copied report: ${COPIED_FIELDREPORT_ID}
        Run Keyword And Ignore Error    Perform Deletion For ID    ${COPIED_FIELDREPORT_ID}
    END
    
    # Delete original field report
    IF    '${CREATED_FIELDREPORT_ID}' != '${EMPTY}'
        Log To Console    Cleaning up original report: ${CREATED_FIELDREPORT_ID}
        Run Keyword And Ignore Error    Perform Deletion For ID    ${CREATED_FIELDREPORT_ID}
    END
    
    Close All Browsers
