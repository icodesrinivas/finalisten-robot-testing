*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
*** Variables ***
${REGISTER_MENU}      id=register
${EMPLOYEES_MENU}     id=employee_app_menu
${ADVANCED_SEARCH_TOGGLE}    id=id_advanced_search_toggle

*** Test Cases ***
Verify Employee List Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    # Wait for Presence (id=register) which is more robust in headless
    Wait Until Page Contains Element    ${REGISTER_MENU}    timeout=45s
    Sleep    3s
    # Scroll to ensure element is in viewport
    Execute Javascript    var el = document.getElementById('register'); if(el) el.scrollIntoView({behavior: 'smooth', block: 'center'});
    Sleep    2s
    Wait Until Element Is Visible    ${REGISTER_MENU}    timeout=15s
    Click Element    ${REGISTER_MENU}
    # Wait for Presence (submenu)
    Wait Until Page Contains Element    ${EMPLOYEES_MENU}    timeout=20s
    Sleep    2s
    Click Element    ${EMPLOYEES_MENU}
    Sleep    3s
    Wait Until Element Is Visible    ${ADVANCED_SEARCH_TOGGLE}    timeout=30s
    Element Should Contain    ${ADVANCED_SEARCH_TOGGLE}    Advanced search
    Log To Console    "Advanced search found. Employee list opened successfully."
    Close Browser
