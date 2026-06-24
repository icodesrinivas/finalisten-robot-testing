*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Product Register List Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Product Register List
    Wait Until Page Contains    Filters    timeout=20s
    Log To Console    "Product register list opened successfully."
    Close Browser
