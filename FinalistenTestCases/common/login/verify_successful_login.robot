*** Settings ***
Resource    ../../keywords/LoginKeyword.robot

*** Test Cases ***
Verify Successful Login
    Open And Login
    Title Should Be    Finalisten ERP - Home Page
    Log To Console    "Login successful."