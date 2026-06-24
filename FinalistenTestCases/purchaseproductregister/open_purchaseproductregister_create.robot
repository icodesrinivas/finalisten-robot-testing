*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Purchase Product Register Create Page Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Purchase Product Register List
    Click Element    xpath=//a[contains(@href,'purchase_product_new')]
    Wait Until Page Contains    PURCHASE PRODUCT    timeout=30s
    Log To Console    "Purchase product register create page opened successfully."
    Close Browser
