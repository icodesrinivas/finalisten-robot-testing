*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Field Report List View Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Field Report List
    Wait Until Page Contains    Filters    timeout=20s
    Log To Console    "Field report list view opened successfully."
    Close Browser
