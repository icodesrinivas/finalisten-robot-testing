*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Contact Create Page Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Contacts App
    Open Contact Create Dialog
    Log To Console    "Contact create dialog opened successfully (React UI)."
    Close Browser
