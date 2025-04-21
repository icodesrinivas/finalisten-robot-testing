*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REGISTER_MENU}      xpath=//*[@id="register"]
${EMPLOYEES_MENU}     xpath=//*[@id="employee_app_menu"]
${EDIT_EMPLOYEE_BTN}   xpath=//a[contains(@href, '/employees/employee/list/') and contains(@href, '/edit/')]

*** Test Cases ***
Verify Employee Edit Page Opens Successfully
    Open And Login
    Hover Over Register Menu
    Click On Employees Menu
    Wait Until Page Contains    Filters    timeout=10s
    Click On Edit Employee Button
    Wait Until Page Contains    PERSONAL DATA    timeout=10s
    Log To Console    "PERSONAL DATA found. Employee edit page opened successfully."
    Close Browser

*** Keywords ***
Hover Over Register Menu
    Mouse Over    ${REGISTER_MENU}

Click On Employees Menu
    Click Element    ${EMPLOYEES_MENU}

Click On Edit Employee Button
    # Click on any available employee edit button in the list (first available)
    Click Element    ${EDIT_EMPLOYEE_BTN}
