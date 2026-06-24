*** Settings ***
Library  SeleniumLibrary
Resource    ../../keywords/LoginKeyword.robot
Resource    ../../keywords/NavigationKeyword.robot

*** Test Cases ***
Login And Verify Production Link
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Wait For Erp Shell Ready
    Page Should Contain Element    css=header button[aria-label*="sidopanel"]
    Log To Console    "Login successful and React ERP shell sidebar is present."
    Close Browser
