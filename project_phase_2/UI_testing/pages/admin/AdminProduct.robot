*** Settings ***
Library    SeleniumLibrary
Resource   ..\..\pages\customer\CuctomerLogin.robot

*** Variables ***
# -------- Sidebar --------
${MENU_PRODUCTS}          xpath=//a[contains(@class,'flex') and normalize-space()='Products']

# -------- Product List --------
${PRODUCTS_TABLE}         xpath=//table[contains(@class,'text-ui-fg-subtle')]
${FIRST_PRODUCT_ROW}      xpath=(//tbody[contains(@class,'border-ui-border-base')]//tr)[1]

# -------- Product Detail: Variants Section --------
${VARIANTS_HEADER}        xpath=//*[normalize-space(.)='Variants']

# ปุ่ม ⋮ ใน section Variants
${VARIANT_OPTIONS_BTN}    xpath=//input[@placeholder='Search']/following::button[@aria-haspopup='menu'][1]

# -------- Dropdown Menu --------
${EDIT_PRICE_IN_MENU}     xpath=//span[normalize-space(.)='Edit prices']

# -------- Bulk Edit Price Editor (price EUR) --------
${PRICE_EUR_CELL}         xpath=//div[@data-container-id='0:2']
${PRICE_EUR_INPUT}        xpath=//input[@data-cell-id='0:2']

${SAVE_BTN}               xpath=//button[normalize-space()='Save']
${SUCCESS_TOAST}          xpath=//*[contains(.,'success') or contains(.,'updated')]



*** Keywords ***

Go To Products Page
    Wait Until Element Is Visible    ${MENU_PRODUCTS}    10s
    Click Element                    ${MENU_PRODUCTS}
    Wait Until Element Is Visible    ${PRODUCTS_TABLE}   10s
    Log To Console    เปิดหน้า Products สำเร็จ


Open First Product
    Wait Until Element Is Visible    ${FIRST_PRODUCT_ROW}    10s
    Click Element                    ${FIRST_PRODUCT_ROW}
    Sleep    1s
    Log To Console    เปิดสินค้าตัวแรกสำเร็จ


Scroll To Variant Section
    Log To Console    เริ่มเลื่อนหา Variants...

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
    Log To Console    เจอ Variants แล้ว!


Open Variants Menu
    Wait Until Element Is Visible    ${VARIANT_OPTIONS_BTN}    10s
    Scroll Element Into View         ${VARIANT_OPTIONS_BTN}
    Click Element                    ${VARIANT_OPTIONS_BTN}
    Wait Until Element Is Visible    ${EDIT_PRICE_IN_MENU}    10s
    Log To Console    เปิดเมนู Variants แล้ว


Click Edit Prices
    Wait Until Element Is Visible    ${EDIT_PRICE_IN_MENU}    10s
    Click Element                    ${EDIT_PRICE_IN_MENU}
    Sleep    1s
    Log To Console    เข้าโหมด Bulk Edit Prices แล้ว


Update Variant Price
    [Arguments]    ${NEW_PRICE}

    Log To Console    🔵 เริ่มแก้ราคา Price EUR...

    # 1) รอ cell โผล่ + scroll ให้เห็น
    Wait Until Element Is Visible    ${PRICE_EUR_CELL}    10s
    Scroll Element Into View         ${PRICE_EUR_CELL}
    Sleep    300ms

    # 2) Double Click cell เพื่อเปิด input (สำคัญที่สุด!)
    Double Click Element             ${PRICE_EUR_CELL}
    Sleep    500ms

    # 3) รอ input active (overlay จะหาย)
    Wait Until Element Is Visible    ${PRICE_EUR_INPUT}    10s
    Click Element                    ${PRICE_EUR_INPUT}
    Sleep    200ms

    # 4) เคลียร์ค่า
    Execute JavaScript    document.activeElement.value = "";
    Execute JavaScript    document.activeElement.dispatchEvent(new Event('input', { bubbles: true }));
    Sleep    200ms

    # 5) ใส่ราคาใหม่
    Press Keys    None    ${NEW_PRICE}
    Sleep    300ms

    # 6) Save
    Click Button    ${SAVE_BTN}
    Log To Console    💾 Save แล้ว...

    # 7) รอสำเร็จ
    Wait Until Page Contains Element    ${SUCCESS_TOAST}    15s
    Log To Console    ✅ อัปเดตราคา Price EUR เป็น ${NEW_PRICE} สำเร็จ!



Verify Product Price On Store Page
    [Arguments]    ${STORE_URL}    ${PRODUCT_NAME}    ${EXPECTED_PRICE}

    Log To Console     เปิดหน้า Store และเข้าสู่ระบบลูกค้า...
    Open Browser    ${STORE_URL}    chrome    alias=store
    Maximize Browser Window

    Wait Until Page Contains Element    xpath=//input[@name='email']    15s
    Input Text    xpath=//input[@name='email']       ${CUS_USER_HAM}
    Input Text    xpath=//input[@name='password']    ${CUS_PASS_HAM}

    Click Button    xpath=//button[normalize-space()='Sign in']
    Log To Console    Login Customer สำเร็จ

    Wait Until Page Contains Element    xpath=//h1[normalize-space()='All products']    20s

    Sleep    1s
    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class,'skeleton')]    10s

    Wait Until Page Contains Element    xpath=//*[contains(text(),'${PRODUCT_NAME}')]    20s

    ${price_xpath}=    Set Variable    //*[contains(text(),'${PRODUCT_NAME}')]/ancestor::*[3]//span[contains(.,'€')]

    Wait Until Page Contains Element    ${price_xpath}    10s

    ${actual_price}=    Get Text    ${price_xpath}

    Should Contain    ${actual_price}    ${EXPECTED_PRICE}
    Log To Console     ราคาแสดงถูกต้องบนหน้า Store หลัง Login!
