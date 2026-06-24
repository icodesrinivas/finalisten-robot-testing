*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Invoice List View Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Invoice List
    Wait Until Page Contains    Filters    timeout=20s
    Log To Console    "Invoice list view opened successfully."
    Close Browser
