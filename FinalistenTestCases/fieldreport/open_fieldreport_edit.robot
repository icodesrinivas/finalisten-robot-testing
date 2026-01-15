*** Settings ***
Library    SeleniumLibrary
Library    DateTime
Library    String
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_MENU}           xpath=//*[@id="production"]
${FIELD_REPORT_MENU}         xpath=//*[@id="field_reports_app_menu"]
${FILTER_FRAME_HEADER}       id=fieldreport_list_filter
${START_WORK_DATE_INPUT}     id=start_work_date
${END_WORK_DATE_INPUT}       id=end_work_date
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

    ${today}=    Get Current Date    result_format=%Y-%m-%d
    ${current_end_date}=    Set Variable    ${today}

    FOR    ${i}    IN RANGE    20    # Check up to 5 years (20 * 90 days)
        ${is_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${FIELD_REPORT_ROW}    timeout=5s
        IF    ${is_visible}
            Exit For Loop
        END

        ${current_start_date}=    Subtract Time From Date    ${current_end_date}    90 days    result_format=%Y-%m-%d
        Log To Console    Searching for records between ${current_start_date} and ${current_end_date} (Iteration: ${i})
        
        Click Element    ${FILTER_FRAME_HEADER}
        Wait Until Element Is Visible    ${START_WORK_DATE_INPUT}
        
        Clear Element Text    ${START_WORK_DATE_INPUT}
        Input Text    ${START_WORK_DATE_INPUT}    ${current_start_date}
        Clear Element Text    ${END_WORK_DATE_INPUT}
        Input Text    ${END_WORK_DATE_INPUT}    ${current_end_date}
        
        Click Search Button
        # Prepare for next window if this one fails
        ${current_end_date}=    Set Variable    ${current_start_date}
    END

    Wait Until Element Is Visible    ${FIELD_REPORT_LINK}
    ${before_click_handles}=    Get Window Handles
    ${link_elem}=    Get WebElement    ${FIELD_REPORT_LINK}
    Execute Javascript    arguments[0].scrollIntoView({block: "center"});    ARGUMENTS    ${link_elem}
    Sleep    1s
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${link_elem}
    Sleep    2s
    ${after_click_handles}=    Get Window Handles
    ${new_tab}=    Find New Window Handle    ${before_click_handles}    ${after_click_handles}
    Set Suite Variable    ${new_tab}

Click Search Button
    ${element}=    Get Webelement    ${SEARCH_BUTTON_XPATH}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${element}

Switch To New Tab And Verify Field Report Text
    Switch Window    ${new_tab}
    Wait Until Keyword Succeeds    3x    10s    Wait Until Page Contains    FIELD REPORT    timeout=10s
    ${has_text}=    Run Keyword And Return Status    Page Should Contain    FIELD REPORT
    IF    not ${has_text}
        Log To Console    ⚠ 'FIELD REPORT' text not found with standard check. Checking page source...
        ${source}=    Get Source
        # Log To Console    Page Source: ${source}
        Should Contain    ${source}    FIELD REPORT    msg=Edit page should contain 'FIELD REPORT' text
    END
    Log To Console    "FIELD REPORT text found. Edit page opened successfully."

Find New Window Handle
    [Arguments]    ${before}    ${after}
    ${handles}=    Get Window Handles
    ${handle_count}=    Get Length    ${handles}
    IF    ${handle_count} > 1
        FOR    ${handle}    IN    @{handles}
            IF    '${handle}' not in ${before}
                RETURN    ${handle}
            END
        END
    END
    # Fallback: Just return the last handle if it's new
    IF    '${after}[-1]' not in ${before}
        RETURN    ${after}[-1]
    END
    Fail    No new tab opened after clicking field report link. Current handles: ${handle_count}
