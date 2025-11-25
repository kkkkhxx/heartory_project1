*** Settings ***
Library           SeleniumLibrary
Resource          ../../pages/admin/AdminLogin.robot

Suite Setup       Open Admin Browser
Suite Teardown    Close All Browsers


*** Variables ***
${ADMIN_URL}             http://10.34.112.158:9000/app/orders

# ------ Sidebar ------
${BTN_PRODUCTS}          xpath=//a[contains(@href,'/app/products') and .//p[text()='Products']]
${BTN_CATEGORIES}        xpath=//a[contains(@href,'/app/categories') and .//p[text()='Categories']]

# ------ Login ------
${BTN_CONTINUE_EMAIL}    xpath=//button[contains(.,'Continue with Email')]
${INPUT_EMAIL}           xpath=//input[@name='email']
${INPUT_PASSWORD}        xpath=//input[@name='password']
${BTN_SIGNIN}            xpath=//button[normalize-space()='Continue']

# --- Category inside Products page ---
${BTN_CATEGORY_TAB}      xpath=//p[normalize-space()='Categories']
${CATEGORY_ITEM_MERCH}   xpath=//span[normalize-space()='Merch']

# --- Inside Merch Page ---
${BTN_CATEGORY_MENU}     xpath=//h2[normalize-space()='Products']/following::button[@aria-haspopup='menu'][1]
${BTN_ADD_PRODUCT}       xpath=//a[@role='menuitem' and contains(.,'Add')]
${INPUT_ADD_SEARCH}    xpath=//input[@type='search' and @name='q']
${CHECKBOX_BY_TITLE}   xpath=//span[normalize-space()='sikkhim']/ancestor::tr//button[@role='checkbox']
# Product row inside Merch page
${PRODUCT_TITLE_IN_MERCH}    xpath=//span[normalize-space()='sikkhim']

# Checkbox in Merch list
${PRODUCT_CHECKBOX_IN_MERCH}   xpath=//span[normalize-space()='sikkhim']/ancestor::tr//button[@role='checkbox']
${STORE_URL}      http://10.34.112.158:8000/dk


*** Keywords ***

Open Admin Browser
    Open Browser    ${ADMIN_URL}    chrome
    Maximize Browser Window
    Sleep    1s


Admin Login
    [Arguments]    ${user}    ${pass}
    Go To    ${ADMIN_URL}
    Admin Page Should Be Visible
    Input Text       ${LOC_USERNAME}    ${user}
    Input Text       ${LOC_PASSWORD}    ${pass}
    Click Button     ${LOC_SUBMIT}
    Wait Until Page Contains Element   ${LOC_DASHBOARD_TAG}    15s


Go To Products Page
    Wait Until Element Is Visible    ${BTN_PRODUCTS}    30s
    Click Element    ${BTN_PRODUCTS}
    Log To Console    เปิดหน้า Products สำเร็จ


Go To Categories Page
    Wait Until Element Is Visible    ${BTN_CATEGORIES}    30s
    Click Element    ${BTN_CATEGORIES}
    Log To Console    เปิดหน้า Categories สำเร็จ


Open Category Tab
    Wait Until Element Is Visible    ${BTN_CATEGORY_TAB}    30s
    Click Element    ${BTN_CATEGORY_TAB}
    Log To Console     เปิดแท็บ Categories แล้ว


Select Category Merch
    Wait Until Element Is Visible    ${CATEGORY_ITEM_MERCH}    30s
    Click Element    ${CATEGORY_ITEM_MERCH}
    Log To Console     เลือก Category: Merch สำเร็จ


Open Merch Menu
    Wait Until Element Is Visible    ${BTN_CATEGORY_MENU}    30s
    Click Element                    ${BTN_CATEGORY_MENU}
    Sleep    500ms
    Log To Console    ⋯ เปิดเมนู 3 จุดของ Merch แล้ว


Click Add Inside Merch
    Wait Until Element Is Visible    ${BTN_ADD_PRODUCT}    20s
    Click Element                    ${BTN_ADD_PRODUCT}
    Log To Console     เปิดหน้า Add Product ของ Merch สำเร็จ! 

Search Product In Add Page
    [Arguments]    ${KEYWORD}
    Wait Until Element Is Visible    ${INPUT_ADD_SEARCH}    20s
    Click Element    ${INPUT_ADD_SEARCH}
    Input Text       ${INPUT_ADD_SEARCH}    ${KEYWORD}
    Sleep    1s
    Log To Console    ค้นหา Product: ${KEYWORD} แล้ว
Select Product Checkbox By Title
    [Arguments]    ${TITLE}
    ${CHECKBOX}=    Set Variable    xpath=//span[normalize-space()='${TITLE}']/ancestor::tr//button[@role='checkbox']
    Wait Until Element Is Visible    ${CHECKBOX}    20s
    Click Element    ${CHECKBOX}
    Log To Console     เลือกสินค้า: ${TITLE} สำเร็จ!

Click Save Add Product
    ${BTN_SAVE}=    Set Variable    xpath=//button[normalize-space()='Save']
    Wait Until Element Is Visible    ${BTN_SAVE}    20s
    Click Element    ${BTN_SAVE}
    Log To Console     กด Save สำเร็จ!


*** Test Cases ***

TC_Admin_Navigate_To_Categories_And_Add_Product
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Go To Products Page
    Go To Categories Page
    Open Category Tab
    Select Category Merch
    Open Merch Menu
    Click Add Inside Merch
    Search Product In Add Page    sikkhim
    Select Product Checkbox By Title    sikkhim
    Click Save Add Product



