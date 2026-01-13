*** Settings ***
Library          SeleniumLibrary
Library          OperatingSystem
Resource         ../keywords/LoginKeyword.robot

*** Variables ***
${SETTINGS_URL}    https://preproderp.finalisten.se/setting/
${OUTPUT_FILE}     ${OUTPUT DIR}/settings_page_source.html

*** Test Cases ***
Dump Settings Page Source
    Open And Login
    Mouse Over    xpath=//*[@id="register"]
    Sleep    1s
    Click Element    xpath=//*[@id="settings_app_menu"]
    Sleep    3s
    ${source}=    Get Source
    Create File    ${OUTPUT_FILE}    ${source}
    Log To Console    Settings page source saved to ${OUTPUT_FILE}
    
    # Force show the list item
    Execute Javascript    document.querySelector("a[class='global_setting_child_leaf']").parentNode.parentNode.style.display = 'block'
    Execute Javascript    document.querySelector("a[class='global_setting_child_leaf']").parentNode.style.display = 'block'
    # Or more specific selector
    Execute Javascript    var el = document.evaluate("//a[contains(text(),'Reporting Date Range')]/parent::li", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue; el.style.display = 'block'; el.parentNode.style.display = 'block';
    Sleep    1s
    
    # Click Pencil icon for Reporting Date Range
    Wait Until Element Is Visible    id=id_global_setting    timeout=10s
    Click Element    id=id_global_setting
    Sleep    3s
    
    # Dump source again to see the form
    ${form_source}=    Get Source
    Create File    ${OUTPUT_FILE}_form.html    ${form_source}
    Log To Console    Settings form source saved to ${OUTPUT_FILE}_form.html
    
    Close Browser
