*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Guest User Create Page Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Guest User List
    Click Element    id=id_add_subcontractor
    Wait Until Page Contains    PERSONAL DATA    timeout=30s
    Log To Console    "Guest user create page opened successfully."
    Close Browser
