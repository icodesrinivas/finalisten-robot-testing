*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Invoice Report App Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Invoice Report
    Wait Until Page Contains    Filters    timeout=20s
    Log To Console    "Invoice report app opened successfully."
    Close Browser
