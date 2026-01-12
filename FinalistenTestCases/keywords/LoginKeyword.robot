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
${CHROME_OPTIONS}    add_argument("--ignore-certificate-errors");add_argument("--disable-web-security");add_argument("--allow-running-insecure-content");add_argument("--window-size=1920,1080");add_argument("--no-sandbox");add_argument("--disable-dev-shm-usage")

*** Keywords ***
Open And Login
    Register Keyword To Run On Failure    Capture Page Screenshot
    Open Browser    ${URL}    ${BROWSER}    options=${CHROME_OPTIONS}
    Set Window Size    1920    1080
    Maximize Browser Window
    Set Selenium Implicit Wait    15s
    Set Selenium Timeout    60s
    Sleep    5s
    Handle SSL Warning
    
    # Wait for page to fully load
    Execute Javascript    return document.readyState === 'complete'
    Sleep    3s
    
    # Use Presence check first as it's more robust in headless mode
    Wait Until Page Contains Element    xpath=//input[@name='username']    timeout=30s
    Input Text    xpath=//input[@name='username']    ${USERNAME}
    Wait Until Page Contains Element    xpath=//input[@name='password']    timeout=20s
    Input Text    xpath=//input[@name='password']    ${PASSWORD}
    Click Button    ${LOGIN_BUTTON}
    Wait Until Location Contains    ${HOMEPAGE_URL}    timeout=30s
    
    # Wait for page to fully load after login
    Sleep    8s
    Execute Javascript    return document.readyState === 'complete'
    Execute Javascript    window.scrollTo(0, 0);
    Sleep    2s
    
    # MOBILE/HEADLESS FALLBACK: Try multiple approaches to ensure menu is accessible
    ${is_visible}=    Run Keyword And Return Status    Element Should Be Visible    id=register
    IF    not ${is_visible}
        Log To Console    Register menu not visible, trying fallback approaches...
        # Try clicking navbar toggler for mobile view
        ${toggler_exists}=    Run Keyword And Return Status    Page Should Contain Element    css=.navbar-toggler
        IF    ${toggler_exists}
            ${toggler_visible}=    Run Keyword And Return Status    Element Should Be Visible    css=.navbar-toggler
            IF    ${toggler_visible}
                Click Element    css=.navbar-toggler
                Sleep    3s
            END
        END
        # Try scrolling to make element visible
        Execute Javascript    var el = document.getElementById('register'); if(el) el.scrollIntoView({behavior: 'smooth', block: 'center'});
        Sleep    2s
    END
    
    # Final wait for navigation element with longer timeout
    Wait Until Page Contains Element    id=register    timeout=30s
    Sleep    3s

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