*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Supplier Edit Page Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Supplier List
    Wait Until Element Is Visible    css=tr.supplier_rows    timeout=20s
    Click Element    css=tr.supplier_rows
    Wait Until Page Contains    SUPPLIER    timeout=30s
    Log To Console    "Supplier edit page opened successfully."
    Close Browser
