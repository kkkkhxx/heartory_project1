*** Settings ***
Library           SeleniumLibrary
Resource          ../../pages/admin/AdminLogin.robot

Suite Setup       Open Admin Browser
Suite Teardown    Close All Browsers


*** Variables ***
${ADMIN_URL}       http://10.34.112.158:9000/app/orders

# Sidebar buttons
${BTN_PRODUCTS}    xpath=//a[contains(@href,'/app/products') and .//p[text()='Products']]
${BTN_CATEGORIES}  xpath=//a[contains(@href,'/app/categories') and .//p[text()='Categories']]

# Category tabs
${BTN_CATEGORY_TAB}      xpath=//p[normalize-space()='Categories']
${CATEGORY_ITEM_MERCH}   xpath=//span[normalize-space()='Merch']

# Product row inside Merch
${PRODUCT_ROW_SIKKHIM}        xpath=//span[normalize-space()='sikkhim']
${PRODUCT_CHECKBOX_SIKKHIM}   xpath=//span[normalize-space()='sikkhim']/ancestor::tr//button[@role='checkbox']

# Remove bar
${BTN_REMOVE_BAR}        xpath=//span[normalize-space()='Remove']

# Remove confirm popup
${BTN_CONFIRM_REMOVE}    xpath=//button[normalize-space()='Remove']


*** Keywords ***

Open Admin Browser
    Open Browser    ${ADMIN_URL}    chrome
    Maximize Browser Window
    Sleep    1s


Go To Products Page First
    Wait Until Element Is Visible    ${BTN_PRODUCTS}    20s
    Click Element    ${BTN_PRODUCTS}
    Log To Console    ▶️ เข้าเมนู Products แล้ว
    Sleep    1s


Go To Categories Page
    Wait Until Element Is Visible    ${BTN_CATEGORIES}    20s
    Click Element    ${BTN_CATEGORIES}
    Log To Console    ▶️ เข้า Categories page แล้ว


Open Category Tab
    Wait Until Element Is Visible    ${BTN_CATEGORY_TAB}    20s
    Click Element    ${BTN_CATEGORY_TAB}
    Log To Console    ▶️ เปิดแท็บ Categories แล้ว


Select Category Merch
    Wait Until Element Is Visible    ${CATEGORY_ITEM_MERCH}    20s
    Click Element    ${CATEGORY_ITEM_MERCH}
    Log To Console    ▶️ เข้า Merch category แล้ว


Check Product Exists
    Wait Until Element Is Visible    ${PRODUCT_ROW_SIKKHIM}    20s
    Log To Console    👀 พบสินค้า sikkhim แล้ว


Select Product Checkbox
    Wait Until Element Is Visible    ${PRODUCT_CHECKBOX_SIKKHIM}    20s
    Click Element    ${PRODUCT_CHECKBOX_SIKKHIM}
    Sleep    500ms
    Log To Console    ☑️ เลือกสินค้า sikkhim แล้ว


Click Remove In Bar
    Wait Until Element Is Visible    ${BTN_REMOVE_BAR}    15s
    Click Element    ${BTN_REMOVE_BAR}
    Log To Console    🗑️ กด Remove แล้ว


Confirm Remove
    Wait Until Element Is Visible    ${BTN_CONFIRM_REMOVE}    10s
    Click Element    ${BTN_CONFIRM_REMOVE}
    Log To Console    ❗ ยืนยันลบสินค้าเรียบร้อย


Verify Removed
    Sleep    2s
    ${still}=    Run Keyword And Return Status    Page Should Contain Element    ${PRODUCT_ROW_SIKKHIM}
    IF    ${still}
        Fail    ❌ ลบไม่สำเร็จ: ยังเห็นสินค้าอยู่
    ELSE
        Log To Console    🎉 SUCCESS: สินค้า sikkhim ถูกลบออกแล้ว
    END


*** Test Cases ***

TC_Remove_Product_From_Merch
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Go To Products Page First
    Go To Categories Page
    Open Category Tab
    Select Category Merch
    Check Product Exists
    Select Product Checkbox
    Click Remove In Bar
    Confirm Remove
    Verify Removed
