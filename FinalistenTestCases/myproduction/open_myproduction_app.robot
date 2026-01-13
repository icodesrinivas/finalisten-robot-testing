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
    # The MyProduction page shows a tree menu with installers - wait for that to load
    # "Installer Name" text only appears after clicking the pencil icon next to an installer
    Wait Until Page Contains Element    xpath=//a[contains(@href, 'fieldreport_approval_installer')]    timeout=20s
    Sleep    3s
    Page Should Contain Element    xpath=//*[contains(@class, 'tree') or contains(@id, 'tree')]
    Log To Console    "MyProduction app page loaded successfully."
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
