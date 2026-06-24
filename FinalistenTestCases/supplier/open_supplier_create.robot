*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Supplier Create Page Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Supplier List
    Click Element    id=id_add_supplier
    Wait Until Page Contains    SUPPLIER    timeout=30s
    Log To Console    "Supplier create page opened successfully."
    Close Browser
