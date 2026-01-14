*** Settings ***
Library    SeleniumLibrary
Library    DateTime
Library    String
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_MENU}           xpath=//*[@id="production"]
${FIELD_REPORT_MENU}         xpath=//*[@id="field_reports_app_menu"]
${FILTER_FRAME_HEADER}       id=fieldreport_list_filter
${START_WORK_DATE_INPUT}     xpath=//input[@name='start_work_date']
${SEARCH_BUTTON_XPATH}       xpath=//*[@id='fieldreport_list_search']
${FIELD_REPORT_ROW}          css=.fieldreport_rows
${FIELD_REPORT_LINK}         xpath=//tr[contains(@class, 'fieldreport_rows')]//a[contains(@href, '/edit/')]

*** Test Cases ***
Verify Field Report Edit Page Opens Successfully
    Open And Login
    Hover Over Production Menu
    Click On Field Report Menu
    Open Field Report Edit Page
    Switch To New Tab And Verify Field Report Text
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Wait Until Page Contains Element    ${PRODUCTION_MENU}    timeout=20s
    Execute Javascript    var el = document.getElementById('production'); if(el) el.scrollIntoView({behavior: 'smooth', block: 'center'});
    Sleep    2s
    Wait Until Element Is Visible    ${PRODUCTION_MENU}    timeout=15s
    Mouse Over    ${PRODUCTION_MENU}
    Sleep    1s

Click On Field Report Menu
    Wait Until Element Is Visible    ${FIELD_REPORT_MENU}    timeout=10s
    Click Element    ${FIELD_REPORT_MENU}
    Sleep    3s

Open Field Report Edit Page
    Wait Until Element Is Visible    ${FILTER_FRAME_HEADER}    timeout=20s
    Click Element    ${FILTER_FRAME_HEADER}
    Wait Until Page Contains Element    ${SEARCH_BUTTON_XPATH}    timeout=10s
    Click Search Button

    FOR    ${i}    IN RANGE    10
        ${is_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${FIELD_REPORT_ROW}    timeout=5s
        IF    ${is_visible}
            Exit For Loop
        END

        Click Element    ${FILTER_FRAME_HEADER}
        Wait Until Element Is Visible    ${START_WORK_DATE_INPUT}

        ${current_date_str}=    Get Value    ${START_WORK_DATE_INPUT}
        ${date_object}=    Evaluate    datetime.datetime.strptime($current_date_str, '%Y-%m-%d')    modules=datetime
        ${new_date_object}=    Evaluate    $date_object - datetime.timedelta(days=7)    modules=datetime
        ${new_date_str}=    Evaluate    $new_date_object.strftime('%Y-%m-%d')
        Input Text    ${START_WORK_DATE_INPUT}    ${new_date_str}
        Click Search Button
    END

    Wait Until Element Is Visible    ${FIELD_REPORT_LINK}
    ${before_click_handles}=    Get Window Handles
    Click Element    ${FIELD_REPORT_LINK}
    Sleep    2s
    ${after_click_handles}=    Get Window Handles
    ${new_tab}=    Get New Window Handle    ${before_click_handles}    ${after_click_handles}
    Set Suite Variable    ${new_tab}

Click Search Button
    ${element}=    Get Webelement    ${SEARCH_BUTTON_XPATH}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${element}

Switch To New Tab And Verify Field Report Text
    Switch Window    ${new_tab}
    Wait Until Page Contains    FIELD REPORT    timeout=30s
    ${has_text}=    Run Keyword And Return Status    Page Should Contain    FIELD REPORT
    IF    not ${has_text}
        Log To Console    ⚠ 'FIELD REPORT' text not found with standard check. Checking page source...
        ${source}=    Get Source
        Should Contain    ${source}    FIELD REPORT    msg=Edit page should contain 'FIELD REPORT' text
    END
    Log To Console    "FIELD REPORT text found. Edit page opened successfully."

Get New Window Handle
    [Arguments]    ${before}    ${after}
    FOR    ${handle}    IN    @{after}
        Run Keyword If    '${handle}' not in ${before}    Return From Keyword    ${handle}
    END
    Fail    No new tab opened after clicking field report link.
