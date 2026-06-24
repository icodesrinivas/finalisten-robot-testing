*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Guest User List Opens
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Guest User List
    Wait Until Element Is Visible    id=id_advanced_search_toggle    timeout=30s
    Log To Console    "Guest user list opened."
    Close Browser
