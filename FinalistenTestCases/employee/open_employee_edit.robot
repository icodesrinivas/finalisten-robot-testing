*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Edit Employee Page Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Employee List
    Wait Until Element Is Visible    css=tr.employee_rows    timeout=20s
    Click Element    css=tr.employee_rows
    Wait Until Page Contains    PERSONAL DATA    timeout=30s
    Log To Console    "Employee edit page opened successfully."
    Close Browser
