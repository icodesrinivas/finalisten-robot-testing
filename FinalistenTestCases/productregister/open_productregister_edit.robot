*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Edit Product Register Page Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Product Register List
    Wait Until Element Is Visible    css=tr.product_rows    timeout=20s
    Click Element    css=tr.product_rows
    Wait Until Page Contains    PRODUCT    timeout=30s
    Log To Console    "Product register edit page opened successfully."
    Close Browser
