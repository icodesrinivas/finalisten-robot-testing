*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Employee Create Page Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Employee List
    Click Element    id=id_add_employee
    Wait Until Page Contains    Personal Data    timeout=30s
    Log To Console    "Employee create page opened successfully."
    Close Browser
