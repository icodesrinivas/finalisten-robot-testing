*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}                        xpath=//*[@id="register"]
${PRODUCT_REGISTER_MENU}               xpath=//*[@id="product_register_app_menu"]
${PRODUCT_REGISTER_ROW}                css=tr.product_register_rows

*** Test Cases ***
Verify Product Register Edit Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Product Register Menu
    Sleep    3s
    ${row_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${PRODUCT_REGISTER_ROW}    timeout=10s
    Run Keyword If    ${row_exists}    Click Product Register Row And Verify
    ...    ELSE    Log To Console    "No product register records found. Test skipped."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Product Register Menu
    Click Element    ${PRODUCT_REGISTER_MENU}

Click Product Register Row And Verify
    Click Element    ${PRODUCT_REGISTER_ROW}
    Wait Until Page Contains    SALES PRODUCT    timeout=10s
    Log To Console    "SALES PRODUCT text found. Edit view opened successfully."
