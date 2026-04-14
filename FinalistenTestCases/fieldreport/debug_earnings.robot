*** Settings ***
1: *** Settings ***
2: Documentation    Debug test to dump sources.
3: Library          SeleniumLibrary
4: Library          OperatingSystem
5: Resource         ../keywords/LoginKeyword.robot
6: 
7: *** Test Cases ***
8: Debug Field Report Creation And Products
9:     [Documentation]    Dump sources to debug earnings calculation failure.
10:     Open And Login
11:     
12:     Go To    https://preproderp.finalisten.se/fieldreport/create/
13:     
14:     # Fill basic details
15:     Wait Until Element Is Visible    id=id_related_customer    timeout=15s
16:     Select From List By Index    id=id_related_customer    1
17:     ${element}=    Get WebElement    id=id_related_customer
18:     Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
19:     Sleep    2s
20:     Select From List By Index    id=id_related_project    1
21:     ${element}=    Get WebElement    id=id_related_project
22:     Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
23:     Sleep    2s
24:     Select From List By Index    id=id_related_subproject    1
25:     Input Text    id=id_work_date    2025-10-20
26:     Input Text    id=id_total_work_hours    8
27:     Select From List By Index    id=id_installer_name    1
28:     
29:     # Save (create FR)
30:     Click Element    css=button.save
31:     Wait Until Location Contains    /edit/    timeout=15s
32:     ${id}=    Extract And Verify Fieldreport ID
33:     Set Suite Variable    ${CREATED_FIELDREPORT_ID}    ${id}
34:     
35:     # Dump Edit Page Source
36:     ${src}=    Get Source
37:     Create File    ${OUTPUT DIR}/debug_edit_page.html    ${src}
38:     
39:     # Open Modal
40:     Execute Javascript    window.scrollTo(0, 800);
41:     Click Element    xpath=//span[text()='ADD']
42:     Wait Until Element Is Visible    id=myModal3    timeout=10s
43:     Sleep    3s
44:     ${modal_src}=    Get Source
45:     Create File    ${OUTPUT DIR}/debug_modal.html    ${modal_src}
46:     
47:     # Select product
48:     Click Element    css=#myTable .selected-checkbox
49:     Click Element    css=.prodinfr_save_button
50:     Sleep    2s
51:     Run Keyword And Ignore Error    Handle Alert    action=ACCEPT    timeout=3s
52:     
53:     # Dump source after adding product
54:     ${after_add_src}=    Get Source
55:     Create File    ${OUTPUT DIR}/debug_edit_page_with_product.html    ${after_add_src}
56:     
57:     [Teardown]    Cleanup Created Fieldreport
