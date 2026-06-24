*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Customer List Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Customers App
    Page Should Contain Element    ${CUSTOMER_SEARCH_INPUT}
    Log To Console    "Customer list opened successfully (React UI)."
    Close Browser
