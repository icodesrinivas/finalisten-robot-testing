*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Product Register Create Page Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Product Register List
    Click Element    xpath=//a[contains(@href,'product_new')]
    Wait Until Page Contains    PRODUCT    timeout=30s
    Log To Console    "Product register create page opened successfully."
    Close Browser
