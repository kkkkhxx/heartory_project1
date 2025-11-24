*** Settings ***
Library    SeleniumLibrary

*** Variables ***
# -------- Sidebar --------
${MENU_PRODUCTS}          xpath=//a[contains(@class,'flex') and normalize-space()='Products']



# -------- Product List --------
${PRODUCTS_TABLE}         xpath=//table[contains(@class,'text-ui-fg-subtle')]
${FIRST_PRODUCT_ROW}      xpath=(//tbody[contains(@class,'border-ui-border-base')]//tr)[1]

# -------- Product Detail: Variants Section --------
# ใช้ตัวนี้แทน เพราะ DOM ของคุณไม่มี <h2>Variants</h2>
${VARIANTS_HEADER}        xpath=//*[normalize-space(.)='Variants']

# ปุ่ม ⋮ ใน section Variants
${VARIANT_OPTIONS_BTN}    xpath=//input[@placeholder='Search']/following::button[@aria-haspopup='menu'][1]


# -------- Dropdown Menu --------
${EDIT_PRICE_IN_MENU}     xpath=//span[normalize-space(.)='Edit prices']

# -------- Bulk Edit Price Editor --------
${PRICE_FIRST_CELL}    xpath=(//div[contains(@class,'group/cell')])[1]
${PRICE_FIRST_INPUT}    xpath=//input[@type='text' and @data-field]
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
    Sleep    1s
    Log To Console    🧩 เปิดสินค้าตัวแรกสำเร็จ


Scroll To Variant Section
    Log To Console    🔽 เริ่มเลื่อนหา Variants...

    ${SCROLL_JS}=    Catenate    SEPARATOR=\n
    ...    const sc = document.querySelector('main.overflow-y-auto');
    ...    if (sc) { sc.scrollBy(0, 400); } else { window.scrollBy(0, 400); }

    FOR    ${i}    IN RANGE    1    12
        Execute JavaScript    ${SCROLL_JS}
        Sleep    300ms
        ${found}=    Run Keyword And Return Status    Element Should Be Visible    ${VARIANTS_HEADER}
        Exit For Loop If    ${found}
    END

    Wait Until Element Is Visible    ${VARIANTS_HEADER}    10s
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

    Log To Console    🎯 เริ่มแก้ราคา...

    Wait Until Element Is Visible    ${PRICE_FIRST_CELL}    10s
    Scroll Element Into View         ${PRICE_FIRST_CELL}
    Sleep    300ms

    # 1) คลิก + ดับเบิ้ลคลิกเพื่อ active cell
    Click Element         ${PRICE_FIRST_CELL}
    Double Click Element  ${PRICE_FIRST_CELL}
    Sleep    300ms

    # 2) ยิง JS เคลียร์ค่าใน cell
    Execute JavaScript    document.activeElement.value = "";
    Execute JavaScript    document.activeElement.dispatchEvent(new Event('input', { bubbles: true }));
    Sleep    300ms

    # 3) ใส่ค่าราคาใหม่
    Press Keys            None    ${NEW_PRICE}
    Sleep                 300ms

    # 4) Save
    Click Button          ${SAVE_BTN}
    Log To Console        💾 กด Save แล้ว...

    Wait Until Page Contains Element    ${SUCCESS_TOAST}    15s
    Log To Console        ✅ อัปเดตราคาเป็น ${NEW_PRICE} สำเร็จ!

Verify Product Price On Store Page
    [Arguments]    ${STORE_URL}    ${PRODUCT_NAME}    ${EXPECTED_PRICE}

    Log To Console    🌐 เปิดหน้า Store และเข้าสู่ระบบลูกค้า...
    Open Browser    ${STORE_URL}    chrome    alias=store
    Maximize Browser Window

    # ----------- Customer Login -------------
    Wait Until Page Contains Element    xpath=//input[@name='email']    15s
    Input Text    xpath=//input[@name='email']       ${CUSTOMER_EMAIL}
    Input Text    xpath=//input[@name='password']    ${CUSTOMER_PASSWORD}

    Click Button    xpath=//button[normalize-space()='Sign in']
    Log To Console   🔐 Login Customer สำเร็จ

    # ----------- Wait For Product Page ------------
    Wait Until Page Contains Element    xpath=//h1[normalize-space()='All products']    20s

    # รอ skeleton หาย
    Sleep    1s
    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class,'skeleton')]    10s

    # ----------- Find product card ------------
    Wait Until Page Contains Element    xpath=//*[contains(text(),'${PRODUCT_NAME}')]    20s

    ${price_xpath}=    Set Variable    //*[contains(text(),'${PRODUCT_NAME}')]/ancestor::*[3]//span[contains(.,'€')]

    Wait Until Page Contains Element    ${price_xpath}    10s

    ${actual_price}=    Get Text    ${price_xpath}
    Log To Console    🏷️ ราคาใน Store ปัจจุบันหลังเข้าระบบ: ${actual_price}

    Should Contain    ${actual_price}    ${EXPECTED_PRICE}
    Log To Console    🎉 ราคาแสดงถูกต้องบนหน้า Store หลัง Login!

