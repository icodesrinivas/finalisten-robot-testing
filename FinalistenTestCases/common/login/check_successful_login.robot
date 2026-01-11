*** Settings ***
Library  SeleniumLibrary
Resource    ../../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_LINK}  id=production

*** Test Cases ***
Login And Verify Production Link
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Sleep    5s
    # Use Presence check (id=production) which is more robust than visibility in headless
    Wait Until Page Contains Element    ${PRODUCTION_LINK}    timeout=45s
    Log To Console    "Login successful and Production link is present."
    Close Browser