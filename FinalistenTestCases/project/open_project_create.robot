*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Project Create Page Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Project List
    Click Element    xpath=//a[contains(@href,'project_new')]
    Wait Until Page Contains    GENERAL DATA    timeout=30s
    Log To Console    "Project create page opened successfully."
    Close Browser
