*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Subcontractor Create Page Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Subcontractor List
    Click Element    id=id_add_subcontractor
    Wait Until Page Contains    SUBCONTRACTOR    timeout=30s
    Log To Console    "Subcontractor create page opened successfully."
    Close Browser
