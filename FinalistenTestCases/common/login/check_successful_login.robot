*** Settings ***
Library  SeleniumLibrary
Resource    ../../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_LINK}  xpath=//a[@class='nav-link dropdown-toggle' and @role='button' and @data-toggle='dropdown' and @id='production']

*** Test Cases ***
Login And Verify Production Link
    Open And Login
    Wait Until Element Is Visible    ${PRODUCTION_LINK}    timeout=10s
    Log To Console    "Login successful and Production link is present."