*** Settings ***
Library           SeleniumLibrary    timeout=10s    implicit_wait=0.3
Library    String
Resource          ../../config/Env.robot
Resource          ../../pages/admin/AdminLogin.robot
Resource          ../../pages/customer/CustomerLogin.robot
Resource          Happy_Edit_Customer_Profile.robot
Suite Setup       Open Admin Browser


*** Variables ***
${CUSTOMER_SEARCH_INPUT}        xpath=//input[@type='search' and @name='q']
${CUSTOMERS_TABLE}              xpath=//table[.//th[normalize-space()='Email']]

${DELETE_CUSTOMER_MODAL}          xpath=//div[@role='alertdialog' and contains(.,'Delete Customer')]
${DELETE_CUSTOMER_INPUT}    xpath=//input[@id='verificationText']
${DELETE_CUSTOMER_CONFIRM_BTN}    xpath=//div[@role='alertdialog']//button[contains(.,'Delete')]

${CUSTOMER_ACTION_MENU_BTN_TEMPLATE}    xpath=//h1[normalize-space(.)='__EMAIL__']
...    /ancestor::*[self::section or self::div][1]
...    //button[.//*[name()='svg']][1]

${MENUITEM_DELETE_CUSTOMER}    xpath=//div[@role='menu']//div[@role='menuitem'][contains(normalize-space(),'Delete')]

   
*** Keywords ***
Get Customer Action Menu Locator
    [Arguments]    ${email}
    ${locator}=    Replace String    ${CUSTOMER_ACTION_MENU_BTN_TEMPLATE}    __EMAIL__    ${email}
    [Return]       ${locator}

Search Customer By Email
    [Arguments]    ${email}
    Wait Until Element Is Visible    ${CUSTOMER_SEARCH_INPUT}    10s
    Click Element                    ${CUSTOMER_SEARCH_INPUT}
    Clear Element Text               ${CUSTOMER_SEARCH_INPUT}
    Input Text                       ${CUSTOMER_SEARCH_INPUT}    ${email}
    Press Keys                       ${CUSTOMER_SEARCH_INPUT}    ENTER
    Wait Until Location Contains     q=    10s
    Wait Until Element Is Visible    ${CUSTOMERS_TABLE}          20s
    Wait Until Page Contains         ${email}                    20s

Open Customer From Search By Email
    [Arguments]    ${email}
    ${locator}=    Set Variable
    ...    xpath=//table[.//th[normalize-space()='Email']]//tbody//tr[.//a[@data-row-link='true' and normalize-space()='${email}']]//a[@data-row-link='true']
    Wait Until Element Is Visible    ${locator}    20s
    Click Element                    ${locator}

Open Customer Action Menu
    [Arguments]    ${email}
    ${locator}=    Get Customer Action Menu Locator    ${email}
    Wait Until Element Is Visible    ${locator}    10s
    Click Element                    ${locator}
    Wait Until Element Is Visible    xpath=//div[@role='menu']    5s


Choose Delete From Customer Menu
    # เมนูถูกเปิดแล้วจาก Open Customer Action Menu
    Wait Until Element Is Visible    xpath=//div[@role='menu']    5s
    Wait Until Element Is Visible    ${MENUITEM_DELETE_CUSTOMER}    10s
    Click Element                    ${MENUITEM_DELETE_CUSTOMER}

Confirm Delete Customer By Email
    [Arguments]    ${email}
    Wait Until Element Is Visible    ${DELETE_CUSTOMER_MODAL}        10s
    Wait Until Element Is Visible    ${DELETE_CUSTOMER_INPUT}        10s
    Clear Element Text               ${DELETE_CUSTOMER_INPUT}
    Input Text                       ${DELETE_CUSTOMER_INPUT}        ${email}
    Wait Until Element Is Enabled    ${DELETE_CUSTOMER_CONFIRM_BTN}  10s
    Click Element                    ${DELETE_CUSTOMER_CONFIRM_BTN}

Delete Customer From Detail Page
    [Arguments]    ${email}
    Open Customer Action Menu           ${email}
    Choose Delete From Customer Menu
    Confirm Delete Customer By Email    ${email}
    Wait Until Location Contains    /app/customers    10s
    Wait Until Page Does Not Contain    ${email}      20s

Search Customer By Email (No Assert)
    [Arguments]    ${email}
    Wait Until Element Is Visible    ${CUSTOMER_SEARCH_INPUT}    10s
    Click Element                    ${CUSTOMER_SEARCH_INPUT}
    Clear Element Text               ${CUSTOMER_SEARCH_INPUT}
    Input Text                       ${CUSTOMER_SEARCH_INPUT}    ${email}
    Press Keys                       ${CUSTOMER_SEARCH_INPUT}    ENTER
    Wait Until Location Contains     q=    10s
    # ไม่ต้อง Wait Until Element Is Visible ${CUSTOMERS_TABLE}
    # ให้รอจนมีข้อความ "results" ที่ด้านล่าง เช่น "0 — 0 of 0 results"
    Wait Until Page Contains    results    10s

Customer Should Not Exist In Table
    [Arguments]    ${email}
    # 1) ค้นหาด้วย email อีกครั้ง
    Search Customer By Email (No Assert)    ${email}
    # 2) หน้าต้องแสดง "No results"
    Wait Until Page Contains    No results    10s

Back To Customers List
    Go To    ${ADMIN_URL}customers
    Wait Until Element Is Visible    ${ADMIN_MENU_CUSTOMER}    10s
