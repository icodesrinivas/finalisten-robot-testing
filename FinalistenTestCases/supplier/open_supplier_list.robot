*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Supplier List Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Supplier List
    Wait Until Page Contains    Filters    timeout=20s
    Log To Console    "Supplier list opened successfully."
    Close Browser
