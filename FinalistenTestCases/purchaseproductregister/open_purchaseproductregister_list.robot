*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Purchase Product Register List Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Purchase Product Register List
    Wait Until Page Contains    Filters    timeout=20s
    Log To Console    "Purchase product register list opened successfully."
    Close Browser
