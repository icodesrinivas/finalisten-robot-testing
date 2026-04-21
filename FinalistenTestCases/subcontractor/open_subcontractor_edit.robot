*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}               id=register
${SUBCONTRACTOR_MENU}          id=subcontractor_app_menu
${SUBCONTRACTOR_ROW}           css=tr.subcontractor_rows
${SUBCONTRACTOR_HEADER}        id=subcontractor-header-name-display

*** Test Cases ***
Verify Subcontractor Edit Page Opens Successfully
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
    Wait Until Element Is Visible    ${SUBCONTRACTOR_ROW}    timeout=30s
    ${row_el}=    Get WebElement    ${SUBCONTRACTOR_ROW}
    Execute Javascript    arguments[0].scrollIntoView({block: "center", behavior: "instant"});    ARGUMENTS    ${row_el}
    Sleep    1s
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${row_el}
    Wait Until Element Is Visible    ${SUBCONTRACTOR_HEADER}    timeout=30s
    Page Should Contain    SUBCONTRACTOR
    Log To Console    "Subcontractor edit page opened (header and SUBCONTRACTOR content verified)."
    Close Browser
