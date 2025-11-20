*** Settings ***
Documentation     FLOW 7: Product Update Synchronization
Library           SeleniumLibrary    timeout=10s    implicit_wait=0.3
Resource          ../../config/Env.robot
Resource          ../../pages/admin/AdminLogin.robot
Resource          ../../pages/admin/AdminProduct.robot
Suite Setup       Open Admin Browser
Suite Teardown    Close All Browsers

*** Variables ***
# ใช้ a class + ข้อความในลิงก์
${MENU_PRODUCTS}    xpath=//a[contains(@class,'flex') and normalize-space()='Products']
${PRODUCTS_HEADER}  xpath=//a[contains(@class,'flex') and contains(.,'Products')]
${PRODUCTS_TABLE}   xpath=//table[contains(@class,"text-ui-fg-subtle txt-compact-small relative w-full")]
${FIRST_PRODUCT_ROW}    xpath=(//tbody[contains(@class,'border-ui-border-base')]//tr)[1]

*** Keywords ***
Scroll To Variant Section
    [Documentation]    เลื่อนลงจนแน่ใจว่าเจอหัวข้อ Variants (แบบไม่ใช้ loop)
    Log To Console    🔽 เริ่มเลื่อนลงเพื่อหาหัวข้อ Variants

    ${scroll_js}=    Set Variable    const el=document.querySelector('div.overflow-auto'); if(el){el.scrollBy(0,800);} else {window.scrollBy(0,800);}

    # --- Scroll รอบที่ 1 ---
    Run Keyword And Ignore Error    Execute JavaScript    ${scroll_js}
    Sleep    1s
    ${found}=    Run Keyword And Return Status    Page Should Contain Element    xpath=//*[normalize-space(.)='Variants']

    # --- ถ้ายังไม่เจอ ลองเลื่อนต่อ ---
    Run Keyword Unless    ${found}    Execute JavaScript    ${scroll_js}
    Sleep    1s
    ${found}=    Run Keyword And Return Status    Page Should Contain Element    xpath=//*[normalize-space(.)='Variants']

    Run Keyword Unless    ${found}    Execute JavaScript    ${scroll_js}
    Sleep    1s
    ${found}=    Run Keyword And Return Status    Page Should Contain Element    xpath=//*[normalize-space(.)='Variants']

    # --- ทำซ้ำอีกได้ตามต้องการ (เพิ่มบรรทัด copy ได้เลย)
    # Run Keyword Unless    ${found}    Execute JavaScript    ${scroll_js}
    # Sleep    1s
    # ${found}=    Run Keyword And Return Status    Page Should Contain Element    xpath=//*[normalize-space(.)='Variants']

    Wait Until Page Contains Element    xpath=//*[normalize-space(.)='Variants']    10s
    Log To Console    👇 เจอส่วน Variants แล้วแน่นอน



Open First Product
    [Documentation]    เปิดสินค้าแถวแรกใน Product list
    Wait Until Element Is Visible    ${FIRST_PRODUCT_ROW}    10s
    Click Element                    ${FIRST_PRODUCT_ROW}
*** Test Cases ***
TC7.1 Admin Can Update Product Price
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Go To Products Page
    Open First Product
    Scroll To Variants Section
    Open Variants Menu
    Click Edit Prices
    Update Variant Price    99.00
    Log To Console    🍊 ราคาใหม่อัปเดตแล้ว

