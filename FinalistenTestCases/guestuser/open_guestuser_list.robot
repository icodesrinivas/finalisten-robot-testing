*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}               id=register
${GUEST_USER_MENU}             xpath=//a[@id='guestuser_app_menu' or contains(@href,'guestuser')]
${ADVANCED_SEARCH_TOGGLE}      id=id_advanced_search_toggle

*** Test Cases ***
Verify Guest User List Opens Successfully
    Open And Login
    Wait Until Page Contains Element    ${REGISTER_MENU}    timeout=45s
    Sleep    2s
    ${reg_el}=    Get WebElement    ${REGISTER_MENU}
    Execute Javascript    arguments[0].scrollIntoView({block: "center", behavior: "instant"});    ARGUMENTS    ${reg_el}
    Sleep    1s
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${reg_el}
    Sleep    1s
    Wait Until Page Contains Element    ${GUEST_USER_MENU}    timeout=30s
    ${guest_el}=    Get WebElement    ${GUEST_USER_MENU}
    Execute Javascript    arguments[0].scrollIntoView({block: "center", behavior: "instant"});    ARGUMENTS    ${guest_el}
    Sleep    1s
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${guest_el}
    Sleep    3s
    Wait Until Element Is Visible    ${ADVANCED_SEARCH_TOGGLE}    timeout=30s
    Element Should Contain    ${ADVANCED_SEARCH_TOGGLE}    Advanced search
    Log To Console    "Advanced search found. Guest user list opened successfully."
    Close Browser
