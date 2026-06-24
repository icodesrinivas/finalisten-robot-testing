*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Edit Purchase Product Register Page Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Purchase Product Register List
    Wait Until Element Is Visible    css=tr.purchase_product_rows    timeout=20s
    Click Element    css=tr.purchase_product_rows
    Wait Until Page Contains    PURCHASE PRODUCT    timeout=30s
    Log To Console    "Purchase product register edit page opened successfully."
    Close Browser
