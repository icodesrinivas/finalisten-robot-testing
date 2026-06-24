*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Performance Report App Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Performance Report
    Wait Until Page Contains    Filters    timeout=20s
    Log To Console    "Performance report app opened successfully."
    Close Browser
