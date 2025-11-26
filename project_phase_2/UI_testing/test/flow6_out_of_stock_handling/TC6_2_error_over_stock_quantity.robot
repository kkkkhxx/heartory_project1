*** Settings ***
Documentation     TC6_2 – Error: ลูกค้าซื้อเกินจำนวน stock → ระบบต้องปฏิเสธและแสดงข้อความผิดพลาดที่หน้า Cart
...               Flow:
...               1) Admin login → ไปหน้า Products → เปิดสินค้า ${PRODUCT_NAME} → เข้า Inventory item → อ่าน Available ของ ${LOCATION_NAME}
...               2) คำนวณจำนวนที่จะซื้อ = Available + 1 (ให้เกิน stock)
...               3) Customer (eatburger) login → เลือกสินค้า → ใส่จำนวนเกิน → ที่หน้า Cart ต้องแสดง error ว่า inventory ไม่พอ
...               4) ห้ามมีหน้าสั่งซื้อสำเร็จ (Thank you)
Library           SeleniumLibrary    run_on_failure=Capture Page Screenshot

Suite Setup       Open All BrowsERS
Suite Teardown    Close All BrowsERS


*** Variables ***
# ===== Product / Location =====
${PRODUCT_NAME}             dolly2
${LOCATION_NAME}            Sweden Warehouse

# ===== Admin / Store URLs =====
${ADMIN_LOGIN_URL}          http://10.34.112.158:9000/app/login
${ADMIN_BASE_URL}           http://10.34.112.158:9000/app/
${STORE_HOME_URL}           http://10.34.112.158:8000/dk
${STORE_STORE_URL}          http://10.34.112.158:8000/dk/store

# ===== Credentials =====
${ADMIN_USER}               group4@mu-store.local
${ADMIN_PASS}               Mp6!dzT3

${CUSTOMER_EMAIL}           eatburger@example.com
${CUSTOMER_PASSWORD}        1234

# ===== Admin – เมนูสินค้า / สินค้า =====
${ADMIN_MENU_PRODUCTS}      xpath=//a[contains(normalize-space(.),'Products')]
${ADMIN_BTN_NEXT}           xpath=(//button[normalize-space(.)='Next'])[last()]

${ADMIN_VARIANT_INVENTORY_CELL}    xpath=//tbody//tr[1]//span[contains(normalize-space(.),'available at')]
${ADMIN_INVENTORY_ITEM_ROW_LINK}   xpath=(//table//tbody//tr[1]//a[@data-row-link='true'])[1]

# ===== Storefront / Customer – Login / Product =====
${BTN_ACCOUNT_OR_LOGIN}             xpath=//a[contains(.,'Account') or contains(.,'Sign in') or contains(.,'Log in')] | //button[contains(.,'Account') or contains(.,'Sign in') or contains(.,'Log in')]
${LOGIN_EMAIL_INPUT}                css=input[name="email"]
${LOGIN_PASSWORD_INPUT}             css=input[type="password"]
${LOGIN_SUBMIT_BTN}                 xpath=//button[normalize-space(.)='Continue'] | //button[contains(normalize-space(.),'Sign in')]

${CARD_PRODUCT}                     xpath=//p[@data-testid='product-title' and normalize-space(.)='${PRODUCT_NAME}']/ancestor::a[1]

# Cart quantity (เป็น select เท่านั้น)
${QTY_SELECT}                       css=select[data-testid="product-select-button"]

${BTN_ADD_TO_CART}                  xpath=//button[contains(normalize-space(.),'Add to cart') or contains(normalize-space(.),'Add')]
${BTN_OPEN_CART}                    xpath=//a[@data-testid='nav-cart-link' or @data-testid='cart-link']
${BTN_CHECKOUT}                     xpath=//button[contains(normalize-space(.),'Go to checkout')]

# ===== Checkout – Shipping Address / Delivery / Payment =====
${BTN_EDIT_SHIPPING_ADDRESS}        xpath=(//button[normalize-space(.)='Edit'])[1]
${BTN_SUBMIT_ADDRESS}               xpath=//button[@data-testid='submit-address-button']

${INPUT_FIRST_NAME}                 xpath=//input[contains(@name,'first_name')]
${INPUT_LAST_NAME}                  xpath=//input[contains(@name,'last_name')]
${INPUT_ADDRESS_1}                  xpath=//input[@name='shipping_address.address_1']
${INPUT_CITY}                       xpath=//input[contains(@name,'city')]
${INPUT_POSTAL_CODE}                xpath=//input[contains(@name,'postal')]
${INPUT_PHONE}                      xpath=//input[contains(@name,'phone')]
${SELECT_COUNTRY}                   xpath=//select[contains(@name,'country') or contains(@id,'country')]

# Shipping options
${SHIPPING_OPTION_IN_AREA}          xpath=//span[@data-testid='delivery-option-radio'][.//span[contains(normalize-space(.),'ในพื้นที่')]]//button[@data-testid='radio-button']
${BTN_CONTINUE_TO_PAYMENT}          xpath=//button[@data-testid='submit-delivery-option-button']

# Payment
${MANUAL_PAYMENT_RADIO}             xpath=//div[@role='radiogroup']//button[@data-testid='radio-button']
${BTN_CONTINUE_TO_REVIEW}           xpath=//button[@data-testid='submit-payment-button']

# Place order
${BTN_PLACE_ORDER}                  xpath=//button[@data-testid='submit-order-button']
${ORDER_SUCCESS_TEXT}               Thank you

# ===== Error Message =====
${OUT_OF_STOCK_ERROR}               Error setting up the request: Some variant does not have the required inventory


*** Test Cases ***
TC6_2_Error_Quantity_Exceeds_Available_Stock
    [Documentation]    ลูกค้าพยายามซื้อเกินจำนวน Available ของ ${LOCATION_NAME} → ระบบต้องขึ้น error ที่หน้า Cart และไม่สั่งซื้อสำเร็จ
    # ----- Admin อ่าน stock ก่อน -----
    Admin Login
    ${available_before}=    Admin Get Product Stock    ${PRODUCT_NAME}    ${LOCATION_NAME}
    Log To Console          Available ปัจจุบัน (${LOCATION_NAME}) = ${available_before}
    Should Be True          ${available_before} > 0

    # ตั้งจำนวนที่จะซื้อให้ "เกิน" stock
    ${qty_to_buy}=    Evaluate    ${available_before} + 1
    Log To Console    จะลองซื้อจำนวน ${qty_to_buy} ชิ้น (เกินจาก Available)

    # ----- Customer ลองซื้อเกิน stock -----
    Customer Login As Eatburger
    Customer Try Buy More Than Available Should Fail    ${PRODUCT_NAME}    ${qty_to_buy}    ${OUT_OF_STOCK_ERROR}


*** Keywords ***
# ======================= COMMON =======================
Open All BrowsERS
    Open Browser    about:blank    chrome
    Maximize Browser Window
    Set Selenium Timeout  25s
    Set Selenium Speed    0.3s

Scroll And Click Element
    [Arguments]    ${locator}
    Wait Until Element Is Visible    ${locator}    20s
    Scroll Element Into View         ${locator}
    Sleep    0.5s
    Click Element                    ${locator}

Click Element With Retry
    [Arguments]    ${locator}
    Wait Until Keyword Succeeds    3x    2s    Scroll And Click Element    ${locator}

Wait Until Store Products Loaded
    [Documentation]    รอให้ skeleton หาย เพื่อให้การ์ดสินค้าขึ้นครบ
    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class,'skeleton')]    30s
    Sleep    1s

Search Product In Current Page
    [Documentation]    หา product ตามชื่อในหน้าปัจจุบัน ถ้าเจอจะ Scroll + Click แล้ว return True
    [Arguments]    ${product_name}
    ${product_locator}=    Set Variable
    ...    xpath=//p[@data-testid='product-title' and normalize-space(.)='${product_name}']/ancestor::a[1]

    ${found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${product_locator}    5s

    IF    ${found}
        Log To Console    Found product ${product_name} in current page
        Scroll Element Into View    ${product_locator}
        Sleep    0.5s
        Click Element With Retry    ${product_locator}
        Sleep    1s
        RETURN    True
    END

    Log To Console    ${product_name} not found in current page
    RETURN    False

Customer Open Product In Store With Pagination
    [Documentation]    เปิดหน้าร้าน แล้วไล่ page 1..max_pages หา product ตามชื่อ ถ้าเจอจะกดเข้า product
    [Arguments]    ${product_name}
    Go To    ${STORE_STORE_URL}
    Wait Until Page Contains Element    xpath=//h1[@data-testid='store-page-title']
    Wait Until Store Products Loaded

    ${current_page}=    Set Variable    1
    ${max_pages}=       Set Variable    6

    ${found}=    Search Product In Current Page    ${product_name}
    IF    ${found}
        RETURN
    END

    WHILE    ${current_page} < ${max_pages}
        ${next_page}=    Evaluate    ${current_page} + 1
        Log To Console    Trying page ${next_page} for product ${product_name}...
        ${next_btn_locator}=    Set Variable
        ...    xpath=//button[normalize-space()='${next_page}']

        ${next_exists}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${next_btn_locator}    5s

        IF    not ${next_exists}
            Fail    Cannot find pagination button for page ${next_page}. Product ${product_name} not found.
        END

        Click Element With Retry    ${next_btn_locator}
        Sleep    1s
        Wait Until Store Products Loaded

        ${found}=    Search Product In Current Page    ${product_name}
        IF    ${found}
            RETURN
        END

        ${current_page}=    Set Variable    ${next_page}
    END

    Fail    Product ${product_name} not found in any Store page (1..${max_pages})


# ======================= ADMIN =======================
Admin Login
    Go To    ${ADMIN_LOGIN_URL}
    Wait Until Element Is Visible    xpath=//input[@name='email']    20s
    Input Text    xpath=//input[@name='email']    ${ADMIN_USER}
    Input Text    xpath=//input[@name='password']    ${ADMIN_PASS}
    Click Button   xpath=//button[contains(.,'Continue with Email')]
    Wait Until Page Contains Element    ${ADMIN_MENU_PRODUCTS}    30s

Admin Go To Products Page
    Click Element    ${ADMIN_MENU_PRODUCTS}
    Wait Until Location Contains    /products    20s
    Sleep    2s

Admin Open Product Detail
    [Arguments]    ${product_name}
    Admin Go To Products Page

    ${product_locator}=    Set Variable
    ...    xpath=//span[normalize-space(.)='${product_name}']/ancestor::a[@data-row-link='true'][1]

    FOR    ${i}    IN RANGE    10
        ${found}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${product_locator}    3s

        IF    ${found}
            Scroll Element Into View    ${product_locator}
            Click Element With Retry    ${product_locator}
            Wait Until Page Contains Element    xpath=//h1[contains(normalize-space(.),'${product_name}')]
            Exit For Loop
        END

        ${has_next}=    Run Keyword And Return Status
        ...    Page Should Contain Element    ${ADMIN_BTN_NEXT}

        IF    not ${has_next}
            Fail    Product '${product_name}' not found in any Products page (no Next button).
        END

        ${is_disabled}=    Run Keyword And Return Status
        ...    Element Should Be Disabled    ${ADMIN_BTN_NEXT}

        IF    ${is_disabled}
            Fail    Product '${product_name}' not found in any Products page (Next disabled on last page).
        END

        Click Element With Retry    ${ADMIN_BTN_NEXT}
        Sleep    0.8s
    END

Admin Open Inventory Item Detail
    [Arguments]    ${product_name}
    Admin Open Product Detail    ${product_name}

    Wait Until Element Is Visible    ${ADMIN_VARIANT_INVENTORY_CELL}    15s
    Scroll Element Into View         ${ADMIN_VARIANT_INVENTORY_CELL}
    Click Element With Retry         ${ADMIN_VARIANT_INVENTORY_CELL}

    Wait Until Element Is Visible    ${ADMIN_INVENTORY_ITEM_ROW_LINK}    15s
    Scroll Element Into View         ${ADMIN_INVENTORY_ITEM_ROW_LINK}
    Click Element With Retry         ${ADMIN_INVENTORY_ITEM_ROW_LINK}

    # แค่เช็คว่าเข้าหน้า Inventory Item แล้วมีหัวข้อ Locations ก็พอ
    Wait Until Page Contains Element    xpath=//h1[contains(normalize-space(.),'Details')]    15s
    Wait Until Page Contains Element    xpath=//h1[normalize-space(.)='Locations']          15s

Admin Get Product Stock
    [Arguments]    ${product_name}    ${location_name}=${LOCATION_NAME}
    # เปิดไปหน้า Inventory item detail ของ product นั้นก่อน
    Admin Open Inventory Item Detail    ${product_name}

    # ดึงค่า "Available" (คอลัมน์ที่ 4) ของแถว location_name
    ${stock_cell_locator}=    Set Variable
    ...    xpath=//table[.//th[normalize-space(.)='Location']]//tbody//tr[.//span[normalize-space(.)='${location_name}']]//td[4]//span

    Wait Until Element Is Visible    ${stock_cell_locator}    25s
    Scroll Element Into View         ${stock_cell_locator}
    ${text}=    Get Text             ${stock_cell_locator}
    ${stock}=   Convert To Integer   ${text}
    RETURN    ${stock}


# ======================= CUSTOMER =======================
Customer Login As Eatburger
    Go To    ${STORE_HOME_URL}
    Wait Until Element Is Visible    ${BTN_ACCOUNT_OR_LOGIN}
    Click Element With Retry         ${BTN_ACCOUNT_OR_LOGIN}
    Wait Until Element Is Visible    ${LOGIN_EMAIL_INPUT}
    Input Text       ${LOGIN_EMAIL_INPUT}       ${CUSTOMER_EMAIL}
    Input Text       ${LOGIN_PASSWORD_INPUT}    ${CUSTOMER_PASSWORD}
    Click Element With Retry         ${LOGIN_SUBMIT_BTN}
    Sleep    1.5s

Set Cart Quantity
    [Arguments]    ${qty}
    Wait Until Element Is Visible    ${QTY_SELECT}    10s
    Select From List By Value        ${QTY_SELECT}    ${qty}
    Sleep    1s

Fill Or Edit Shipping Address Country
    [Arguments]    ${country}
    ${has_edit}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${BTN_EDIT_SHIPPING_ADDRESS}    4s
    Run Keyword If    ${has_edit}    Click Element With Retry    ${BTN_EDIT_SHIPPING_ADDRESS}

    Wait Until Element Is Visible    ${INPUT_FIRST_NAME}
    Clear Element Text    ${INPUT_FIRST_NAME}
    Input Text            ${INPUT_FIRST_NAME}    test
    Clear Element Text    ${INPUT_LAST_NAME}
    Input Text            ${INPUT_LAST_NAME}     test
    Clear Element Text    ${INPUT_ADDRESS_1}
    Input Text            ${INPUT_ADDRESS_1}     MU
    Clear Element Text    ${INPUT_CITY}
    Input Text            ${INPUT_CITY}          Salaya
    Clear Element Text    ${INPUT_POSTAL_CODE}
    Input Text            ${INPUT_POSTAL_CODE}   12345

    Run Keyword And Ignore Error    Clear Element Text    ${INPUT_PHONE}
    Run Keyword And Ignore Error    Input Text            ${INPUT_PHONE}    0123456789

    Select From List By Label       ${SELECT_COUNTRY}    ${country}
    Click Element With Retry        ${BTN_SUBMIT_ADDRESS}
    Sleep    1.5s


Customer Try Buy More Than Available Should Fail
    [Documentation]    ลูกค้าพยายามเพิ่มจำนวนใน Cart ให้เกิน stock → ต้องขึ้น error message และห้ามมี Thank you
    [Arguments]    ${product_name}    ${qty}    ${error_message}

    # 1) หา product ด้วย pagination แล้วเข้า product detail
    Customer Open Product In Store With Pagination    ${product_name}

    # 2) Add to cart ด้วยจำนวน default (1)
    Wait Until Element Is Visible    ${BTN_ADD_TO_CART}
    Click Element With Retry         ${BTN_ADD_TO_CART}
    Sleep    1s

    # 3) เปิด cart → เช็คจากว่ามี dropdown จำนวน
    Click Element With Retry         ${BTN_OPEN_CART}
    Wait Until Element Is Visible    ${QTY_SELECT}    20s

    # 4) เปลี่ยน quantity ให้เกิน stock
    Set Cart Quantity                ${qty}

    # 5) ตรวจสอบ error message ใต้สินค้า
    Wait Until Element Is Visible    xpath=//div[@data-testid='product-error-message']//span    20s
    ${msg}=    Get Text    xpath=//div[@data-testid='product-error-message']//span
    Should Contain    ${msg}    ${error_message}

    # 6) ไม่ควรมีหน้า Thank you โผล่มา
    Run Keyword And Ignore Error    Page Should Not Contain    ${ORDER_SUCCE}