*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Resource Planning Board Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Resource Planning Board
    Wait Until Page Contains    Sales Week    timeout=30s
    Log To Console    "Resource planning board opened successfully."
    Close Browser
