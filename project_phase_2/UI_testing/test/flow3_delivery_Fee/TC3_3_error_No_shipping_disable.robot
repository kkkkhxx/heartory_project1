*** Settings ***
Documentation     TC3.3 – Disable Shipping Area (In Service) แล้ว Customer ยังเห็นค่าจัดส่งในพื้นที่/นอกพื้นที่อยู่หรือไม่
...               Flow (ตามโจทย์):
...               1) Customer (eatburger) login → เลือกสินค้า dolly → Add to cart → ไป cart → Go to checkout
...                  - เลือกประเทศ Sweden → เห็น "ในพื้นที่"
...                  - เลือกประเทศ Germany → เห็น "นอกพื้นที่"
...               2) Admin login → เข้า Sweden Warehouse → Shipping → กด Disable (หัวข้อ Shipping > ... > Disable > ยืนยัน Disable)
...               3) Customer (คนเดิม) → เลือกสินค้า dolly → Checkout → เลือก Sweden อีกครั้ง
...                  - Expected: ไม่ควรมีคำว่า "ในพื้นที่" / "นอกพื้นที่" ถ้ายังเห็น แปลว่า Disable ไม่ทำงาน (BUG)
Library           SeleniumLibrary    run_on_failure=Capture Page Screenshot

Suite Setup       Open All Browsers
Suite Teardown    Close All Browsers


*** Variables ***
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

# ===== Admin – Locations & Shipping (list page) =====
${ADMIN_MENU_SETTINGS}              xpath=//a[contains(normalize-space(.),'Settings')]
${ADMIN_MENU_LOCATIONS_SHIPPING}    xpath=//a[contains(normalize-space(.),'Locations & Shipping')]

# ปุ่ม View details ของ Sweden Warehouse บนหน้า Locations & Shipping
${SWEDEN_WAREHOUSE_VIEW_DETAILS}    xpath=//p[normalize-space(.)='Sweden Warehouse']/ancestor::div[contains(@class,'shadow-elevation-card-rest')][1]//a[normalize-space(.)='View details']

# ===== Admin – Sweden Warehouse detail (Shipping header Disable) =====
# ปุ่มเมนู … ที่หัวข้อ Shipping (ขวาบน)
${BTN_SHIPPING_HEADER_MENU}    xpath=//h2[normalize-space(.)='Shipping']/ancestor::div[contains(@class,'items-center justify-between')][1]//button[@aria-haspopup='menu']

# เมนู Disable ใน dropdown (หัวข้อ Shipping)
${MENUITEM_SHIPPING_DISABLE}  xpath=//div[@role='menu']//span[normalize-space(.)='Disable']/ancestor::div[@role='menuitem'][1]

# ปุ่ม Disable สีแดงใน modal ยืนยัน
${MODAL_DISABLE_BTN}          xpath=//div[contains(@class,'flex items-center justify-end')]//button[normalize-space(.)='Disable' and contains(@class,'button-danger')]

# ===== Storefront / User side =====
# Account / Login
${BTN_ACCOUNT_OR_LOGIN}             xpath=//a[contains(.,'Account') or contains(.,'Sign in') or contains(.,'Log in')] | //button[contains(.,'Account') or contains(.,'Sign in') or contains(.,'Log in')]
${LOGIN_EMAIL_INPUT}                css=input[name="email"]
${LOGIN_PASSWORD_INPUT}             css=input[type="password"]
${LOGIN_SUBMIT_BTN}                 xpath=//button[normalize-space(.)='Continue'] | //button[contains(normalize-space(.),'Sign in')]

# Product list / dolly card
${CARD_PRODUCT_DOLLY}               xpath=//p[@data-testid='product-title' and normalize-space(.)='dolly']/ancestor::a[1]

# ปุ่ม Add to cart บนหน้า product detail (ใช้ text-based ให้ชัวร์)
${BTN_ADD_TO_CART}                  xpath=//button[contains(normalize-space(.),'Add') or contains(normalize-space(.),'Add to cart')]

# Cart & checkout
${BTN_OPEN_CART}                    css=a[data-testid="nav-cart-link"]

# Shipping address form
${INPUT_FIRST_NAME}                 xpath=//input[contains(@name,'first_name')]
${INPUT_LAST_NAME}                  xpath=//input[contains(@name,'last_name')]
${INPUT_ADDRESS_1}                  xpath=//input[@name='shipping_address.address_1']
${INPUT_CITY}                       xpath=//input[contains(@name,'city')]
${INPUT_POSTAL_CODE}                xpath=//input[contains(@name,'postal')]
${INPUT_PHONE}                      xpath=//input[contains(@name,'phone')]
${SELECT_COUNTRY}                   xpath=//select[contains(@name,'country') or contains(@id,'country')]

# ปุ่ม continue จาก address → delivery
${BTN_SUBMIT_ADDRESS}               xpath=//button[@data-testid='submit-address-button']

# Shipping address summary + Edit
${BTN_EDIT_SHIPPING_ADDRESS}        xpath=(//button[normalize-space(.)='Edit'])[1]

# ใช้ดึง text ทั้งหน้า delivery / payment / review
${PAGE_BODY}                        xpath=//body


*** Test Cases ***
TC3_2_Error_No_Shipping_After_Disable
    [Documentation]    Customer → Admin Disable → Customer:
    ...                1) Customer เช็ค Sweden/Germany ก่อน (เห็น ในพื้นที่/นอกพื้นที่)
    ...                2) Admin Disable Shipping ที่ Sweden Warehouse (หัวข้อ Shipping)
    ...                3) Customer กลับมาดู Sweden อีกรอบ → ไม่ควรเห็น ในพื้นที่/นอกพื้นที่
    ...                ถ้ายังเห็น แปลว่า Disable ไม่ทำงาน → เทสต์นี้ FAIL = พบ BUG
    # ----- Step 1: Customer เช็คก่อน Disable -----
    Customer Login As Eatburger
    Customer Start Checkout With Dolly

    # Sweden ก่อน Disable → ต้องมี "ในพื้นที่"
    Fill Or Edit Shipping Address Country    Sweden
    ${before_sweden}=    Get DeliveryPage Text
    Log To Console    BEFORE DISABLE (Sweden): ${before_sweden}
    Should Contain    ${before_sweden}    ในพื้นที่

    # Germany ก่อน Disable → ต้องมี "นอกพื้นที่"
    Fill Or Edit Shipping Address Country    Germany
    ${before_germany}=    Get DeliveryPage Text
    Log To Console    BEFORE DISABLE (Germany): ${before_germany}
    Should Contain    ${before_germany}    นอกพื้นที่

    # ----- Step 2: Admin Disable Shipping -----
    Admin Login
    Admin Go To Sweden Warehouse
    Admin Disable Shipping From Header

    # ----- Step 3: Customer เช็คหลัง Disable (Sweden) -----
    # กลับไปฝั่ง Store อีกครั้ง (ใช้ cart เดิม → ตอนนี้อาจมี 2 ชิ้นได้ ไม่เป็นไร)
    Go To    ${STORE_STORE_URL}
    Customer Start Checkout With Dolly

    Fill Or Edit Shipping Address Country    Sweden
    ${after_sweden}=    Get DeliveryPage Text
    Log To Console    AFTER DISABLE (Sweden): ${after_sweden}

    # Expected ของ TC3.2: หลัง Disable แล้วไม่ควรเห็น ในพื้นที่/นอกพื้นที่
    Should Not Contain    ${after_sweden}    ในพื้นที่
    Should Not Contain    ${after_sweden}    นอกพื้นที่


*** Keywords ***
# ======================= COMMON / HELPER =======================
Open All Browsers
    Open Browser    about:blank    chrome
    Maximize Browser Window
    Set Selenium Speed    0.3s
    Set Selenium Timeout  20s

Click Element With Retry
    [Arguments]    ${locator}
    Wait Until Keyword Succeeds    3x    2s    Click Element    ${locator}

Click Checkout Button
    [Documentation]    คลิกปุ่มไปหน้า checkout:
    ...                1) ใช้ data-testid="checkout-button" (บน <a> หรือ <button>)
    ...                2) ถ้าไม่เจอ ใช้ fallback หา /checkout หรือปุ่มที่มี text Checkout / Go to checkout
    ${has_testid}=    Run Keyword And Return Status    Wait Until Element Is Visible    css=[data-testid="checkout-button"]    10s
    IF    ${has_testid}
        Scroll Element Into View    css=[data-testid="checkout-button"]
        Click Element With Retry    css=[data-testid="checkout-button"]
        RETURN
    END

    ${CHECKOUT_LOCATOR}=    Set Variable    xpath=( //a[contains(@href,'/checkout')]
    ...                                           | //button[contains(normalize-space(.),'Checkout') or contains(normalize-space(.),'Go to checkout')] )

    Wait Until Element Is Visible    ${CHECKOUT_LOCATOR}    20s
    Scroll Element Into View          ${CHECKOUT_LOCATOR}
    Click Element With Retry          ${CHECKOUT_LOCATOR}


# ======================= ADMIN PART =======================
Admin Login
    Log To Console     Logging in as Admin...
    Go To    ${ADMIN_LOGIN_URL}
    Wait Until Element Is Visible    xpath=//input[@name='email']    20s
    Input Text    xpath=//input[@name='email']       ${ADMIN_USER}
    Input Text    xpath=//input[@name='password']    ${ADMIN_PASS}
    Click Button   xpath=//button[contains(.,'Continue with Email')]
    Wait Until Page Contains Element    ${ADMIN_MENU_SETTINGS}    30s
    Log To Console    Admin logged in.

Admin Go To Sweden Warehouse
    [Documentation]    จาก admin dashboard เข้า Settings → Locations & Shipping → Sweden Warehouse
    Click Element    ${ADMIN_MENU_SETTINGS}
    Wait Until Element Is Visible    ${ADMIN_MENU_LOCATIONS_SHIPPING}    20s
    Click Element    ${ADMIN_MENU_LOCATIONS_SHIPPING}
    Wait Until Element Is Visible    ${SWEDEN_WAREHOUSE_VIEW_DETAILS}    20s
    Click Element    ${SWEDEN_WAREHOUSE_VIEW_DETAILS}
    Wait Until Page Contains Element    xpath=//h1[normalize-space(.)='Sweden Warehouse']    20s

Admin Disable Shipping From Header
    [Documentation]    ที่หน้า Sweden Warehouse → หัวข้อ Shipping:
    ...                - กดปุ่ม ... ขวาบน
    ...                - เลือกเมนู Disable
    ...                - ใน modal กดปุ่ม Disable สีแดงเพื่อยืนยัน
    Wait Until Page Contains Element    xpath=//h2[normalize-space(.)='Shipping']    20s

    # เปิดเมนู …
    Wait Until Element Is Visible    ${BTN_SHIPPING_HEADER_MENU}    20s
    Click Element With Retry         ${BTN_SHIPPING_HEADER_MENU}

    # คลิกเมนู Disable
    Wait Until Element Is Visible    ${MENUITEM_SHIPPING_DISABLE}    10s
    Click Element With Retry         ${MENUITEM_SHIPPING_DISABLE}

    # รอ modal ขึ้น แล้วกดปุ่ม Disable สีแดง
    Wait Until Element Is Visible    ${MODAL_DISABLE_BTN}    10s
    Click Element With Retry         ${MODAL_DISABLE_BTN}

    # รอให้สถานะเปลี่ยน (จาก Enabled → Disabled หรือเมนูหาย)
    Sleep    2s
    Run Keyword And Ignore Error    Wait Until Page Contains    Disabled    10s
    Log To Console    In-service shipping disabled from Shipping header.


# ======================= CUSTOMER / STORE PART =======================
Customer Login As Eatburger
    [Documentation]    เปิดหน้า home แล้ว login ด้วย eatburger@example.com / 1234
    Go To    ${STORE_HOME_URL}
    Wait Until Page Contains Element    ${BTN_ACCOUNT_OR_LOGIN}    30s
    Click Element With Retry             ${BTN_ACCOUNT_OR_LOGIN}
    Sleep    1s
    Wait Until Page Contains Element    ${LOGIN_EMAIL_INPUT}    30s
    Input Text       ${LOGIN_EMAIL_INPUT}       ${CUSTOMER_EMAIL}
    Input Text       ${LOGIN_PASSWORD_INPUT}    ${CUSTOMER_PASSWORD}
    Click Button     ${LOGIN_SUBMIT_BTN}
    Sleep    2s
    Log To Console   Customer logged in as ${CUSTOMER_EMAIL}.

Customer Start Checkout With Dolly
    [Documentation]    ไปหน้า store → หา product dolly (วนทุกหน้า pagination) → Add to cart → เปิด cart → กด Go to checkout
    Go To    ${STORE_STORE_URL}

    # ยืนยันว่าอยู่หน้า All products
    Wait Until Page Contains Element    xpath=//h1[@data-testid='store-page-title' and normalize-space(.)='All products']    20s

    # ===== นับจำนวนหน้า pagination ทั้งหมด =====
    ${page_buttons}=    Get WebElements    xpath=//div[@data-testid='product-pagination']//button[contains(@class,'txt-xlarge-plus')]
    ${total_pages}=     Get Length        ${page_buttons}
    Log To Console      Total pages found: ${total_pages}

    # ===== วนทุกหน้าเพื่อตามหา dolly =====
    FOR    ${idx}    IN RANGE    ${total_pages}
        ${found}=    Run Keyword And Return Status
        ...    Wait Until Page Contains Element    ${CARD_PRODUCT_DOLLY}    5s
        IF    ${found}
            Log To Console    Found dolly on page index ${idx}
            Click Element With Retry    ${CARD_PRODUCT_DOLLY}
            Exit For Loop
        END

        # ถ้ายังไม่เจอ และยังมีหน้าถัดไป → คลิกเลขหน้าถัดไป (idx เริ่มจาก 0 → page = idx+1)
        ${next_page}=    Evaluate    ${idx} + 2
        ${has_next}=     Run Keyword And Return Status
        ...    Page Should Contain Element    xpath=//div[@data-testid='product-pagination']//button[normalize-space(.)='${next_page}' and not(@disabled)]
        IF    ${has_next}
            Log To Console    dolly not found on page ${idx + 1}, going to page ${next_page}...
            Click Element With Retry    xpath=//div[@data-testid='product-pagination']//button[normalize-space(.)='${next_page}' and not(@disabled)]
            Sleep    1s
        ELSE
            Log To Console    No next page button for page ${next_page}, stop searching.
            Exit For Loop
        END
    END

    # Add to cart (ใช้ text-based ให้ตรงกับ UI จริง)
    Wait Until Page Contains Element    ${BTN_ADD_TO_CART}    20s
    Click Element With Retry             ${BTN_ADD_TO_CART}
    Sleep    1s

    # เปิด cart ผ่านปุ่มบน header
    Wait Until Page Contains Element    ${BTN_OPEN_CART}    20s
    ${cart_text}=    Get Text    ${BTN_OPEN_CART}
    Log To Console   Cart link text: ${cart_text}
    Click Element With Retry             ${BTN_OPEN_CART}
    Wait Until Location Contains         /cart                20s

    # ไป checkout
    Click Checkout Button
    Wait Until Location Contains         /checkout            25s


Fill Or Edit Shipping Address Country
    [Arguments]    ${country_name}
    [Documentation]    เปิดหน้า Shipping Address → Edit (ถ้ามี) → กรอก address → เลือกประเทศ → Continue

    ${has_edit}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${BTN_EDIT_SHIPPING_ADDRESS}    5s
    Run Keyword If    ${has_edit}    Click Element With Retry    ${BTN_EDIT_SHIPPING_ADDRESS}

    Wait Until Element Is Visible    ${INPUT_FIRST_NAME}    20s

    # กรอกข้อมูล address
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

    Run Keyword And Ignore Error
    ...    Clear Element Text    ${INPUT_PHONE}
    Run Keyword And Ignore Error
    ...    Input Text            ${INPUT_PHONE}    0123456789

    # เลือกประเทศ
    Wait Until Element Is Visible    ${SELECT_COUNTRY}    20s
    Select From List By Label       ${SELECT_COUNTRY}    ${country_name}

    # Continue
    Click Element With Retry        ${BTN_SUBMIT_ADDRESS}
    Wait Until Page Contains Element    ${PAGE_BODY}    20s
    Sleep    1.5s


Get DeliveryPage Text
    [Documentation]    ดึงข้อความทั้งหน้า delivery / payment / review
    ${txt}=    Get Text    ${PAGE_BODY}
    RETURN     ${txt}
