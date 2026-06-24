*** Settings ***
Documentation    Update the Field Report allowed date range in Settings.
Library          SeleniumLibrary
Resource         ../keywords/LoginKeyword.robot
Resource         ../keywords/NavigationKeyword.robot

*** Variables ***
${NEW_START_DATE}    2024-01-01
${NEW_END_DATE}      2030-12-31
${SAVE_BUTTON}       id=global_setting_data_save

*** Test Cases ***
Update Field Report Date Range
    [Documentation]    Updates the allowed reporting period to 2024-2030.
    Open And Login
    Navigate To Old Settings App
    Log To Console    Expanding Fieldreport settings via JS...
    Execute Javascript    var leaf = document.evaluate("//a[contains(text(),'Reporting Date Range')]", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue; if(leaf) { leaf.parentNode.style.display = 'block'; leaf.parentNode.parentNode.style.display = 'block'; leaf.parentNode.parentNode.parentNode.style.display = 'block'; }
    Wait Until Element Is Visible    id=id_global_setting    timeout=15s
    Click Element    id=id_global_setting
    Wait Until Element Is Visible    id=id_work_date_start    timeout=15s
    Input Text    id=id_work_date_start    ${NEW_START_DATE}
    Execute Javascript    document.getElementById('id_work_date_start').dispatchEvent(new Event('change'));
    Input Text    id=id_work_date_end    ${NEW_END_DATE}
    Execute Javascript    document.getElementById('id_work_date_end').dispatchEvent(new Event('change'));
    Click Button    ${SAVE_BUTTON}
    Wait Until Keyword Succeeds    10x    1s    Work Date Start Persisted
    Log To Console    Date range updated successfully.
    [Teardown]    Close Browser

*** Keywords ***
Work Date Start Persisted
    ${value}=    Get Value    id=id_work_date_start
    Should Be Equal    ${value}    ${NEW_START_DATE}
