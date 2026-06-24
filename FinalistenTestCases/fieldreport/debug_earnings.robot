*** Settings ***
Documentation    Debug test to dump field report create page source.
Library          SeleniumLibrary
Library          OperatingSystem
Resource         ../keywords/LoginKeyword.robot
Resource         ../keywords/NavigationKeyword.robot

*** Test Cases ***
Debug Field Report Creation Page Source
    [Documentation]    Dump create page source for troubleshooting.
    Open And Login
    Navigate To Legacy Path    /fieldreport/create/
    Select Legacy Content Frame
    Wait Until Element Is Visible    id=id_related_customer    timeout=30s
    ${src}=    Get Source
    Create File    ${OUTPUT DIR}/debug_create_page.html    ${src}
    [Teardown]    Close Browser
