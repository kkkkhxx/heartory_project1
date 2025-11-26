*** Settings ***
Library    SeleniumLibrary    timeout=10s    implicit_wait=0.3
Resource   ../../pages/customer/CustomerLogin.robot
Resource   ../../pages/admin/AdminLogin.robot
Variables  ../../config/Env.robot

*** Variables ***
${CUS_LOC_NAV_ACCOUNT}     css=a[data-testid="nav-account-link"]
${ADMIN_LOC_CUSTOMERS_BUTTON}   xpath=//p[@class='font-medium font-sans txt-compact-small' and text()='Customers']
${LOC_WELCOME_MESSAGE}     xpath=//span[@data-testid="welcome-message"]
${ADMIN_LOC_SEARCH_BOX}    xpath=//input[@name="q"]
${LOC_FIRST_ORDER_ROW}     xpath=//table/tbody/tr[1] 
${LOC_CUSTOMER_EMAIL}      xpath=//span[@data-testid="customer-email"]  # XPath for email

${VIEWPORT_W}              1366
${VIEWPORT_H}              768

*** Test Cases ***
Test Customer Order History and Verify in Admin
    Open Customer Browser
    Customer Login    ${CUS_USER_HAM}    ${CUS_PASS_HAM}
    Retrieve Customer Email
    Open Admin Browser And Login
    Search Order in Admin

*** Keywords ***
Customer Page Should Be Visible
    Wait Until Element Is Visible    ${CUS_LOC_NAV_ACCOUNT}    10s

Customer Login
    [Arguments]    ${email}    ${password}
    Switch Browser    CUSTOMER
    Go To    ${CUSTOMER_URL}
    Wait Until Element Is Visible    ${CUS_LOC_NAV_ACCOUNT}    10s
    Click Element    ${CUS_LOC_NAV_ACCOUNT}
    Wait Until Element Is Visible    ${LOC_USERNAME}    10s
    Input Text    ${LOC_USERNAME}    ${email}
    Input Text    ${LOC_PASSWORD}    ${password}
    Click Button    ${CUS_LOC_SUBMIT}
    Wait Until Element Is Visible    ${CUS_LOC_NAV_ACCOUNT}    15s

Navigate To Orders Page
    Wait Until Element Is Visible    ${CUS_LOC_NAV_ACCOUNT}    10s
    Click Element    ${CUS_LOC_NAV_ACCOUNT}   
    Click Element    ${CUS_LOC_ORDERS_BUTTON}
    Wait Until Page Contains    Orders    15s

Retrieve Customer Email
    [Documentation]    Extract the email from the customer account page.
    Switch Browser    CUSTOMER
    Wait Until Element Is Visible    ${LOC_CUSTOMER_EMAIL}    10s
    ${customer_email}=    Get Text    ${LOC_CUSTOMER_EMAIL}
    Set Global Variable    ${ORDER_EMAIL}    ${customer_email}   # Store the email to be used for searching

Open Admin Browser And Login
    Open Admin Browser
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Wait Until Element Is Visible    ${LOC_DASHBOARD_TAG}    15s

Search Order in Admin
    [Documentation]    Search the extracted customer email in Admin page.
    Switch Browser    ADMIN
    Wait Until Element Is Visible    ${ADMIN_LOC_CUSTOMERS_BUTTON}    10s
    Click Element    ${ADMIN_LOC_CUSTOMERS_BUTTON}    # คลิกปุ่ม Customers
    Wait Until Element Is Visible    ${ADMIN_LOC_SEARCH_BOX}    10s
    Input Text    ${ADMIN_LOC_SEARCH_BOX}    ${ORDER_EMAIL}
    Press Keys    ${ADMIN_LOC_SEARCH_BOX}    ENTER
    # รอจนกว่าผลลัพธ์การค้นหาจะครบถ้วน
    Wait Until Element Contains    ${LOC_FIRST_ORDER_ROW}    ${ORDER_EMAIL}    10s
    # หรือรอให้แถวคำสั่งซื้อแรกปรากฏ
    Wait Until Element Is Visible    ${LOC_FIRST_ORDER_ROW}    10s
    Click Element    ${LOC_FIRST_ORDER_ROW}
    Log    Found Order with Customer Email ${ORDER_EMAIL} in Admin
    Sleep    2s

