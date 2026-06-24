*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Field Report Create Page Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Field Report List
    Click Element    xpath=//a[contains(@href,'fieldreport/create')]
    Wait Until Page Contains    FIELD REPORT    timeout=30s
    Log To Console    "Field report create page opened successfully."
    Close Browser
