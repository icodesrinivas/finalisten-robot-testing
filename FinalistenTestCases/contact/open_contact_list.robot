*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Contact List Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Contacts App
    Page Should Contain Element    ${CONTACT_SEARCH_INPUT}
    Log To Console    "Contact list opened successfully (React UI)."
    Close Browser
