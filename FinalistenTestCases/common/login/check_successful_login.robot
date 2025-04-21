*** Settings ***
Library  SeleniumLibrary

*** Variables ***
${BROWSER}        chrome
${URL}           https://preproderp.finalisten.se/login/
${USERNAME}      erpadmin@finalisten.se
${PASSWORD}      Djangocrm123
${LOGIN_BUTTON}  xpath=//button[@type='submit' and contains(@class,'btn-primary') and contains(@class,'btn-block')]
${PRODUCTION_LINK}  xpath=//a[@class='nav-link dropdown-toggle' and @role='button' and @data-toggle='dropdown' and @id='production']
${HOMEPAGE_URL}  https://preproderp.finalisten.se/homepage/

*** Test Cases ***
Login And Verify Production Link
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Handle SSL Warning
    Input Text    xpath=//input[@name='username']    ${USERNAME}
    Input Text    xpath=//input[@name='password']    ${PASSWORD}
    Click Button    ${LOGIN_BUTTON}
    Wait Until Location Contains    ${HOMEPAGE_URL}    timeout=10s
    Wait Until Element Is Visible    ${PRODUCTION_LINK}    timeout=10s
    Log To Console    "Login successful and Production link is present."

*** Keywords ***
Handle SSL Warning
    ${advanced_button}=    Get WebElements    xpath=//button[contains(text(),'Advanced')]
    Run Keyword If    ${advanced_button}    Click Button    xpath=//button[contains(text(),'Advanced')]

    ${proceed_link}=    Get WebElements    xpath=//a[contains(text(),'Proceed')]
    Run Keyword If    ${proceed_link}    Click Element    xpath=//a[contains(text(),'Proceed')]
