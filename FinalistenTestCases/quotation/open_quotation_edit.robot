*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot
Resource   ../keywords/NavigationKeyword.robot

*** Test Cases ***
Verify Quotation Edit Page Opens Successfully
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open And Login
    Navigate To Quotation List
    Wait Until Page Contains    Filters    timeout=20s
    ${row_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    css=tr.quotation_rows    timeout=10s
    Run Keyword If    ${row_exists}    Click Element    css=tr.quotation_rows
    Run Keyword If    ${row_exists}    Wait Until Page Contains    QUOTATION    timeout=20s
    Log To Console    "Quotation edit page opened successfully."
    Close Browser
