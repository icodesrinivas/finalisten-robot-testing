*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_MENU}                xpath=//*[@id="production"]
${PROJECT_MENU}                   xpath=//*[@id="project_app_menu"]
${PROJECT_ROW}                    css=tr.project_rows
${PROJECT_EDIT_TEXT}             GENERAL DATA
${PROJECT_LIST_URL}               /projects/list/

*** Test Cases ***
Verify Project Edit View Opens Successfully
    Open And Login
    Hover Over Production Menu
    Click On Project Menu
    
    # Verify we are on the project list page
    Wait Until Location Contains    ${PROJECT_LIST_URL}    timeout=15s
    
    # Check for project rows
    ${row_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${PROJECT_ROW}    timeout=15s
    
    IF    ${row_exists}
        Click Project Row And Verify
    ELSE
        Fail    Failed to find project records on the project list page (${PROJECT_LIST_URL}).
    END
    
    [Teardown]    Close Browser

*** Keywords ***
Hover Over Production Menu
    Wait Until Page Contains Element    ${PRODUCTION_MENU}    timeout=20s
    Execute Javascript    var el = document.getElementById('production'); if(el) el.scrollIntoView({behavior: 'smooth', block: 'center'});
    Sleep    2s
    Wait Until Element Is Visible    ${PRODUCTION_MENU}    timeout=15s
    Click Element    ${PRODUCTION_MENU}
    Sleep    1s

Click On Project Menu
    Wait Until Element Is Visible    ${PROJECT_MENU}    timeout=15s
    # Try regular click
    Click Element    ${PROJECT_MENU}
    
    # Fallback to JS click if URL doesn't change
    ${status}=    Run Keyword And Return Status    Wait Until Location Contains    ${PROJECT_LIST_URL}    timeout=5s
    IF    not ${status}
        Log To Console    ⚠ Direct click failed to navigate, trying JavaScript click...
        Execute Javascript    document.getElementById('project_app_menu').click();
    END

Click Project Row And Verify
    ${row}=    Get WebElement    ${PROJECT_ROW}
    Execute Javascript    arguments[0].scrollIntoView({behavior: 'smooth', block: 'center'});    ARGUMENTS    ${row}
    Sleep    1s
    Double Click Element    ${PROJECT_ROW}
    Wait Until Page Contains    ${PROJECT_EDIT_TEXT}    timeout=20s
    Log To Console    "GENERAL DATA text found. Project Edit view opened successfully."
