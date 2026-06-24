*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify My Production App Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To My Production
    Wait Until Page Contains    Filters    timeout=20s
    Log To Console    "My production app opened successfully."
    Close Browser
