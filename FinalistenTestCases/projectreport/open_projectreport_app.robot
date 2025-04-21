*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${REPORTS_MENU}                  xpath=//*[@id="reports"]
${PROJECT_REPORT_MENU}          xpath=//*[@id="project_report_app_menu"]
${PROJECT_REPORT_TEXT}          List Of Projects

*** Test Cases ***
Verify Project Report App Opens Successfully
    Open And Login
    Hover Over Reports Menu
    Click On Project Report Menu
    Wait Until Page Contains    ${PROJECT_REPORT_TEXT}    timeout=10s
    Log To Console    "List Of Projects found. Project Report App opened successfully."
    Close Browser

*** Keywords ***
Hover Over Reports Menu
    Mouse Over    ${REPORTS_MENU}

Click On Project Report Menu
    Click Element    ${PROJECT_REPORT_MENU}
