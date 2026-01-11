*** Settings ***
Library    SeleniumLibrary
Library    OperatingSystem
Library    OperatingSystem

*** Variables ***
${BROWSER}        chrome
${URL}           https://preproderp.finalisten.se/login/
${USERNAME}      erpadmin@finalisten.se
${PASSWORD}      Djangocrm123
${LOGIN_BUTTON}  xpath=//button[@type='submit' and contains(@class,'btn-primary') and contains(@class,'btn-block')]
${HOMEPAGE_URL}  https://preproderp.finalisten.se/homepage/
${CHROME_OPTIONS}    add_argument("--ignore-certificate-errors");add_argument("--disable-web-security");add_argument("--allow-running-insecure-content")

*** Keywords ***
Open And Login
    Open Browser    ${URL}    ${BROWSER}    options=${CHROME_OPTIONS}
    Maximize Browser Window
    Set Selenium Implicit Wait    10s
    Set Selenium Timeout    30s
    Sleep    2s
    Wait Until Page Contains Element    xpath=//input[@name='username']    timeout=15s
    Handle SSL Warning
    Wait Until Element Is Visible    xpath=//input[@name='username']    timeout=10s
    Input Text    xpath=//input[@name='username']    ${USERNAME}
    Wait Until Element Is Visible    xpath=//input[@name='password']    timeout=10s
    Input Text    xpath=//input[@name='password']    ${PASSWORD}
    Click Button    ${LOGIN_BUTTON}
    Wait Until Location Contains    ${HOMEPAGE_URL}    timeout=15s
    Sleep    5s

Handle SSL Warning
    ${advanced_button}=    Get WebElements    xpath=//button[contains(text(),'Advanced')]
    Run Keyword If    ${advanced_button}    Click Button    xpath=//button[contains(text(),'Advanced')]

    ${proceed_link}=    Get WebElements    xpath=//a[contains(text(),'Proceed')]
    Run Keyword If    ${proceed_link}    Click Element    xpath=//a[contains(text(),'Proceed')]

Close Browser
    ${browsers}=    SeleniumLibrary.Get Browser Ids
    IF    ${browsers}
        SeleniumLibrary.Close All Browsers
    END