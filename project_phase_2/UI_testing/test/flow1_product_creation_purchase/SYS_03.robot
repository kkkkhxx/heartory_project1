*** Settings ***
Documentation     Automated UI Test for Flow 3: Customer cannot purchase out-of-stock product (SYS_03)
Library           SeleniumLibrary    run_on_failure=Capture Page Screenshot

Suite Setup       Open All Browsers
Suite Teardown    SeleniumLibrary.Close All Browsers


*** Variables ***
${ADMIN_LOGIN_URL}    http://10.34.112.158:9000/app/login
${ADMIN_URL}          http://10.34.112.158:9000/app/
${STORE_URL}          http://10.34.112.158:8000/dk/store

${ADMIN_USER}         group4@mu-store.local
${ADMIN_PASS}         Mp6!dzT3
${CUSTOMER_USER}      test@gmail.com
${CUSTOMER_PASS}      test123

${PRODUCT_NAME}       ICT Jersey


*** Test Cases ***
SYS_03 Customer Cannot Purchase Out Of Stock Product
    [Documentation]    ตรวจสอบว่าลูกค้าไม่สามารถเพิ่มสินค้าเข้าตะกร้าได้เมื่อสินค้าหมดสต็อก (แสดง Out of stock)
    Admin Login
    Configure Out Of Stock Inventory For Product
    Admin Logout
    Customer Sees Out Of Stock And Cannot Add To Cart
    Delete Product SYS_03


*** Keywords ***
Open All Browsers
    Open Browser    ${ADMIN_LOGIN_URL}    chrome
    Maximize Browser Window
    Set Selenium Speed    0.3s


# ----------------------- ADMIN LOGIN / LOGOUT -----------------------
Admin Login
    Log To Console    [SYS_03] Logging in as Admin...
    Go To    ${ADMIN_LOGIN_URL}
    Wait Until Element Is Visible    xpath=//input[@name='email']    20s
    Input Text    xpath=//input[@name='email']    ${ADMIN_USER}
    Input Text    xpath=//input[@name='password']    ${ADMIN_PASS}
    Click Button   xpath=//button[contains(.,'Continue with Email')]
    Wait Until Page Contains Element    xpath=//a[contains(.,'Products')]    30s
    Log To Console    [SYS_03] Admin logged in and dashboard visible.

Admin Logout
    Log To Console    [SYS_03] Logging out as Admin...
    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(.,'Logout') or contains(.,'Sign out')]
    Sleep    2s


# ----------------------- CONFIGURE INVENTORY = OUT OF STOCK -----------------------
Configure Out Of Stock Inventory For Product
    Log To Console    [SYS_03] Configure inventory item to Default variant qty=1...

    # ไปหน้า Products
    Click Element    xpath=//a[contains(.,'Products')]

    # หา product ในหลายหน้า (เผื่อไปอยู่หน้า 2 / 3)
    Search Product On Admin Product List    ${PRODUCT_NAME}

    # เจอแล้วค่อยกดเข้า edit product
    Click Element    xpath=//tr[.//a[contains(normalize-space(.),'${PRODUCT_NAME}')]]
    Wait Until Page Contains    Variants    20s

    # เข้า variant "Default variant"
    Log To Console    [SYS_03] Open Default variant row...
    Wait Until Element Is Visible
    ...    xpath=//tbody//tr[.//td[contains(normalize-space(.),'Default variant')]]
    ...    20s
    Click Element
    ...    xpath=//tbody//tr[.//td[contains(normalize-space(.),'Default variant')]]

    # รอหน้า Variant detail
    Wait Until Page Contains    Inventory items    20s

    # เปิดเมนูสามจุดของการ์ด Inventory items → Manage inventory items
    Log To Console    [SYS_03] Open Manage inventory items menu...
    Click Element
    ...    xpath=//h2[contains(.,'Inventory items')]/following::button[contains(@aria-haspopup,'menu')][1]

    Wait Until Element Is Visible
    ...    xpath=//div[@role='menu']//*[contains(normalize-space(.),'Manage inventory items')]
    ...    10s
    Click Element
    ...    xpath=//div[@role='menu']//*[contains(normalize-space(.),'Manage inventory items')]

    # ===== ใน popup Manage inventory items =====
    Log To Console    [SYS_03] Select 'Default variant' inventory item...

    # ให้ field โผล่ก่อน
    Wait Until Element Is Visible    xpath=//input[@name='inventory.0.required_quantity']    20s

    # เปิด dropdown "Item"
    Click Element    xpath=//input[@name='inventory.0.inventory_item_id']/parent::div
    Sleep    0.5s

    # เลือก option ที่มีคำว่า "Default variant"
    Wait Until Element Is Visible
    ...    xpath=//div[@role='listbox']//div[@role='option'][.//span[contains(normalize-space(.),'Default variant')]]
    ...    10s
    Click Element
    ...    xpath=//div[@role='listbox']//div[@role='option'][.//span[contains(normalize-space(.),'Default variant')]]
    Sleep    0.5s

    # ตั้ง Quantity = 1
    Log To Console    [SYS_03] Set required quantity = 1...
    Press Keys    xpath=//input[@name='inventory.0.required_quantity']    CTRL+A
    Press Keys    xpath=//input[@name='inventory.0.required_quantity']    BACKSPACE
    Input Text    xpath=//input[@name='inventory.0.required_quantity']    1

    # Save
    Click Button  xpath=//button[normalize-space()='Save']

    # กลับมาหน้า Variant detail
    Wait Until Page Contains    Inventory items    20s
    Log To Console    [SYS_03] Inventory item set to 'Default variant' with qty=1.


# ----------------------- CUSTOMER CHECKS OUT-OF-STOCK -----------------------
Customer Sees Out Of Stock And Cannot Add To Cart
    Log To Console    [SYS_03] Customer checks product out-of-stock...

    Go To    ${STORE_URL}

    # Login ลูกค้า
    Wait Until Element Is Visible    xpath=//a[contains(.,'Account')]    30s
    Click Element    xpath=//a[contains(.,'Account')]
    Wait Until Element Is Visible    xpath=//input[@name='email']    20s
    Input Text    xpath=//input[@name='email']    ${CUSTOMER_USER}
    Input Text    xpath=//input[@name='password']    ${CUSTOMER_PASS}
    Click Button   xpath=//button[contains(.,'Sign in')]
    Wait Until Page Contains    Overview    30s
    Log To Console    [SYS_03] Customer logged in.

    # ไปหน้า Store แล้วเข้า product
    Go To    ${STORE_URL}
    Wait Until Page Contains    ${PRODUCT_NAME}    30s
    Click Element    xpath=//a[contains(.,'${PRODUCT_NAME}')]

    # ต้องเห็น Out of stock
    Wait Until Page Contains    Out of stock    20s

    # ----- เช็คว่าลูกค้าซื้อไม่ได้ (2 เคส: มีปุ่มแต่ disabled หรือไม่มีปุ่มเลย) -----
    ${has_add_button}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//button[contains(.,'Add')]

    IF    ${has_add_button}
        Element Should Be Disabled    xpath=//button[contains(.,'Add')]
        Log To Console    [SYS_03] Add button is visible but disabled (cannot add to cart).
    ELSE
        Log To Console    [SYS_03] No Add button shown for out-of-stock product (cannot add to cart).
    END

    Log To Console    [SYS_03] Product is out of stock and customer cannot purchase.


# ----------------------- HELPER: SEARCH PRODUCT MULTI-PAGE -----------------------
Search Product On Admin Product List
    [Arguments]    ${PRODUCT_NAME}

    # ลูปเช็กได้สูงสุด 3 หน้า กันเผื่ออนาคต (ตอนนี้มี Prev / Next)
    FOR    ${idx}    IN RANGE    1    10
        Log To Console    [SYS_03] Check Admin Products page ${idx}...

        ${found}=    Run Keyword And Return Status
        ...    Page Should Contain Element
        ...    xpath=//tr[.//a[contains(normalize-space(.),'${PRODUCT_NAME}')]]

        IF    ${found}
            Log To Console    [SYS_03] Found product on Admin Products page ${idx}.
            RETURN
        END

        ${has_next}=    Run Keyword And Return Status
        ...    Page Should Contain Element
        ...    xpath=//button[normalize-space()='Next']

        IF    ${has_next}
            Log To Console    [SYS_03] Not found on page ${idx} → click Next...
            Click Element    xpath=//button[normalize-space()='Next']
            Sleep    1s
        ELSE
            Log To Console    [SYS_03] No Next button on page ${idx} → stop searching.
            BREAK
        END
    END

    Fail    [SYS_03] Product '${PRODUCT_NAME}' not found in first 3 pages of Products list.

Delete Product SYS_03
    [Documentation]    ลบสินค้า ${PRODUCT_NAME} จากหน้า Admin Products (ใช้เมนูสามจุดบนแถว)
    Log To Console    [SYS_03] Deleting product ${PRODUCT_NAME} from Admin Products list...

    # กลับไปหน้า Products
    Go To    ${ADMIN_URL}products
    Wait Until Page Contains    Products    20s

    # หา product บนหลายหน้า (ใช้ helper เดิม)
    Search Product On Admin Product List    ${PRODUCT_NAME}

    # เปิดเมนูสามจุดของแถวสินค้าที่ต้องการ
    Log To Console    [SYS_03] Open product action menu (3 dots) on list row...
    Wait Until Element Is Visible
    ...    xpath=//tr[.//a[contains(normalize-space(.),'${PRODUCT_NAME}')]]//button[contains(@aria-haspopup,'menu')][1]
    ...    10s
    Click Element
    ...    xpath=//tr[.//a[contains(normalize-space(.),'${PRODUCT_NAME}')]]//button[contains(@aria-haspopup,'menu')][1]

    # เลือกเมนู Delete
    Wait Until Element Is Visible
    ...    xpath=//div[@role='menu']//span[normalize-space()='Delete']
    ...    10s
    Click Element
    ...    xpath=//div[@role='menu']//span[normalize-space()='Delete']

    # ป๊อปอัปยืนยัน → กดปุ่ม Delete สีแดง
    Wait Until Element Is Visible
    ...    xpath=//button[normalize-space()='Delete']
    ...    10s
    Click Button
    ...    xpath=//button[normalize-space()='Delete']

    # กลับมาหน้า Products
    Wait Until Page Contains    Products    20s
    Log To Console    [SYS_03] Product ${PRODUCT_NAME} deleted (or expected to be deleted).
