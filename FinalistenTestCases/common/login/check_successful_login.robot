*** Settings ***
Library  SeleniumLibrary
Resource    ../../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_LINK}  id=production

*** Test Cases ***
Login And Verify Production Link
    Open And Login
    Sleep    3s
    # Wait for any menu to be visible first
    Wait Until Element Is Visible    xpath=//*[@id="navbarSupportedContent"]    timeout=15s
    # Then check for Production menu
    Wait Until Element Is Visible    ${PRODUCTION_LINK}    timeout=30s
    Log To Console    "Login successful and Production link is present."
    Close Browser