*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Invoicing App Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Invoicing Tree
    Wait Until Page Contains    Filters    timeout=20s
    Log To Console    "Invoicing app opened successfully."
    Close Browser
