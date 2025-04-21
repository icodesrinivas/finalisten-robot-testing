*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_MENU}             xpath=//*[@id="production"]
${MY_PRODUCTION_MENU}          xpath=//*[@id="my_production_app_menu"]

*** Test Cases ***
Verify MyProduction App Opens Successfully
    Open And Login
    Hover Over Production Menu
    Click On MyProduction Menu
    Wait Until Page Contains    Installer Name    timeout=10s
    Log To Console    "Installer Name text found. MyProduction app opened successfully."
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Mouse Over    ${PRODUCTION_MENU}

Click On MyProduction Menu
    Click Element    ${MY_PRODUCTION_MENU}

