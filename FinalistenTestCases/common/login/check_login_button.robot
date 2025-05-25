*** Settings ***
Library  SeleniumLibrary

*** Variables ***
${BROWSER}        chrome
${URL}           https://erp.finalisten.se/login/
${LOGIN_BUTTON}   xpath=//button[@type='submit' and contains(@class,'btn-primary') and contains(@class,'btn-block')]

*** Test Cases ***
Verify Login Button Exists
    Open Browser With Options
    Go To    ${URL}
    Handle SSL Warning
    Page Should Contain Element    ${LOGIN_BUTTON}    timeout=5s
    Log To Console    "Login button is present."

*** Keywords ***
Open Browser With Options
    ${chrome_options}=    Evaluate    sys.modules['selenium.webdriver'].ChromeOptions()    sys, selenium.webdriver
    Call Method    ${chrome_options}    add_argument    --ignore-certificate-errors
    Call Method    ${chrome_options}    add_argument    --user-data-dir=/path/to/unique/directory
    Create Webdriver    Chrome    options=${chrome_options}

Handle SSL Warning
    ${advanced_button}=    Get WebElements    xpath=//button[contains(text(),'Advanced')]
    Run Keyword If    ${advanced_button}    Click Button    xpath=//button[contains(text(),'Advanced')]

    ${proceed_link}=    Get WebElements    xpath=//a[contains(text(),'Proceed')]
    Run Keyword If    ${proceed_link}    Click Element    xpath=//a[contains(text(),'Proceed')]
