*** Settings ***
Library    SeleniumLibrary
Resource   ../keywords/LoginKeyword.robot

*** Variables ***
${PRODUCTION_MENU}           xpath=//*[@id="production"]
${FIELD_REPORT_MENU}         xpath=//*[@id="field_reports_app_menu"]
${FIELD_REPORT_LINK}         xpath=//a[contains(@href, '/fieldreport/list/') and contains(@href, '/edit/')]

*** Test Cases ***
Verify Field Report Edit Page Opens Successfully
    Open And Login
    Hover Over Production Menu
    Click On Field Report Menu
    Click On Any Field Report Edit Link
    Switch To New Tab And Verify Field Report Text
    Close Browser

*** Keywords ***
Hover Over Production Menu
    Mouse Over    ${PRODUCTION_MENU}

Click On Field Report Menu
    Click Element    ${FIELD_REPORT_MENU}

Click On Any Field Report Edit Link
    Wait Until Element Is Visible    ${FIELD_REPORT_LINK}    timeout=10s
    ${before_click_handles}=    Get Window Handles
    Click Element    ${FIELD_REPORT_LINK}
    Sleep    2s
    ${after_click_handles}=    Get Window Handles
    ${new_tab}=    Get New Window Handle    ${before_click_handles}    ${after_click_handles}
    Set Suite Variable    ${new_tab}

Switch To New Tab And Verify Field Report Text
    Switch Window    ${new_tab}
    Wait Until Page Contains    FIELD REPORT    timeout=10s
    Log To Console    "FIELD REPORT text found. Edit page opened successfully."

Get New Window Handle
    [Arguments]    ${before}    ${after}
    FOR    ${handle}    IN    @{after}
        Run Keyword If    '${handle}' not in ${before}    Return From Keyword    ${handle}
    END
    Fail    No new tab opened after clicking field report link.
