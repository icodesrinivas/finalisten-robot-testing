*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Edit Subcontractor Page Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Subcontractor List
    Wait Until Element Is Visible    css=tr.subcontractor_rows    timeout=20s
    Click Element    css=tr.subcontractor_rows
    Wait Until Page Contains    SUBCONTRACTOR    timeout=30s
    Log To Console    "Subcontractor edit page opened successfully."
    Close Browser
