*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Variables ***
${LEGACY_CUSTOMER_CREATE_URL}    https://preproderp.finalisten.se/account/customers/create/

*** Test Cases ***
Verify Customer Registry Opens From Legacy Create Route
    [Documentation]    Legacy /account/customers/create/ now redirects to the React customer registry.
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Go To    ${LEGACY_CUSTOMER_CREATE_URL}
    Wait Until Location Contains    /register/customers/list    timeout=30s
    Wait For Customers List Loaded
    Verify Customer Registry Actions Visible
    Log To Console    "Legacy create route redirects to React customer registry."
    Close Browser
