*** Settings ***
Resource    ../../keywords/LoginKeyword.robot

*** Test Cases ***
Verify Successful Login
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Title Should Be    Finalisten ERP - Home Page
    Log To Console    "Login successful."