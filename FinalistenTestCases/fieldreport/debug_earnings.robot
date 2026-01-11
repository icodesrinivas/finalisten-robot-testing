*** Settings ***
Documentation    Debug test to dump sources.
Library          SeleniumLibrary
Library          OperatingSystem

*** Variables ***
${BASE_URL}                       https://preproderp.finalisten.se
${LOGIN_URL}                      ${BASE_URL}/login/
${FIELDREPORT_CREATE_URL}         ${BASE_URL}/fieldreport/create/
${USERNAME}                       erpadmin@finalisten.se
${PASSWORD}                       Djangocrm123
${BROWSER}                        headlesschrome
${CHROME_OPTIONS}                 add_argument("--disable-search-engine-choice-screen"); add_argument("--disable-popup-blocking"); add_argument("--ignore-certificate-errors"); add_argument("--disable-extensions"); add_argument("--no-sandbox"); add_argument("--disable-dev-shm-usage"); add_argument("--window-size=1920,1080")

*** Test Cases ***
Debug Field Report Creation And Products
    [Documentation]    Dump sources to debug earnings calculation failure.
    Open Browser    ${LOGIN_URL}    ${BROWSER}    options=${CHROME_OPTIONS}
    Wait Until Page Contains Element    xpath=//input[@name='username']    timeout=10s
    Input Text    xpath=//input[@name='username']    ${USERNAME}
    Input Text    xpath=//input[@name='password']    ${PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Contains    ${BASE_URL}/homepage/    timeout=15s
    
    Go To    ${FIELDREPORT_CREATE_URL}
    
    # Fill basic details
    Wait Until Element Is Visible    id=id_related_customer    timeout=15s
    Select From List By Index    id=id_related_customer    1
    ${element}=    Get WebElement    id=id_related_customer
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    Select From List By Index    id=id_related_project    1
    ${element}=    Get WebElement    id=id_related_project
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    Select From List By Index    id=id_related_subproject    1
    Input Text    id=id_work_date    2025-10-20
    Input Text    id=id_total_work_hours    8
    Select From List By Index    id=id_installer_name    1
    
    # Save (create FR)
    Click Element    css=button.save
    Sleep    3s
    
    # Dump Edit Page Source
    ${src}=    Get Source
    Create File    ${OUTPUT DIR}/debug_edit_page.html    ${src}
    
    # Open Modal
    Execute Javascript    window.scrollTo(0, 800);
    Click Element    xpath=//span[text()='ADD']
    Wait Until Element Is Visible    id=myModal3    timeout=10s
    Sleep    3s
    ${modal_src}=    Get Source
    Create File    ${OUTPUT DIR}/debug_modal.html    ${modal_src}
    
    # Select product
    Click Element    css=#prodInProjTable tbody tr:first-child .selected-checkbox
    Click Element    css=.prodinfr_save_button
    Sleep    2s
    Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
    
    # Dump source after adding product
    ${after_add_src}=    Get Source
    Create File    ${OUTPUT DIR}/debug_edit_page_with_product.html    ${after_add_src}
    
    Close All Browsers
