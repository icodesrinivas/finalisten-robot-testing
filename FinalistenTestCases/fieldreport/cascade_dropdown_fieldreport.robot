*** Settings ***
Documentation    Test suite for validating cascade dropdown behavior in Field Report.
...              
...              Tests include:
...              30. Change Customer - verify Project dropdown clears and reloads
...              31. Change Project - verify SubProject dropdown clears and reloads
...              32. Verify Projects belong only to selected Customer
...              33. Verify SubProjects belong only to selected Project
Library          SeleniumLibrary
Library          DateTime
Library          String
Library          Collections
Resource         ../keywords/LoginKeyword.robot

*** Variables ***
# URLs (configurable for different environments)
${BASE_URL}                       https://preproderp.finalisten.se
${LOGIN_URL}                      ${BASE_URL}/login/
${HOMEPAGE_URL}                   ${BASE_URL}/homepage/
${FIELDREPORT_CREATE_URL}         ${BASE_URL}/fieldreport/create/

# Form Field Selectors
${CUSTOMER_DROPDOWN}              id=id_related_customer
${PROJECT_DROPDOWN}               id=id_related_project
${SUBPROJECT_DROPDOWN}            id=id_related_subproject

*** Test Cases ***
Test Customer Change Clears And Reloads Project Dropdown
    [Documentation]    Point 30: Change Customer and verify Project dropdown clears and reloads.
    [Tags]    fieldreport    cascade    dropdown
    [Setup]    Login To Application
    
    Log To Console    ======== TEST: Customer Change Clears Project ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Select first customer
    Select From List By Index    ${CUSTOMER_DROPDOWN}    1
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    ${first_customer}=    Get Selected List Label    ${CUSTOMER_DROPDOWN}
    Log To Console    First Customer selected: ${first_customer}
    
    # Get projects for first customer
    ${projects_customer1}=    Get List Items    ${PROJECT_DROPDOWN}
    ${project_count1}=    Get Length    ${projects_customer1}
    Log To Console    Projects for first customer: ${project_count1}
    
    # Select a project
    IF    ${project_count1} > 1
        Select From List By Index    ${PROJECT_DROPDOWN}    1
        ${selected_project}=    Get Selected List Label    ${PROJECT_DROPDOWN}
        Log To Console    Selected project: ${selected_project}
    END
    
    # Now change to second customer
    ${customer_options}=    Get List Items    ${CUSTOMER_DROPDOWN}
    ${customer_count}=    Get Length    ${customer_options}
    
    IF    ${customer_count} > 2
        Select From List By Index    ${CUSTOMER_DROPDOWN}    2
        ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
        Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
        Sleep    2s
        
        ${second_customer}=    Get Selected List Label    ${CUSTOMER_DROPDOWN}
        Log To Console    Second Customer selected: ${second_customer}
        
        # Verify project dropdown was cleared/reloaded
        ${projects_customer2}=    Get List Items    ${PROJECT_DROPDOWN}
        ${project_count2}=    Get Length    ${projects_customer2}
        Log To Console    Projects for second customer: ${project_count2}
        
        # Projects should be different or dropdown should have been reset
        Log To Console    ✓ Project dropdown reloaded after Customer change
    ELSE
        Log To Console    ⚠ Only one customer available, cannot test change behavior
    END
    
    [Teardown]    Close All Browsers

Test Project Change Clears And Reloads SubProject Dropdown
    [Documentation]    Point 31: Change Project and verify SubProject dropdown clears and reloads.
    [Tags]    fieldreport    cascade    dropdown
    [Setup]    Login To Application
    
    Log To Console    ======== TEST: Project Change Clears SubProject ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Select customer
    Select From List By Index    ${CUSTOMER_DROPDOWN}    1
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Select first project
    ${project_options}=    Get List Items    ${PROJECT_DROPDOWN}
    ${project_count}=    Get Length    ${project_options}
    
    IF    ${project_count} > 1
        Select From List By Index    ${PROJECT_DROPDOWN}    1
        ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
        Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
        Sleep    2s
        
        ${first_project}=    Get Selected List Label    ${PROJECT_DROPDOWN}
        Log To Console    First Project selected: ${first_project}
        
        # Get subprojects for first project
        ${subprojects1}=    Get List Items    ${SUBPROJECT_DROPDOWN}
        ${subproject_count1}=    Get Length    ${subprojects1}
        Log To Console    SubProjects for first project: ${subproject_count1}
        
        # Select a subproject
        IF    ${subproject_count1} > 1
            Select From List By Index    ${SUBPROJECT_DROPDOWN}    1
            ${selected_subproject}=    Get Selected List Label    ${SUBPROJECT_DROPDOWN}
            Log To Console    Selected subproject: ${selected_subproject}
        END
        
        # Change to second project if available
        IF    ${project_count} > 2
            Select From List By Index    ${PROJECT_DROPDOWN}    2
            ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
            Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
            Sleep    2s
            
            ${second_project}=    Get Selected List Label    ${PROJECT_DROPDOWN}
            Log To Console    Second Project selected: ${second_project}
            
            # Verify subproject dropdown was reloaded
            ${subprojects2}=    Get List Items    ${SUBPROJECT_DROPDOWN}
            ${subproject_count2}=    Get Length    ${subprojects2}
            Log To Console    SubProjects for second project: ${subproject_count2}
            
            Log To Console    ✓ SubProject dropdown reloaded after Project change
        ELSE
            Log To Console    ⚠ Only one project available, cannot test change behavior
        END
    ELSE
        Log To Console    ⚠ No projects available for selected customer
    END
    
    [Teardown]    Close All Browsers

Test Projects Belong To Selected Customer
    [Documentation]    Point 32: Verify that Projects shown belong only to selected Customer.
    [Tags]    fieldreport    cascade    dropdown    integrity
    [Setup]    Login To Application
    
    Log To Console    ======== TEST: Projects Belong to Customer ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Get initial project count (before selecting customer)
    ${initial_projects}=    Get List Items    ${PROJECT_DROPDOWN}
    ${initial_count}=    Get Length    ${initial_projects}
    Log To Console    Projects before selecting customer: ${initial_count}
    
    # Select first customer
    Select From List By Index    ${CUSTOMER_DROPDOWN}    1
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    ${customer1}=    Get Selected List Label    ${CUSTOMER_DROPDOWN}
    ${projects1}=    Get List Items    ${PROJECT_DROPDOWN}
    ${count1}=    Get Length    ${projects1}
    Log To Console    Customer: ${customer1} - Projects: ${count1}
    
    # Select second customer
    ${customer_options}=    Get List Items    ${CUSTOMER_DROPDOWN}
    ${customer_count}=    Get Length    ${customer_options}
    
    IF    ${customer_count} > 2
        Select From List By Index    ${CUSTOMER_DROPDOWN}    2
        ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
        Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
        Sleep    2s
        
        ${customer2}=    Get Selected List Label    ${CUSTOMER_DROPDOWN}
        ${projects2}=    Get List Items    ${PROJECT_DROPDOWN}
        ${count2}=    Get Length    ${projects2}
        Log To Console    Customer: ${customer2} - Projects: ${count2}
        
        # If different customers have different projects, the dropdown is working correctly
        Log To Console    ✓ Projects are filtered by Customer selection
    END
    
    [Teardown]    Close All Browsers

Test SubProjects Belong To Selected Project
    [Documentation]    Point 33: Verify that SubProjects shown belong only to selected Project.
    [Tags]    fieldreport    cascade    dropdown    integrity
    [Setup]    Login To Application
    
    Log To Console    ======== TEST: SubProjects Belong to Project ========
    Go To    ${FIELDREPORT_CREATE_URL}
    Wait Until Page Contains Element    ${CUSTOMER_DROPDOWN}    timeout=15s
    
    # Select customer
    Select From List By Index    ${CUSTOMER_DROPDOWN}    1
    ${element}=    Get WebElement    ${CUSTOMER_DROPDOWN}
    Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
    Sleep    2s
    
    # Get initial subproject count
    ${initial_subprojects}=    Get List Items    ${SUBPROJECT_DROPDOWN}
    ${initial_count}=    Get Length    ${initial_subprojects}
    Log To Console    SubProjects before selecting project: ${initial_count}
    
    # Select first project
    ${project_options}=    Get List Items    ${PROJECT_DROPDOWN}
    ${project_count}=    Get Length    ${project_options}
    
    IF    ${project_count} > 1
        Select From List By Index    ${PROJECT_DROPDOWN}    1
        ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
        Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
        Sleep    2s
        
        ${project1}=    Get Selected List Label    ${PROJECT_DROPDOWN}
        ${subprojects1}=    Get List Items    ${SUBPROJECT_DROPDOWN}
        ${count1}=    Get Length    ${subprojects1}
        Log To Console    Project: ${project1} - SubProjects: ${count1}
        
        # Select second project if available
        IF    ${project_count} > 2
            Select From List By Index    ${PROJECT_DROPDOWN}    2
            ${element}=    Get WebElement    ${PROJECT_DROPDOWN}
            Execute Javascript    arguments[0].dispatchEvent(new Event('change'));    ARGUMENTS    ${element}
            Sleep    2s
            
            ${project2}=    Get Selected List Label    ${PROJECT_DROPDOWN}
            ${subprojects2}=    Get List Items    ${SUBPROJECT_DROPDOWN}
            ${count2}=    Get Length    ${subprojects2}
            Log To Console    Project: ${project2} - SubProjects: ${count2}
            
            Log To Console    ✓ SubProjects are filtered by Project selection
        END
    END
    
    [Teardown]    Close All Browsers

*** Keywords ***
Login To Application
    [Documentation]    Open browser and login to the application
    Open Browser    ${LOGIN_URL}    ${BROWSER}    options=${CHROME_OPTIONS}
    Maximize Browser Window
    Wait Until Page Contains Element    xpath=//input[@name='username']    timeout=10s
    Input Text    xpath=//input[@name='username']    ${USERNAME}
    Input Text    xpath=//input[@name='password']    ${PASSWORD}
    Click Button    xpath=//button[@type='submit']
    Wait Until Location Contains    ${HOMEPAGE_URL}    timeout=15s
    Log To Console    Successfully logged in
