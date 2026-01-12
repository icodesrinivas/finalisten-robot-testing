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
    Wait Until Page Contains    Installer Name    timeout=20s
    Log To Console    "Installer Name text found. MyProduction app opened successfully."
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Wait Until Page Contains Element    ${PRODUCTION_MENU}    timeout=20s
    Execute Javascript    var el = document.getElementById('production'); if(el) el.scrollIntoView({behavior: 'smooth', block: 'center'});
    Sleep    2s
    Wait Until Element Is Visible    ${PRODUCTION_MENU}    timeout=15s
    Mouse Over    ${PRODUCTION_MENU}
    Sleep    1s

Click On MyProduction Menu
    Wait Until Element Is Visible    ${MY_PRODUCTION_MENU}    timeout=15s
    Click Element    ${MY_PRODUCTION_MENU}
