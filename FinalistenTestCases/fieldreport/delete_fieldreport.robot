*** Settings ***
Documentation    Test suite for verifying Delete button functionality on Field Report.
...              
...              Test Flow:
...              1. Create a new field report (setup)
...              2. Navigate to edit page
...              3. Click Delete button
...              4. Accept confirmation dialog
...              5. Verify field report no longer exists
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
${INSTALLER_DROPDOWN}             id=id_installer_name
${SAVE_BUTTON}                    css=button.save

# Action Buttons
${DELETE_BUTTON}                  id=remove_fieldreport

# Initial Values (for creation)
${INITIAL_WORK_DATE}              2025-10-20

# Test State Variables
${CREATED_FIELDREPORT_ID}         ${EMPTY}

*** Test Cases ***
Test Delete Field Report
    [Documentation]    Test that Delete button removes the field report.
    ...                Verify field report cannot be accessed after deletion.
    [Tags]    fieldreport    delete    validation
    [Setup]    Create Field Report For Delete Test
    
    # Navigate to edit page
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${DELETE_BUTTON}    timeout=15s
    Log To Console    ======== TESTING DELETE FUNCTIONALITY FOR FIELD REPORT ${CREATED_FIELDREPORT_ID} ========
    
    # ======== VERIFY FIELD REPORT EXISTS ========
    Log To Console    \n--- Verifying Field Report Exists ---
    ${customer}=    Get Selected List Label    ${CUSTOMER_DROPDOWN}
    Log To Console    Field Report exists with Customer: ${customer}
    
    # ======== CLICK DELETE BUTTON ========
    Log To Console    \n--- Clicking DELETE Button ---
    Click Element    ${DELETE_BUTTON}
    Sleep    1s
    
    # Accept confirmation dialog
    ${alert_text}=    Handle Alert    action=ACCEPT    timeout=5s
    Log To Console    ✓ Accepted confirmation dialog: ${alert_text}
    Sleep    2s
    
    # ======== VERIFY NAVIGATED AWAY FROM EDIT PAGE ========
    ${current_url}=    Get Location
    ${is_on_list}=    Run Keyword And Return Status    Should Contain    ${current_url}    /fieldreport/list/
    IF    ${is_on_list}
        Should Not Contain    ${current_url}    /edit/    msg=Should not be on edit page after delete
        Log To Console    ✓ Navigated to list page after deletion
    END
    
    # ======== VERIFY FIELD REPORT NO LONGER EXISTS ========
    Log To Console    \n--- Verifying Field Report Was Deleted ---
    ${deleted_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${deleted_url}
    Sleep    2s
    
    # Verify we get an error or redirect (field report doesn't exist)
    ${page_source}=    Get Source
    ${not_found}=    Run Keyword And Return Status    Should Contain Any    ${page_source}    not found    does not exist    404    error
    
    ${current_url_check}=    Get Location
    ${redirected}=    Run Keyword And Return Status    Should Not Contain    ${current_url_check}    ${CREATED_FIELDREPORT_ID}
    
    # Either we got a 404/error OR we were redirected away
    ${delete_confirmed}=    Evaluate    ${not_found} or ${redirected}
    
    IF    ${delete_confirmed}
        Log To Console    ✓ Field Report ${CREATED_FIELDREPORT_ID} successfully deleted (no longer accessible)
    ELSE
        # Check if page shows the deleted report
        ${still_exists}=    Run Keyword And Return Status    Page Should Contain Element    ${CUSTOMER_DROPDOWN}
        IF    not ${still_exists}
            Log To Console    ✓ Field Report ${CREATED_FIELDREPORT_ID} successfully deleted
        ELSE
            Fail    Field Report ${CREATED_FIELDREPORT_ID} still exists after deletion!
        END
    END
    
    Log To Console    \n======== DELETE TEST COMPLETED SUCCESSFULLY! ========
    
    [Teardown]    Close All Browsers

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

Create Field Report For Delete Test
    [Documentation]    Create a new field report for delete testing
    Login To Application
    
    Log To Console    ======== CREATING FIELD REPORT FOR DELETE TEST ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Select first available customer
    Select From List By Index    ${CUSTOMER_DROPDOWN}    1
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Select first available project
    Select From List By Index    ${PROJECT_DROPDOWN}    1
    ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Select first available subproject
    Select From List By Index    ${SUBPROJECT_DROPDOWN}    1
    
    # Set work date
    Input Text    ${WORK_DATE_INPUT}    ${INITIAL_WORK_DATE}
    
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
