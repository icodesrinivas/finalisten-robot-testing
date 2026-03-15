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
    
    Log To Console    Clicking 'ADD' button...
    # Wait for loading buffer to disappear if any
    Wait Until Keyword Succeeds    3x    2s    Wait For Loading Buffer To Disappear
    
    Wait Until Element Is Visible    ${ADD_BUTTON}    timeout=45s
    Scroll Element Into View    ${ADD_BUTTON}
    Sleep    2s
    Click Element    ${ADD_BUTTON}
    
    Log To Console    Verifying modal appearance...
    Wait Until Element Is Visible    ${MODAL}    timeout=30s
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
    Wait Until Element Is Visible    ${REGISTER_MENU}    timeout=20s
    Mouse Over    ${REGISTER_MENU}
    Sleep    2s
    Wait Until Element Is Visible    ${PURCHASE_PRODUCT_REGISTER_MENU}    timeout=15s
    Click Element    ${PURCHASE_PRODUCT_REGISTER_MENU}
    Wait Until Page Contains    Filters    timeout=20s

Open First Purchase Product Record
    [Documentation]    Opens the first available purchase product record from the list.
    ${row_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${PURCHASE_PRODUCT_REGISTER_ROW}    timeout=30s
    IF    not ${row_visible}
        Fail    No purchase product records found in register.
    END
    Click Element    ${PURCHASE_PRODUCT_REGISTER_ROW}
    Wait Until Page Contains Keywords    PURCHASE PRODUCT REGISTER    timeout=20s

Wait Until Page Contains Keywords
    [Arguments]    ${text}    ${timeout}=10s
    Wait Until Page Contains    ${text}    timeout=${timeout}

Wait For Loading Buffer To Disappear
    [Documentation]    Wait until the loading buffer overlay is no longer visible (opacity 0).
    ${buffer_exists}=    Run Keyword And Return Status    Element Should Be Visible    id=loading_buffer
    IF    ${buffer_exists}
        Wait Until Element Is Not Visible    id=loading_buffer    timeout=15s
        # Double check opacity via JS for extra reliability
        Wait Until Keyword Succeeds    5x    1s    Verify Loading Buffer Opacity Is Zero
    END

Verify Loading Buffer Opacity Is Zero
    ${opacity}=    Execute Javascript    return window.getComputedStyle(document.getElementById('loading_buffer')).getPropertyValue('opacity');
    Should Be Equal As Numbers    ${opacity}    0
