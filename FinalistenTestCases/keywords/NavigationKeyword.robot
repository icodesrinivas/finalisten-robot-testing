*** Settings ***
Library    SeleniumLibrary

*** Variables ***
${BASE_URL}                  https://preproderp.finalisten.se
${SIDEBAR_TOGGLE_OPEN}       css=button[aria-label="Öppna sidopanel"]
${SIDEBAR_TOGGLE_ANY}        css=header button[aria-label*="sidopanel"]
${LEGACY_IFRAME}             css=main iframe
${CONTACTS_MENU_LINK}        xpath=//a[contains(@href,'/register/contact/list')]
${CUSTOMERS_MENU_LINK}       xpath=//a[contains(@href,'/register/customers/list')]
${CONTACT_SEARCH_INPUT}      xpath=//input[contains(@placeholder,'Search name') or contains(@placeholder,'Sök namn')]
${CUSTOMER_SEARCH_INPUT}     xpath=//input[contains(@placeholder,'Search customer') or contains(@placeholder,'Sök kundnr')]
${CONTACT_CREATE_BUTTON}     xpath=//button[@aria-label='New contact' or @aria-label='Ny kontakt']
${CONTACTS_LIST_TITLE}       xpath=//h2[contains(normalize-space(),'Contacts') or contains(normalize-space(),'Kontakter')]
${CUSTOMERS_LIST_TITLE}      xpath=//h2[contains(normalize-space(),'Customers') or contains(normalize-space(),'Kunder')]

*** Keywords ***
Ensure Top Level Window Context
    [Documentation]    Leave legacy iframe so shell URL checks and Go To target the React shell.
    Run Keyword And Ignore Error    Unselect Frame

Wait For Erp Shell Ready
    [Documentation]    Waits for the React ERP shell after login (left sidebar layout).
    Ensure Top Level Window Context
    Wait Until Keyword Succeeds    45x    1s    Erp Shell Is Ready

Erp Shell Is Ready
    ${url}=    Get Location
    Should Contain    ${url}    preproderp.finalisten.se
    ${toggle}=    Run Keyword And Return Status    Page Should Contain Element    ${SIDEBAR_TOGGLE_ANY}
    ${react_main}=    Run Keyword And Return Status    Page Should Contain Element    css=main
    Should Be True    ${toggle} or ${react_main}    msg=React ERP shell did not load.

Open Sidebar If Collapsed
    ${needs_open}=    Run Keyword And Return Status    Element Should Be Visible    ${SIDEBAR_TOGGLE_OPEN}
    IF    ${needs_open}
        Click Element    ${SIDEBAR_TOGGLE_OPEN}
        Wait Until Page Contains Element    ${SIDEBAR_TOGGLE_ANY}    timeout=5s
    END

Navigate Via Sidebar To
    [Arguments]    ${menu_link_locator}    ${expected_path_fragment}
    Wait For Erp Shell Ready
    Open Sidebar If Collapsed
    Wait Until Element Is Visible    ${menu_link_locator}    timeout=20s
    ${link}=    Get WebElement    ${menu_link_locator}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${link}
    Wait Until Location Contains    ${expected_path_fragment}    timeout=45s

Navigate To Legacy Path
    [Documentation]    Fast navigation: shell route change + legacy iframe load (no hover menus).
    [Arguments]    ${path}
    Ensure Top Level Window Context
    Wait For Erp Shell Ready
    ${normalized}=    Set Variable    ${path}
    IF    not '${normalized}'.endswith('/')
        ${normalized}=    Set Variable    ${path}/
    END
    IF    not '${normalized}'.startswith('/')
        ${normalized}=    Set Variable    /${path}
    END
    Go To    ${BASE_URL}${normalized}
    ${fragment}=    Evaluate    '${normalized}'.strip('/')
    Wait Until Location Contains    ${fragment}    timeout=45s
    Wait For Legacy Iframe Ready

Navigate To Legacy Full Url
    [Documentation]    Top-level navigation to a legacy page URL inside the React shell iframe.
    [Arguments]    ${url}
    Ensure Top Level Window Context
    Go To    ${url}
    Wait For Legacy Iframe Ready
    Select Legacy Content Frame

Wait For Legacy Iframe Ready
    Ensure Top Level Window Context
    Wait Until Page Contains Element    ${LEGACY_IFRAME}    timeout=45s
    Wait Until Keyword Succeeds    45x    1s    Legacy Iframe Document Ready

Legacy Iframe Document Ready
    Select Frame    ${LEGACY_IFRAME}
    ${state}=    Execute Javascript    return document.readyState
    Unselect Frame
    Should Be Equal    ${state}    complete

Select Legacy Content Frame
    [Documentation]    Enter the legacy iframe when at shell level; no-op if already inside legacy content.
    ${can_see_iframe}=    Run Keyword And Return Status    Page Should Contain Element    ${LEGACY_IFRAME}    timeout=3s
    IF    ${can_see_iframe}
        Wait For Legacy Iframe Ready
        Select Frame    ${LEGACY_IFRAME}
    END

Unselect Legacy Content Frame
    Run Keyword And Ignore Error    Unselect Frame

Legacy Wait Until Element Is Visible
    [Arguments]    ${locator}    ${timeout}=30s
    Select Legacy Content Frame
    Wait Until Element Is Visible    ${locator}    timeout=${timeout}
    Unselect Legacy Content Frame

Legacy Wait Until Page Contains Element
    [Arguments]    ${locator}    ${timeout}=30s
    Select Legacy Content Frame
    Wait Until Page Contains Element    ${locator}    timeout=${timeout}
    Unselect Legacy Content Frame

Legacy Page Should Contain
    [Arguments]    ${text}    ${timeout}=20s
    Select Legacy Content Frame
    Wait Until Page Contains    ${text}    timeout=${timeout}
    Unselect Legacy Content Frame

Legacy Click Element
    [Arguments]    ${locator}
    Select Legacy Content Frame
    ${el}=    Get WebElement    ${locator}
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${el}
    Unselect Legacy Content Frame

Reload Legacy Content Page
    Ensure Top Level Window Context
    Reload Page
    Wait For Legacy Iframe Ready
    Select Legacy Content Frame

# --- React apps (contacts / customers) ---------------------------------
Navigate To Contacts App
    Navigate Via Sidebar To    ${CONTACTS_MENU_LINK}    /register/contact/list
    Wait For Contacts List Loaded

Navigate To Customers App
    Navigate Via Sidebar To    ${CUSTOMERS_MENU_LINK}    /register/customers/list
    Wait For Customers List Loaded

Wait For Contacts List Loaded
    Wait Until Keyword Succeeds    45x    1s    Contacts List Content Ready

Contacts List Content Ready
    ${loading}=    Run Keyword And Return Status    Page Should Contain Element    xpath=//*[contains(text(),'Loading contacts') or contains(text(),'Laddar kontakter')]
    IF    ${loading}    Fail    Contacts list is still loading.
    ${has_search}=    Run Keyword And Return Status    Page Should Contain Element    ${CONTACT_SEARCH_INPUT}
    ${has_title}=    Run Keyword And Return Status    Page Should Contain Element    ${CONTACTS_LIST_TITLE}
    Should Be True    ${has_search} or ${has_title}

Wait For Customers List Loaded
    Wait Until Keyword Succeeds    45x    1s    Customers List Content Ready

Customers List Content Ready
    ${loading}=    Run Keyword And Return Status    Page Should Contain Element    xpath=//*[contains(text(),'Loading customers') or contains(text(),'Laddar kunder')]
    IF    ${loading}    Fail    Customers list is still loading.
    ${has_search}=    Run Keyword And Return Status    Page Should Contain Element    ${CUSTOMER_SEARCH_INPUT}
    ${has_title}=    Run Keyword And Return Status    Page Should Contain Element    ${CUSTOMERS_LIST_TITLE}
    Should Be True    ${has_search} or ${has_title}

Open First Contact From List
    Wait Until Element Is Visible    css=table tbody tr    timeout=20s
    ${row}=    Get WebElement    css=table tbody tr:first-child
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${row}
    Wait Until Location Contains    /edit/    timeout=20s
    Wait Until Page Contains Element    xpath=//*[@role='tab' and (contains(.,'Contact details') or contains(.,'Kontaktuppgifter'))]    timeout=20s

Open Contact Create Dialog
    Wait Until Element Is Visible    ${CONTACT_CREATE_BUTTON}    timeout=20s
    Click Element    ${CONTACT_CREATE_BUTTON}
    Wait Until Page Contains Element    css=[role="dialog"]    timeout=15s

Open First Customer From List
    Wait Until Element Is Visible    css=table tbody tr    timeout=20s
    ${row}=    Get WebElement    css=table tbody tr:first-child
    Execute Javascript    arguments[0].click();    ARGUMENTS    ${row}
    Wait Until Location Contains    /edit/    timeout=20s
    Wait Until Page Contains Element    xpath=//*[@role='tab' and (contains(.,'Basic info') or contains(.,'Grunduppgifter'))]    timeout=20s

Verify Customer Registry Actions Visible
    Wait Until Page Contains Element    xpath=//button[@aria-label='Export CSV' or @aria-label='Exportera CSV']    timeout=15s

Navigate To Field Report List
    Navigate To Legacy Path    /fieldreport/list/
    Select Legacy Content Frame

Navigate To Field Report Create Page
    Navigate To Legacy Path    /fieldreport/create/
    Select Legacy Content Frame

Open Legacy Field Report Edit By Id
    [Arguments]    ${fieldreport_id}
    Navigate To Legacy Full Url    ${BASE_URL}/fieldreport/list/${fieldreport_id}/edit/

Legacy Frame Location Contains
    [Arguments]    ${fragment}
    ${url}=    Execute Javascript    return window.location.href
    Should Contain    ${url}    ${fragment}

Wait Until Field Report Saved To Edit Page
    [Documentation]    After save on create page, navigation occurs inside the legacy iframe.
    Wait Until Keyword Succeeds    20x    2s    Legacy Frame Location Contains    /edit/

# --- Legacy register apps ----------------------------------------------
Navigate To Employee List
    Navigate To Legacy Path    /employees/employee/list/
    Select Legacy Content Frame

Navigate To Guest User List
    Navigate To Legacy Path    /employees/guestuser/list/
    Select Legacy Content Frame

Navigate To Supplier List
    Navigate To Legacy Path    /supplier/list/
    Select Legacy Content Frame

Navigate To Subcontractor List
    Navigate To Legacy Path    /subcontractor/list/
    Select Legacy Content Frame

Navigate To Product Register List
    Navigate To Legacy Path    /products/list/
    Select Legacy Content Frame

Navigate To Purchase Product Register List
    Navigate To Legacy Path    /purchaseproductregister/list/
    Select Legacy Content Frame

Navigate To Old Settings App
    Navigate To Legacy Path    /global_setting/global_setting_view/
    Select Legacy Content Frame

# --- Legacy production apps --------------------------------------------
Navigate To Field Report Approval
    Navigate To Legacy Path    /fieldreport/fieldreport_approval/
    Select Legacy Content Frame

Navigate To My Production
    Navigate To Legacy Path    /fieldreport/fieldreport_approval_installer/
    Select Legacy Content Frame

Navigate To Project List
    Navigate To Legacy Path    /projects/list/
    Select Legacy Content Frame

Navigate To Resource Planning Board
    Navigate To Legacy Path    /resourceplanning/resourceplanning_board/
    Select Legacy Content Frame

Navigate To Door Planning Board
    Navigate To Legacy Path    /doorplanning/doorplanning_board/
    Select Legacy Content Frame

Navigate To Daily Planner Home
    Navigate To Legacy Path    /kanbanboard/home/
    Select Legacy Content Frame

# --- Legacy sales / admin / reports ------------------------------------
Navigate To Quotation List
    Navigate To Legacy Path    /quotation/list/
    Select Legacy Content Frame

Navigate To Invoicing Tree
    Navigate To Legacy Path    /invoice/invoicereport_tree_view/
    Select Legacy Content Frame

Navigate To Invoice List
    Navigate To Legacy Path    /invoice/invoicereport_list_view/
    Select Legacy Content Frame

Navigate To Project Report
    Navigate To Legacy Path    /report/project_report_list/
    Select Legacy Content Frame

Navigate To Invoice Report
    Navigate To Legacy Path    /report/invoice_report_list/
    Select Legacy Content Frame

Navigate To Performance Report
    Navigate To Legacy Path    /report/performance_report_view/
    Select Legacy Content Frame
