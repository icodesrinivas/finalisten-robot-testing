*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Project Report App Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Project Report
    Wait Until Page Contains    List Of Projects    timeout=20s
    Log To Console    "Project report app opened successfully."
    Close Browser
