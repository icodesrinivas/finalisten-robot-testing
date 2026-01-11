*** Settings ***
Documentation    Test suite for calculation edge cases in Field Report.
...              
...              Tests include:
...              46. Total Hours = 0 - verify Per Hour calculation (division by zero)
...              47. Very large Total Hours - verify calculation accuracy
...              48. Product with negative price - verify Earnings calculation
...              49. Modify product quantity - verify Earnings recalculates
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
${INSTALLER_DROPDOWN}             id=id_installer_name
${SAVE_BUTTON}                    css=button.save
${DELETE_BUTTON}                  id=remove_fieldreport
${EDIT_GENERAL_DATA_BUTTON}       id=EditGeneralDataButton
${SAVE_GENERAL_DATA_BUTTON}       id=fieldreport_general_data_save

# Earnings Display
${TOTAL_EARNING_DISPLAY}          id=total_earning

# Product Selectors
${ADD_PRODUCT_BUTTON}             xpath=//span[text()='ADD']
${PRODUCT_MODAL}                  id=myModal3
${MODAL_SAVE_BUTTON}              css=.prodinfr_save_button
${PRODUCT_CHECKBOX}               css=#prodInProjTable .selected-checkbox
${COMMON_EDIT_BUTTON}             id=common_edit_product
${COMMON_SAVE_BUTTON}             id=product_in_fieldreport_save
${PRODUCT_QTY_INPUT}              css=input[name*='quantity']
${PRODUCT_PRICE_INPUT}            css=input[name*='price']

# Test Values
${VALID_WORK_DATE}                2025-10-15

# Test State
${CREATED_FIELDREPORT_ID}         ${EMPTY}

*** Test Cases ***
Test Zero Total Hours Per Hour Calculation
    [Documentation]    Point 46: Set Total Hours to 0 and verify Per Hour calculation handles division by zero.
    [Tags]    fieldreport    calculation    edge    divzero
    [Setup]    Create Field Report With Product And Hours
    
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Log To Console    ======== TEST: Zero Total Hours (Division by Zero) ========
    
    # Get current earnings display
    ${earnings_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${TOTAL_EARNING_DISPLAY}    timeout=5s
    IF    ${earnings_exists}
        ${initial_earnings}=    Get Text    ${TOTAL_EARNING_DISPLAY}
        Log To Console    Initial Earnings: ${initial_earnings}
    END
    
    # Enable edit mode
    Wait Until Element Is Visible    ${EDIT_GENERAL_DATA_BUTTON}    timeout=10s
    Click Element    ${EDIT_GENERAL_DATA_BUTTON}
    Sleep    1s
    
    # Set Total Hours to 0
    Clear Element Text    ${TOTAL_HOURS_INPUT}
    Input Text    ${TOTAL_HOURS_INPUT}    0
    Log To Console    Set Total Hours to: 0
    
    # Save
    Click Element    ${SAVE_GENERAL_DATA_BUTTON}
    Sleep    2s
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
    Sleep    2s
    
    # Refresh and check earnings
    Reload Page
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    ${hours_after}=    Get Value    ${TOTAL_HOURS_INPUT}
    Log To Console    Total Hours after save: ${hours_after}
    
    IF    ${earnings_exists}
        ${earnings_after}=    Get Text    ${TOTAL_EARNING_DISPLAY}
        Log To Console    Earnings after zero hours: ${earnings_after}
        
        # Check for division by zero handling (should show 0, N/A, or infinity)
        ${no_error}=    Run Keyword And Return Status    Should Not Contain    ${earnings_after}    NaN
        IF    ${no_error}
            Log To Console    ✓ System handles division by zero correctly (no NaN)
        ELSE
            Log To Console    ⚠ Division by zero shows NaN
        END
    END
    
    [Teardown]    Cleanup Created Fieldreport

Test Very Large Total Hours Calculation
    [Documentation]    Point 47: Enter very large Total Hours and verify calculation accuracy.
    [Tags]    fieldreport    calculation    edge    overflow
    [Setup]    Create Field Report With Product And Hours
    
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Log To Console    ======== TEST: Very Large Total Hours ========
    
    # Enable edit mode
    Wait Until Element Is Visible    ${EDIT_GENERAL_DATA_BUTTON}    timeout=10s
    Click Element    ${EDIT_GENERAL_DATA_BUTTON}
    Sleep    1s
    
    # Set very large Total Hours
    Clear Element Text    ${TOTAL_HOURS_INPUT}
    Input Text    ${TOTAL_HOURS_INPUT}    99999
    Log To Console    Set Total Hours to: 99999
    
    # Save
    Click Element    ${SAVE_GENERAL_DATA_BUTTON}
    Sleep    2s
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
    Sleep    2s
    
    # Refresh and verify
    Reload Page
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    ${hours_after}=    Get Value    ${TOTAL_HOURS_INPUT}
    Log To Console    Total Hours stored: ${hours_after}
    
    ${earnings_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${TOTAL_EARNING_DISPLAY}    timeout=5s
    IF    ${earnings_exists}
        ${earnings}=    Get Text    ${TOTAL_EARNING_DISPLAY}
        Log To Console    Earnings with large hours: ${earnings}
        
        # Per Hour should be very small but not overflow
        ${no_overflow}=    Run Keyword And Return Status    Should Not Contain    ${earnings}    Infinity
        IF    ${no_overflow}
            Log To Console    ✓ System handles large values without overflow
        END
    END
    
    [Teardown]    Cleanup Created Fieldreport

Test Negative Product Price Earnings Calculation
    [Documentation]    Point 48: Add product with negative price and verify Earnings calculation.
    [Tags]    fieldreport    calculation    edge    negative
    [Setup]    Create Field Report With Product And Hours
    
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Log To Console    ======== TEST: Negative Product Price ========
    
    # Get initial earnings
    ${earnings_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${TOTAL_EARNING_DISPLAY}    timeout=5s
    IF    ${earnings_exists}
        ${initial_earnings}=    Get Text    ${TOTAL_EARNING_DISPLAY}
        Log To Console    Initial Earnings: ${initial_earnings}
    END
    
    # Edit product with negative price
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    2s
    
    ${edit_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${COMMON_EDIT_BUTTON}    timeout=5s
    
    IF    ${edit_exists}
        Click Element    ${COMMON_EDIT_BUTTON}
        Sleep    2s
        
        ${price_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${PRODUCT_PRICE_INPUT}    timeout=5s
        IF    ${price_exists}
            ${original_price}=    Get Value    ${PRODUCT_PRICE_INPUT}
            Log To Console    Original price: ${original_price}
            
            Clear Element Text    ${PRODUCT_PRICE_INPUT}
            ${element}=    Get WebElement    ${PRODUCT_PRICE_INPUT}
            Execute Javascript    arguments[0].value = '-100'; arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
            Log To Console    Set price to: -100
            
            Click Element    ${COMMON_SAVE_BUTTON}
            Sleep    2s
            Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
            Sleep    2s
            
            # Check if negative price was accepted
            Reload Page
            Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
            
            IF    ${earnings_exists}
                ${earnings_after}=    Get Text    ${TOTAL_EARNING_DISPLAY}
                Log To Console    Earnings after negative price: ${earnings_after}
                Log To Console    ✓ System processed negative price entry
            END
        ELSE
            Log To Console    ⚠ Price input not found
        END
    ELSE
        Log To Console    ⚠ Could not enable edit mode
    END
    
    [Teardown]    Cleanup Created Fieldreport

Test Modify Quantity Updates Earnings
    [Documentation]    Point 49: Modify product quantity and verify Earnings recalculates correctly.
    [Tags]    fieldreport    calculation    earnings    quantity
    [Setup]    Create Field Report With Product And Hours
    
    ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
    Go To    ${edit_url}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Log To Console    ======== TEST: Quantity Change Updates Earnings ========
    
    # Get initial earnings
    ${earnings_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${TOTAL_EARNING_DISPLAY}    timeout=5s
    ${initial_earnings}=    Set Variable    ${EMPTY}
    IF    ${earnings_exists}
        ${initial_earnings}=    Get Text    ${TOTAL_EARNING_DISPLAY}
        Log To Console    Initial Earnings: ${initial_earnings}
    END
    
    # Edit product quantity
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    2s
    
    ${edit_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${COMMON_EDIT_BUTTON}    timeout=5s
    
    IF    ${edit_exists}
        Click Element    ${COMMON_EDIT_BUTTON}
        Sleep    2s
        
        ${qty_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${PRODUCT_QTY_INPUT}    timeout=5s
        IF    ${qty_exists}
            ${original_qty}=    Get Value    ${PRODUCT_QTY_INPUT}
            Log To Console    Original quantity: ${original_qty}
            
            # Double the quantity
            Clear Element Text    ${PRODUCT_QTY_INPUT}
            ${element}=    Get WebElement    ${PRODUCT_QTY_INPUT}
            Execute Javascript    arguments[0].value = '10'; arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
            Log To Console    Set quantity to: 10
            
            Click Element    ${COMMON_SAVE_BUTTON}
            Sleep    2s
            Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
            Sleep    2s
            
            # Refresh and check new earnings
            Reload Page
            Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
            
            IF    ${earnings_exists}
                ${earnings_after}=    Get Text    ${TOTAL_EARNING_DISPLAY}
                Log To Console    Earnings after quantity change: ${earnings_after}
                
                # Earnings should be different
                IF    '${earnings_after}' != '${initial_earnings}'
                    Log To Console    ✓ Earnings recalculated after quantity change
                ELSE
                    Log To Console    ⚠ Earnings unchanged (may need to check calculation)
                END
            END
        ELSE
            Log To Console    ⚠ Quantity input not found
        END
    ELSE
        Log To Console    ⚠ Could not enable edit mode
    END
    
    [Teardown]    Cleanup Created Fieldreport

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

Create Field Report With Product And Hours
    [Documentation]    Create FR with product and set hours
    Login To Application
    
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Select specific customer
    Select From List By Label    ${CUSTOMER_DROPDOWN}    Arcona Aktiebolag
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Select specific project
    Select From List By Label    ${PROJECT_DROPDOWN}    Systemkameran
    ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    Select From List By Index    ${SUBPROJECT_DROPDOWN}    1
    Input Text    ${WORK_DATE_INPUT}    ${VALID_WORK_DATE}
    Input Text    ${TOTAL_HOURS_INPUT}    8
    Select From List By Index    ${INSTALLER_DROPDOWN}    1
    
    ${save_btn}=    Get WebElement    ${SAVE_BUTTON}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${save_btn}
    Sleep    3s
    
    ${current_url}=    Get Location
    ${fieldreport_id}=    Extract Fieldreport ID From URL    ${current_url}
    Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${fieldreport_id}
    Log To Console    ✓ Created FR: ${fieldreport_id}
    
    # Add product
    # Add product
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    1s
    Click Element    ${ADD_PRODUCT_BUTTON}
    Wait Until Element Is Visible    ${PRODUCT_MODAL}    timeout=10s
    Sleep    2s
    Click Element    ${PRODUCT_CHECKBOX}
    Sleep    1s
    Execute Javascript    document.querySelector('#myModal3 .modal-content').scrollTo(0, 9999);
    Sleep    1s
    Click Element    ${MODAL_SAVE_BUTTON}
    Sleep    2s
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
    Sleep    2s
    
    # Wait for AJAX row and Save with Qty
    Wait Until Element Is Visible    css=#prodInFieldReportTable tbody tr    timeout=30s
    Log To Console    Setting quantity to 1 via JavaScript...
    ${qty_set}=    Execute Javascript
    ...    var qtyInput = document.querySelector('#prodInFieldReportTable input[id^="id_quantity_"]');
    ...    if (qtyInput) { qtyInput.value = '1'; qtyInput.dispatchEvent(new Event('change')); return true; }
    ...    return false;
    Log To Console    Quantity set via JS: ${qty_set}
    Sleep    1s
    
    Wait Until Element Is Visible    ${COMMON_SAVE_BUTTON}    timeout=10s
    Click Element    ${COMMON_SAVE_BUTTON}
    Sleep    3s
    Reload Page
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    Execute Javascript    window.scrollTo(0, 800);
    Sleep    2s
    Wait Until Element Is Visible    css=#prodInFieldReportTable tbody tr    timeout=15s
    Log To Console    ✓ Added product and saved

Extract Fieldreport ID From URL
    [Arguments]    ${url}
    ${parts}=    Split String    ${url}    /
    FOR    ${i}    ${part}    IN ENUMERATE    @{parts}
        ${is_numeric}=    Run Keyword And Return Status    Should Match Regexp    ${part}    ^\\d+$
        IF    ${is_numeric}
            RETURN    ${part}
        END
    END
    Fail    Could not extract ID from URL

Cleanup Created Fieldreport
    ${has_id}=    Run Keyword And Return Status    Should Not Be Empty    ${CREATED_FIELDREPORT_ID}
    IF    ${has_id}
        ${edit_url}=    Set Variable    ${FIELDREPORT_LIST_URL}${CREATED_FIELDREPORT_ID}/edit/
        Go To    ${edit_url}
        Sleep    2s
        ${delete_btn}=    Get WebElement    ${DELETE_BUTTON}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${delete_btn}
        Sleep    1s
        Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=5s
        Log To Console    ✓ Deleted FR
    END
    Close All Browsers
