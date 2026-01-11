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
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open Browser    ${URL}    ${BROWSER}    options=${CHROME_OPTIONS}
    Set Window Size    1920    1080
    Maximize Browser Window
    Set Selenium Implicit Wait    10s
    Set Selenium Timeout    45s
    Sleep    5s
    Handle SSL Warning
    # Use Presence check first as it's more robust in headless mode
    Wait Until Page Contains Element    xpath=//input[@name='username']    timeout=30s
    Input Text    xpath=//input[@name='username']    ${USERNAME}
    Wait Until Page Contains Element    xpath=//input[@name='password']    timeout=20s
    Input Text    xpath=//input[@name='password']    ${PASSWORD}
    Click Button    ${LOGIN_BUTTON}
    Wait Until Location Contains    ${HOMEPAGE_URL}    timeout=30s
    # Ensure navigation bar or sidebar is present before proceeding
    Wait Until Page Contains Element    id=register    timeout=20s
    Sleep    7s

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