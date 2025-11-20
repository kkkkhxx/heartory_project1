*** Settings ***
Library    SeleniumLibrary

*** Variables ***
# -------- Sidebar --------
${MENU_PRODUCTS}          xpath=//a[contains(@class,'flex') and normalize-space()='Products']

# -------- Product List --------
${PRODUCTS_TABLE}         xpath=//table[contains(@class,'text-ui-fg-subtle')]
${FIRST_PRODUCT_ROW}      xpath=(//tbody[contains(@class,'border-ui-border-base')]//tr)[1]

# -------- Product Detail: Variants Section --------
${VARIANT_HEADER}         xpath=//h2[normalize-space(.)='Variants']
${VARIANT_OPTIONS_BTN}    xpath=//section[.//h2[normalize-space(.)='Variants']]//button[@aria-haspopup='menu']

# -------- Dropdown Menu --------
${EDIT_PRICE_IN_MENU}     xpath=//span[normalize-space(.)='Edit prices']

# -------- Bulk Edit Price Editor --------
${PRICE_FIRST_INPUT}      xpath=(//input)[1]
${SAVE_BTN}               xpath=//button[normalize-space()='Save']
${SUCCESS_TOAST}          xpath=//*[contains(.,'success') or contains(.,'updated')]


*** Keywords ***

Go To Products Page
    Wait Until Element Is Visible    ${MENU_PRODUCTS}    10s
    Click Element                    ${MENU_PRODUCTS}
    Wait Until Element Is Visible    ${PRODUCTS_TABLE}   10s
    Log To Console    🏷️ เปิดหน้า Products สำเร็จ


Open First Product
    Wait Until Element Is Visible    ${FIRST_PRODUCT_ROW}    10s
    Click Element                    ${FIRST_PRODUCT_ROW}
    Sleep    2s
    Log To Console    🧩 เปิดสินค้าตัวแรกสำเร็จ


Scroll To Variant Section
    [Documentation]    Scroll ใน scroll-container <main overflow-y-auto> ของ Medusa Admin
    Log To Console    🔽 เริ่มเลื่อนหา Variants

${SCROLL_JS}=    Catenate    SEPARATOR=\n
...    const sc = document.querySelector('main.overflow-y-auto');
...    if (sc) { sc.scrollBy(0, 900); } else { window.scrollBy(0, 900); }

    FOR    ${i}    IN RANGE    1    12
        Execute JavaScript    ${SCROLL_JS}
        Sleep    600ms
        ${found}=    Run Keyword And Return Status    Page Should Contain Element    ${VARIANT_HEADER}
        Exit For Loop If    ${found}
    END

    Wait Until Page Contains Element    ${VARIANT_HEADER}    10s
    Log To Console    👇 เจอ Variants แล้ว!


Open Variants Menu
    Wait Until Element Is Visible    ${VARIANT_OPTIONS_BTN}    10s
    Scroll Element Into View         ${VARIANT_OPTIONS_BTN}
    Click Element                    ${VARIANT_OPTIONS_BTN}
    Wait Until Element Is Visible    ${EDIT_PRICE_IN_MENU}    10s
    Log To Console    ⚙️ เปิดเมนู Variants แล้ว


Click Edit Prices
    Wait Until Element Is Visible    ${EDIT_PRICE_IN_MENU}    10s
    Click Element                    ${EDIT_PRICE_IN_MENU}
    Sleep    1s
    Log To Console    ✏️ เข้าโหมด Bulk Edit Prices แล้ว


Update Variant Price
    [Arguments]    ${NEW_PRICE}
    Wait Until Element Is Visible    ${PRICE_FIRST_INPUT}    10s
    Clear Element Text               ${PRICE_FIRST_INPUT}
    Input Text                       ${PRICE_FIRST_INPUT}    ${NEW_PRICE}
    Click Button                     ${SAVE_BTN}
    Wait Until Page Contains Element    ${SUCCESS_TOAST}    15s
    Log To Console                   💰 ราคาแก้เป็น ${NEW_PRICE} สำเร็จ
