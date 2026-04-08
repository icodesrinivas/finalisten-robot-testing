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
    Wait For Loading Buffer
    
    # Use Robust Click for the ADD button
    Log To Console    Clicking 'ADD' button...
    Robust Click    ${ADD_BUTTON}    timeout=60s
    
    Log To Console    Verifying modal appearance...
    Wait Until Element Is Visible    ${MODAL}    timeout=45s
    Element Should Be Visible        ${MODAL}
    
    Log To Console    Selecting a supplier...
    Wait Until Element Is Visible    ${SUPPLIER_CHECKBOX}    timeout=30s
    # JS Click for checkbox inside modal
    ${chk}=    Get WebElement    ${SUPPLIER_CHECKBOX}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${chk}
    
    Log To Console    Clicking 'Save' inside modal...
    Robust Click    ${SAVE_MODAL_BUTTON}
    
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
    # Purchase Product Register doesn't have the id_advanced_search_toggle yet.
    # It uses the "Filters" text link.
    Wait Until Page Contains  Filters    timeout=30s
    Log To Console    ✓ Navigated to Purchase Product Register. Expanding filters...
    Robust Click    xpath=//a[contains(text(),'Filters')]
    # This module uses different filter IDs. Wait for the general filter container.
    Wait Until Element Is Visible    css=.advanced_search_container, xpath=//div[contains(@class,'advanced_search_container')]    timeout=15s
    Log To Console    ✓ Filters expanded. Waiting for table to refresh...
    Wait For Loading Buffer

Open First Purchase Product Record
    [Documentation]    Opens the first available purchase product record from the list.
    ${row_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${PURCHASE_PRODUCT_REGISTER_ROW}    timeout=45s
    IF    not ${row_visible}
        Fail    No purchase product records found in register.
    END
    Robust Click    ${PURCHASE_PRODUCT_REGISTER_ROW}
    Wait Until Page Contains    PURCHASE PRODUCT REGISTER    timeout=60s

Wait Until Page Contains Keywords
    [Arguments]    ${text}    ${timeout}=30s
    Wait Until Page Contains    ${text}    timeout=${timeout}

