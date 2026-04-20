*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}       xpath=//*[@id="register"]
${EMPLOYEES_MENU}      xpath=//*[@id="employee_app_menu"]
${ADD_EMPLOYEE_BTN}     xpath=//a[@href="/employees/employee/create/" and @title="Add New Employee"]

*** Test Cases ***
Verify Employee Create Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Employees Menu
    Wait Until Element Is Visible    ${ADD_EMPLOYEE_BTN}    timeout=30s
    Click On Add Employee Button
    Wait Until Element Is Visible    id=employee-header-name-display    timeout=30s
    ${header_text}=    Get Text    id=employee-header-name-display
    Should Be Equal As Strings    ${header_text}    New Employee    ignore_case=True
    Log To Console    "New Employee header found. Employee create page opened successfully."
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

Click On Add Employee Button
    Click Element    ${ADD_EMPLOYEE_BTN}
