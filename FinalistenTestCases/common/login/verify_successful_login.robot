*** Settings ***
Library     SeleniumLibrary
Resource    ../../keywords/LoginKeyword.robot
Resource    ../../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Successful Login
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Wait For Erp Shell Ready
    Page Should Contain Element    css=header button[aria-label*="sidopanel"]
    Log To Console    "Login successful."
