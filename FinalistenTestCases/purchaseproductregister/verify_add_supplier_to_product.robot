*** Settings ***
Library    SeleniumLibrary
Library    Collections
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}                                      xpath=//*[@id="register"]
${PURCHASE_PRODUCT_REGISTER_MENU}                    xpath=//*[@id="purchase_product_register_app_menu"]
${PURCHASE_PRODUCT_REGISTER_ROW}                     css=tr.purchase_product_rows
${ADD_BUTTON}                                        id=supplier_add_button
${MODAL}                                             id=myModal3
${SUPPLIER_CHECKBOX}                                 css=input.supplier_in_product_checkbox
${SAVE_MODAL_BUTTON}                                 id=supplier_in_product_save_button
${CLOSE_MODAL_BUTTON}                                xpath=//div[@id='myModal3']//button[contains(text(), 'Cancel')]

*** Test Cases ***
Verify ADD Button Opens Modal And Allows Selecting Supplier
    [Documentation]    Verifies that the ADD button in the Supplier Purchase Price Table 
    ...               opens the supplier modal and allows selecting a supplier.
    [Tags]            purchase_product    modal    supplier
    
    Open And Login
    Navigate To Purchase Product Register
    Open First Purchase Product Record
    
    Log To Console    Waiting for 'ADD' button area to stabilize...
    # Ensure any initial loading buffer is gone
    Wait For Loading Buffer To Disappear
    
    # 1. Wait for Presence first (in DOM)
    Wait Until Page Contains Element    ${ADD_BUTTON}    timeout=60s
    Log To Console    ✓ 'ADD' button present in DOM.
    
    # 2. Force Scroll with JS for headless reliability
    ${btn}=    Get WebElement    ${ADD_BUTTON}
    Execute Javascript    arguments[0].scrollIntoView({behavior: 'smooth', block: 'center'});    ARGUMENTS    ${btn}
    Sleep    3s    # Give time for any scroll-triggered AJAX or layout shifts
    
    # 3. Wait for Visibility (interactability) with retry loop
    Wait Until Keyword Succeeds    10x    2s    Verify Element Is Truly Visible    ${ADD_BUTTON}
    Log To Console    ✓ 'ADD' button is now visible and interactable.
    
    # 4. Click using JS for maximum robustness in CI
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${btn}
    
    Log To Console    Verifying modal appearance...
    Wait Until Element Is Visible    ${MODAL}    timeout=45s
    Element Should Be Visible        ${MODAL}
    
    Log To Console    Selecting a supplier...
    Wait Until Element Is Visible    ${SUPPLIER_CHECKBOX}    timeout=30s
    # Toggle the first checkbox
    Click Element    ${SUPPLIER_CHECKBOX}
    
    Log To Console    Clicking 'Save' inside modal...
    Click Element    ${SAVE_MODAL_BUTTON}
    
    Log To Console    Verifying modal closure...
    Wait Until Element Is Not Visible    ${MODAL}    timeout=30s
    
    Log To Console    Success: ADD button and modal functionality verified.
    
    [Teardown]    Close Browser

*** Keywords ***
Navigate To Purchase Product Register
    [Documentation]    Navigates to the Purchase Product Register via the Register menu.
    Wait Until Element Is Visible    ${REGISTER_MENU}    timeout=30s
    Mouse Over    ${REGISTER_MENU}
    Sleep    2s
    Wait Until Element Is Visible    ${PURCHASE_PRODUCT_REGISTER_MENU}    timeout=20s
    Click Element    ${PURCHASE_PRODUCT_REGISTER_MENU}
    Wait Until Page Contains Element    id=id_advanced_search_toggle    timeout=30s

Open First Purchase Product Record
    [Documentation]    Opens the first available purchase product record from the list.
    ${row_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${PURCHASE_PRODUCT_REGISTER_ROW}    timeout=45s
    IF    not ${row_visible}
        Fail    No purchase product records found in register.
    END
    Click Element    ${PURCHASE_PRODUCT_REGISTER_ROW}
    Wait Until Page Contains Keywords    PURCHASE PRODUCT REGISTER    timeout=45s

Wait Until Page Contains Keywords
    [Arguments]    ${text}    ${timeout}=30s
    Wait Until Page Contains    ${text}    timeout=${timeout}

Wait For Loading Buffer To Disappear
    [Documentation]    Wait until the loading buffer overlay is no longer visible (opacity 0).
    Wait Until Keyword Succeeds    60x    1s    Verify Loading Buffer Is Hidden

Verify Loading Buffer Is Hidden
    ${present}=    Run Keyword And Return Status    Page Should Contain Element    id=loading_buffer
    IF    not ${present}    RETURN
    ${opacity}=    Execute Javascript    return window.getComputedStyle(document.getElementById('loading_buffer')).getPropertyValue('opacity');
    Should Be Equal As Numbers    ${opacity}    0    msg=Loading buffer still visible (opacity ${opacity})

Verify Element Is Truly Visible
    [Arguments]    ${locator}
    Element Should Be Visible    ${locator}
    # Ensure it's not obscured by the loading buffer even if displayed
    Verify Loading Buffer Is Hidden
