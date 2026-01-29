*** Settings ***
Documentation    Test case for editing fieldreports that have inactive installers.
...              
...              This is a regression test to verify that:
...              - A fieldreport with an installer can be edited without validation errors
...              - The installer field (even if inactive) is preserved during save
...              - No "Select a valid choice" error occurs
...              
...              Bug scenario: When a fieldreport was created with Installer A, and
...              that installer was later made inactive, editing the fieldreport
...              would fail with a 400 Bad Request validation error.
Library          SeleniumLibrary
Library          DateTime
Library          String
Library          Collections
Library          Process
Library          OperatingSystem
Resource         ../keywords/LoginKeyword.robot

*** Variables ***
# URLs
${BASE_URL}                       https://preproderp.finalisten.se
${FIELDREPORT_LIST_URL}           ${BASE_URL}/fieldreport/list/

# Database - set DATABASE_URL environment variable before running
# Can be fetched via: heroku config:get DATABASE_URL --app finalistenerppreprod-eu
${DB_SCRIPT_PATH}                 ${CURDIR}/../../scripts/get_inactive_installers.py

# Filter Selectors
${FILTER_TOGGLE}                  id=fieldreport_list_filter
${START_WORK_DATE_INPUT}          id=start_work_date
${END_WORK_DATE_INPUT}            id=end_work_date
${SEARCH_BUTTON}                  id=fieldreport_list_search

# Form Selectors
${INSTALLER_DROPDOWN}             id=id_installer_name
${EDIT_GENERAL_DATA_BUTTON}       id=EditGeneralDataButton
${SAVE_GENERAL_DATA_BUTTON}       id=fieldreport_general_data_save
${TOTAL_HOURS_INPUT}              id=id_total_work_hours
${MESSAGE_TO_APPROVER}            id=id_message_to_approver

# Table Selectors
${FIELDREPORT_ROW}                css=.fieldreport_rows
${FIELDREPORT_EDIT_LINK}          xpath=//tr[contains(@class, 'fieldreport_rows')]//a[contains(@href, '/edit/')]

# Test State
${ORIGINAL_INSTALLER}             ${EMPTY}
${ORIGINAL_HOURS}                 ${EMPTY}
${TEST_FIELDREPORT_URL}           ${EMPTY}

*** Test Cases ***
Verify Fieldreport With Inactive Installer Can Be Edited And Saved
    [Documentation]    Regression test: Verify fieldreport with INACTIVE installer can be edited and saved
    ...                without validation errors. This tests the fix for the inactive installer bug
    ...                where saving would fail with "Select a valid choice" if the assigned installer 
    ...                was marked inactive in the employee record.
    ...                Uses real inactive installers: Adam, Ahmad Almoussa, Ahmad Hanoush, Aklilu
    [Tags]    fieldreport    inactive_installer    regression    edit    save    critical
    [Setup]    Open And Login
    
    Log To Console    ======== TEST: Inactive Installer Edit Regression ========
    
    # Step 1: Navigate to fieldreport list
    Go To    ${FIELDREPORT_LIST_URL}
    Wait Until Page Contains Element    ${FILTER_TOGGLE}    timeout=15s
    Log To Console    ✓ Fieldreport list loaded
    
    # Step 2: Find a fieldreport with an installer
    Find Fieldreport With Installer
    
    # Step 3: Record current installer value
    Wait Until Page Contains Element    ${INSTALLER_DROPDOWN}    timeout=15s
    ${installer_value}=    Get Selected List Label    ${INSTALLER_DROPDOWN}
    Set Suite Variable    ${ORIGINAL_INSTALLER}    ${installer_value}
    Log To Console    Original Installer: ${ORIGINAL_INSTALLER}
    
    # Step 4: Enable edit mode
    Enable Edit Mode
    
    # Step 5: Record current hours and modify
    ${current_hours}=    Get Value    ${TOTAL_HOURS_INPUT}
    Set Suite Variable    ${ORIGINAL_HOURS}    ${current_hours}
    Log To Console    Original Hours: ${ORIGINAL_HOURS}
    
    # Modify the hours slightly (add/subtract 1)
    ${modified_hours}=    Calculate Modified Hours    ${current_hours}
    Clear Element Text    ${TOTAL_HOURS_INPUT}
    Input Text    ${TOTAL_HOURS_INPUT}    ${modified_hours}
    Log To Console    Modified Hours to: ${modified_hours}
    
    # Step 6: Save and verify no errors
    Save And Verify No Errors
    
    # Step 7: Verify installer is preserved
    Verify Installer Preserved
    
    # Step 8: Restore original hours (cleanup)
    Restore Original Hours
    
    Log To Console    ======== TEST PASSED: Fieldreport with installer edited successfully ========
    
    [Teardown]    Close All Browsers

*** Keywords ***
Find Fieldreport With Installer
    [Documentation]    Find a fieldreport with an INACTIVE installer and open its edit page
    ...                Dynamically fetches UNAPPROVED fieldreport slugs from the database
    ...                Navigates directly to the edit page using the slug
    
    # Get inactive installer fieldreport slugs from database
    ${db_result}=    Get Inactive Installers From Database
    @{fieldreport_slugs}=    Set Variable    ${db_result}[fieldreport_slugs]
    
    ${slug_count}=    Get Length    ${fieldreport_slugs}
    Log To Console    Found ${slug_count} unapproved fieldreports with inactive installers
    Should Be True    ${slug_count} > 0    msg=No unapproved fieldreports with inactive installers found in database
    
    # Get the first fieldreport slug
    ${slug}=    Get From List    ${fieldreport_slugs}    0
    
    # Get installer info for this fieldreport
    ${installer_map}=    Set Variable    ${db_result}[fieldreport_installer_map]
    ${installer_info}=    Set Variable    ${installer_map}[${slug}]
    ${installer_name}=    Set Variable    ${installer_info}[name]
    
    Log To Console    Opening fieldreport ${slug} with inactive installer: ${installer_name}
    
    # Navigate directly to the edit page using the slug
    ${edit_url}=    Set Variable    ${BASE_URL}/fieldreport/list/${slug}/edit/
    Go To    ${edit_url}
    Sleep    5s
    
    # Wait for page to load
    ${page_loaded}=    Run Keyword And Return Status    Wait Until Page Contains Element    ${INSTALLER_DROPDOWN}    timeout=20s
    Should Be True    ${page_loaded}    msg=Edit page did not load for fieldreport ${slug}
    
    # Verify this fieldreport has the inactive installer selected
    ${current_installer}=    Get Selected List Label    ${INSTALLER_DROPDOWN}
    Log To Console    ✓ Fieldreport has installer: ${current_installer}
    Set Suite Variable    ${TEST_FIELDREPORT_URL}    ${edit_url}

Enable Edit Mode
    [Documentation]    Click the Edit button to enable form editing
    
    Wait Until Element Is Visible    ${EDIT_GENERAL_DATA_BUTTON}    timeout=10s
    ${edit_btn}=    Get WebElement    ${EDIT_GENERAL_DATA_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${edit_btn}
    Sleep    2s
    
    # Verify fields are now editable
    ${hours_enabled}=    Run Keyword And Return Status    Element Should Be Enabled    ${TOTAL_HOURS_INPUT}
    Should Be True    ${hours_enabled}    msg=Total hours input should be enabled after clicking Edit
    Log To Console    ✓ Edit mode enabled

Calculate Modified Hours
    [Documentation]    Calculate a modified hours value (add 1 or subtract 1)
    [Arguments]    ${current_hours}
    
    # Handle Swedish locale (comma as decimal separator)
    ${clean_hours}=    Replace String    ${current_hours}    ,    .
    ${clean_hours}=    Replace String    ${clean_hours}    ${SPACE}    ${EMPTY}
    
    # If empty, default to 1
    ${is_empty}=    Run Keyword And Return Status    Should Be Empty    ${clean_hours}
    IF    ${is_empty}
        RETURN    1
    END
    
    # Parse as number and add 1
    ${num_hours}=    Convert To Number    ${clean_hours}
    ${new_hours}=    Evaluate    ${num_hours} + 1
    
    RETURN    ${new_hours}

Save And Verify No Errors
    [Documentation]    Click Save and verify the form saves without errors
    
    # Scroll to save button if needed
    Execute Javascript    window.scrollTo(0, 0);
    Sleep    1s
    
    Wait Until Element Is Visible    ${SAVE_GENERAL_DATA_BUTTON}    timeout=10s
    ${save_btn}=    Get WebElement    ${SAVE_GENERAL_DATA_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    
    Sleep    3s
    
    # Check for any error messages
    ${has_error_alert}=    Run Keyword And Return Status    Page Should Contain Element    css=.alert-danger
    ${has_validation_error}=    Run Keyword And Return Status    Page Should Contain    Select a valid choice
    ${has_400_error}=    Run Keyword And Return Status    Page Should Contain    400 Bad Request
    
    IF    ${has_error_alert}
        ${error_text}=    Get Text    css=.alert-danger
        Log To Console    ⚠ Error alert found: ${error_text}
        Fail    Save failed with error: ${error_text}
    END
    
    IF    ${has_validation_error}
        Fail    Validation error: Select a valid choice - This indicates the inactive installer bug!
    END
    
    IF    ${has_400_error}
        Fail    400 Bad Request error occurred during save
    END
    
    # Verify we're still on the edit page (successful save)
    Wait Until Page Contains Element    ${INSTALLER_DROPDOWN}    timeout=10s
    Log To Console    ✓ Save completed without errors

Verify Installer Preserved
    [Documentation]    Verify the installer field still has the original value after save
    
    ${current_installer}=    Get Selected List Label    ${INSTALLER_DROPDOWN}
    Should Be Equal    ${current_installer}    ${ORIGINAL_INSTALLER}    msg=Installer value was not preserved after save!
    Log To Console    ✓ Installer preserved: ${current_installer}

Restore Original Hours
    [Documentation]    Restore the original hours value to clean up test changes
    
    # Re-enable edit mode
    ${edit_visible}=    Run Keyword And Return Status    Element Should Be Visible    ${EDIT_GENERAL_DATA_BUTTON}
    IF    ${edit_visible}
        ${edit_btn}=    Get WebElement    ${EDIT_GENERAL_DATA_BUTTON}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${edit_btn}
        Sleep    2s
    END
    
    # Restore original hours
    Clear Element Text    ${TOTAL_HOURS_INPUT}
    Input Text    ${TOTAL_HOURS_INPUT}    ${ORIGINAL_HOURS}
    
    ${save_btn}=    Get WebElement    ${SAVE_GENERAL_DATA_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    2s
    
    Log To Console    ✓ Original hours restored

Get Inactive Installers From Database
    [Documentation]    Execute Python script to query database for inactive installers with fieldreports
    ...                Returns a dictionary with installer_ids and installer_names lists
    ...                Requires DATABASE_URL environment variable to be set
    
    # Check if DATABASE_URL is set
    ${db_url}=    Get Environment Variable    DATABASE_URL    default=${EMPTY}
    Should Not Be Empty    ${db_url}    msg=DATABASE_URL environment variable must be set. Run: export DATABASE_URL=$(heroku config:get DATABASE_URL --app finalistenerppreprod-eu)
    
    # Run the Python script
    ${result}=    Run Process    python    ${DB_SCRIPT_PATH}    shell=True
    Log To Console    Database query completed with exit code: ${result.rc}
    
    # Parse JSON output
    ${json_output}=    Set Variable    ${result.stdout}
    Log To Console    DB Response: ${json_output}
    
    # Check for errors
    Should Be Equal As Integers    ${result.rc}    0    msg=Database script failed: ${result.stderr}
    
    # Parse JSON to Robot dictionary
    ${parsed}=    Evaluate    json.loads('''${json_output}''')    json
    
    # Verify success
    Should Be True    ${parsed}[success]    msg=Database query failed: ${parsed.get('error', 'Unknown error')}
    
    [Return]    ${parsed}
