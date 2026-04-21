*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}             id=register
${SUBCONTRACTOR_MENU}        id=subcontractor_app_menu
${ADD_SUBCONTRACTOR_BUTTON}  id=id_add_subcontractor
${SUBCONTRACTOR_HEADER}      id=subcontractor-header-name-display

*** Test Cases ***
Verify Subcontractor Create Page Opens Successfully
    Open And Login
    Wait Until Page Contains Element    ${REGISTER_MENU}    timeout=45s
    Sleep    2s
    ${reg_el}=    Get WebElement    ${REGISTER_MENU}
    Execute Javascript    arguments[0].scrollIntoView({block: "center", behavior: "instant"});    ARGUMENTS    ${reg_el}
    Sleep    1s
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${reg_el}
    Sleep    1s
    Wait Until Page Contains Element    ${SUBCONTRACTOR_MENU}    timeout=30s
    ${menu_el}=    Get WebElement    ${SUBCONTRACTOR_MENU}
    Execute Javascript    arguments[0].scrollIntoView({block: "center", behavior: "instant"});    ARGUMENTS    ${menu_el}
    Sleep    1s
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${menu_el}
    Sleep    3s
    Wait Until Page Contains Element    id=id_advanced_search_toggle    timeout=30s
    ${add_el}=    Get WebElement    ${ADD_SUBCONTRACTOR_BUTTON}
    Execute Javascript    arguments[0].scrollIntoView({block: "center", behavior: "instant"});    ARGUMENTS    ${add_el}
    Sleep    1s
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${add_el}
    Wait Until Element Is Visible    ${SUBCONTRACTOR_HEADER}    timeout=30s
    ${hdr}=    Get Text    ${SUBCONTRACTOR_HEADER}
    Should Contain    ${hdr}    SUBCONTRACTOR    msg=Expected subcontractor create header
    Log To Console    "Subcontractor create page opened (header verified)."
    Close Browser
