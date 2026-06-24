*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Quotation Create Page Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Quotation List
    Click Element    id=id_add_quotation
    Wait Until Page Contains    QUOTATION    timeout=30s
    Log To Console    "Quotation create page opened successfully."
    Close Browser
