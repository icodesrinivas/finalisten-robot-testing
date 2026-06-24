*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Subcontractor List Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Subcontractor List
    Wait Until Page Contains    Filters    timeout=20s
    Log To Console    "Subcontractor list opened successfully."
    Close Browser
