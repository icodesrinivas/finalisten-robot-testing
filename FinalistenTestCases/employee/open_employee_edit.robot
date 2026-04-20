*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}      xpath=//*[@id="register"]
${EMPLOYEES_MENU}     xpath=//*[@id="employee_app_menu"]
${EMPLOYEE_ROW}       css=tr.employee_rows
${PERSONAL_DATA_TAB}  xpath=//a[contains(@class,'nav-link') and contains(@href,'#tab_personal_data') and contains(.,'PERSONAL DATA')]

*** Test Cases ***
Verify Employee Edit Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Employees Menu
    Wait Until Element Is Visible    ${EMPLOYEE_ROW}    timeout=10s
    Click Element    ${EMPLOYEE_ROW}
    Wait Until Element Is Visible    ${PERSONAL_DATA_TAB}    timeout=30s
    Log To Console    "PERSONAL DATA found. Employee edit page opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Wait Until Element Is Visible    ${REGISTER_MENU}    timeout=30s
    Sleep    1s
    Mouse Over    ${REGISTER_MENU}

Click On Employees Menu
    Wait Until Page Contains Element    ${EMPLOYEES_MENU}    timeout=30s
    ${emp_menu_el}=    Get WebElement    ${EMPLOYEES_MENU}
    Execute Javascript    arguments[0].scrollIntoView({block: "center", behavior: "instant"});    ARGUMENTS    ${emp_menu_el}
    Sleep    1s
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${emp_menu_el}
    Sleep    2s
