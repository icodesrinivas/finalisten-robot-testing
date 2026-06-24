*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Settings App Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Old Settings App
    Wait Until Page Contains    Settings    timeout=20s
    Wait Until Page Contains    Fieldreport    timeout=20s
    Log To Console    "Settings app opened successfully."
    Close Browser
