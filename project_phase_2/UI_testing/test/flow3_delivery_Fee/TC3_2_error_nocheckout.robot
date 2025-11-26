*** Settings ***
Documentation     TC3.3 – ค่าส่งไม่แสดงใน Checkout ระบบต้องไม่อนุญาตให้ยืนยัน Order
...               Flow:
...               0) Admin login → ไปหน้า Locations & Shipping → European Warehouse → Shipping →
...                  ดู Manage areas ของ Standard shipping option
...               1) Customer (eatburger) login → เลือกสินค้า dolly → Add to cart → ไป cart → Go to checkout
...               2) หน้า Shipping Address → Edit → เลือกประเทศที่ไม่มีค่าจัดส่ง (เช่น Spain)
...               3) มาถึงหน้า Delivery แล้วไม่มี shipping method ให้เลือก
...                  ปุ่ม Continue to payment (data-testid=submit-delivery-option-button) ต้อง disabled
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

# ===== Admin – Locations & Shipping / European Warehouse =====
${ADMIN_MENU_SETTINGS}              xpath=//a[contains(normalize-space(.),'Settings')]
${ADMIN_MENU_LOCATIONS_SHIPPING}    xpath=//a[contains(normalize-space(.),'Locations & Shipping')]

# Card "European Warehouse" บนหน้า Locations & Shipping
${EU_WAREHOUSE_VIEW_DETAILS}        xpath=//p[normalize-space(.)='European Warehouse']/ancestor::div[contains(@class,'shadow-elevation-card-rest')]//a[normalize-space(.)='View details']

# ปุ่ม ... ของ Standard shipping option (ตาม DOM: <p>standard</p> + ปุ่ม aria-haspopup="menu")
${BTN_STANDARD_SHIPPING_MENU}       xpath=//p[normalize-space(.)='standard']/ancestor::div[contains(@class,'flex-row') and contains(@class,'items-center')][1]//button[@aria-haspopup='menu']

# ลิงก์ Manage areas ใน menu ของ Standard
${LINK_MANAGE_AREAS}                xpath=//a[normalize-space(.)='Manage areas']

# Title บนหน้า Areas
${TEXT_AREAS_TITLE}                 Areas

# ===== Storefront / User side =====
# Account / Login
${BTN_ACCOUNT_OR_LOGIN}             xpath=//a[contains(.,'Account') or contains(.,'Sign in') or contains(.,'Log in')] | //button[contains(.,'Account') or contains(.,'Sign in') or contains(.,'Log in')]
${LOGIN_EMAIL_INPUT}                css=input[name="email"]
${LOGIN_PASSWORD_INPUT}             css=input[type="password"]
${LOGIN_SUBMIT_BTN}                 xpath=//button[normalize-space(.)='Continue'] | //button[contains(normalize-space(.),'Sign in')]

# Product list / dolly card
${CARD_PRODUCT_DOLLY}               xpath=//p[@data-testid='product-title' and normalize-space(.)='dolly']/ancestor::a[1]

# ปุ่ม Add to cart
${BTN_ADD_TO_CART}                  xpath=//button[contains(normalize-space(.),'Add') or contains(normalize-space(.),'Add to cart')]

# Cart & checkout
${BTN_OPEN_CART}                    css=a[data-testid="nav-cart-link"]

# Shipping address form
${SELECT_COUNTRY}                   xpath=//select[contains(@name,'country') or contains(@id,'country')]
${BTN_SUBMIT_ADDRESS}               xpath=//button[@data-testid='submit-address-button']
${BTN_EDIT_SHIPPING_ADDRESS}        xpath=(//button[normalize-space(.)='Edit'])[1]

# ปุ่มบนหน้า Delivery
${BTN_CONTINUE_TO_PAYMENT}          xpath=//button[@data-testid='submit-delivery-option-button']

# ใช้ดึง text ทั้งหน้า (ไว้ debug)
${PAGE_BODY}                        xpath=//body

# Country ที่ "ไม่มีค่าจัดส่ง" (ต้องไปตั้งใน admin ให้ Spain ไม่อยู่ใน service zone ใด ๆ)
${NO_SHIPPING_COUNTRY}              Spain


*** Test Cases ***
TC3_3_Error_No_Shipping_Fee_On_Checkout
    [Documentation]    TC3.3 – ถ้าเลือกประเทศ ${NO_SHIPPING_COUNTRY} ที่ไม่มี shipping zone:
    ...                0) Admin เข้า European Warehouse → Shipping → Standard → Manage areas แสดงได้
    ...                1) Customer เลือก ${NO_SHIPPING_COUNTRY}
    ...                2) หน้า Delivery ไม่มี shipping option และปุ่ม Continue to payment disabled
    # ----- Admin part (precondition) -----
    Admin Login
    Admin Go To European Warehouse
    Admin View Standard Manage Areas

    # ----- Customer part -----
    Customer Login As Eatburger
    Customer Start Checkout With Dolly

    # เลือกประเทศที่ไม่มี shipping fee
    Fill Or Edit Shipping Address Country    ${NO_SHIPPING_COUNTRY}

    # ตรวจเงื่อนไขว่า "ไปต่อไม่ได้"
    Assert Cannot Continue When NoShipping


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
    Go To    ${ADMIN_LOGIN_URL}
    Wait Until Element Is Visible    xpath=//input[@name='email']    20s
    Input Text    xpath=//input[@name='email']    ${ADMIN_USER}
    Input Text    xpath=//input[@name='password']    ${ADMIN_PASS}
    Click Button   xpath=//button[contains(.,'Continue with Email')]
    Wait Until Page Contains Element    ${ADMIN_MENU_SETTINGS}    30s

Admin Go To European Warehouse
    [Documentation]    จาก admin dashboard → Settings → Locations & Shipping → European Warehouse
    Click Element    ${ADMIN_MENU_SETTINGS}
    Wait Until Element Is Visible    ${ADMIN_MENU_LOCATIONS_SHIPPING}    20s
    Click Element    ${ADMIN_MENU_LOCATIONS_SHIPPING}
    Wait Until Element Is Visible    ${EU_WAREHOUSE_VIEW_DETAILS}    20s
    Click Element    ${EU_WAREHOUSE_VIEW_DETAILS}
    Wait Until Page Contains Element    xpath=//h1[normalize-space(.)='European Warehouse']    20s

Admin View Standard Manage Areas
    [Documentation]    ที่หน้า European Warehouse → Shipping → หา Standard shipping option แล้วเปิด Manage areas
    Wait Until Page Contains Element    xpath=//h2[normalize-space(.)='Shipping']    20s
    Scroll Element Into View            xpath=//h2[normalize-space(.)='Shipping']
    Sleep    1s

    # ปุ่ม ... ของ Standard shipping option
    Wait Until Element Is Visible    ${BTN_STANDARD_SHIPPING_MENU}    20s
    Scroll Element Into View         ${BTN_STANDARD_SHIPPING_MENU}
    Click Element With Retry         ${BTN_STANDARD_SHIPPING_MENU}

    # คลิก Manage areas
    Wait Until Element Is Visible    ${LINK_MANAGE_AREAS}    15s
    Click Element With Retry         ${LINK_MANAGE_AREAS}

    # หน้าต้องมีคำว่า Areas
    Wait Until Page Contains         ${TEXT_AREAS_TITLE}    10s
    Log To Console    Opened Manage areas for Standard in European Warehouse.
    Go Back


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
    [Documentation]    ไปหน้า store → หา product dolly (วนทุกหน้า pagination) → Add to cart → เปิด cart → Go to checkout
    Go To    ${STORE_STORE_URL}

    # ยืนยันว่าอยู่หน้า All products
    Wait Until Page Contains Element    xpath=//h1[@data-testid='store-page-title' and normalize-space(.)='All products']    20s

    # ===== นับจำนวนหน้า pagination ทั้งหมด (รองรับกี่หน้าก็ได้) =====
    ${page_buttons}=    Get WebElements    xpath=//div[@data-testid='product-pagination']//button
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

        # ถ้ายังไม่เจอ และยังมีหน้าถัดไป → คลิกเลขหน้าถัดไป (idx เริ่ม 0 → หน้า = idx+1)
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

    # Add to cart
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

    Wait Until Element Is Visible    xpath=//input[contains(@name,'first_name')]    20s

    Clear Element Text    xpath=//input[contains(@name,'first_name')]
    Input Text            xpath=//input[contains(@name,'first_name')]    test

    Clear Element Text    xpath=//input[contains(@name,'last_name')]
    Input Text            xpath=//input[contains(@name,'last_name')]     test

    Clear Element Text    xpath=//input[@name='shipping_address.address_1']
    Input Text            xpath=//input[@name='shipping_address.address_1']    MU

    Clear Element Text    xpath=//input[contains(@name,'city')]
    Input Text            xpath=//input[contains(@name,'city')]          Salaya

    Clear Element Text    xpath=//input[contains(@name,'postal')]
    Input Text            xpath=//input[contains(@name,'postal')]        12345

    Run Keyword And Ignore Error
    ...    Clear Element Text    xpath=//input[contains(@name,'phone')]
    Run Keyword And Ignore Error
    ...    Input Text            xpath=//input[contains(@name,'phone')]    0123456789

    Wait Until Element Is Visible    ${SELECT_COUNTRY}    20s
    Select From List By Label       ${SELECT_COUNTRY}    ${country_name}

    Click Element With Retry        ${BTN_SUBMIT_ADDRESS}
    Wait Until Page Contains Element    ${PAGE_BODY}    20s
    Sleep    1.5s


Get DeliveryPage Text
    [Documentation]    ดึงข้อความทั้งหน้า (delivery / payment / review)
    ${txt}=    Get Text    ${PAGE_BODY}
    RETURN     ${txt}


Assert Cannot Continue When NoShipping
    [Documentation]    ใช้ใน TC3.3:
    ...                - ไม่มี shipping option ที่เลือกได้
    ...                - ปุ่ม Continue to payment disabled → ไปหน้าถัดไปไม่ได้
    Location Should Contain    step=delivery

    ${has_delivery_option}=    Run Keyword And Return Status
    ...    Page Should Contain Element    xpath=//span[@data-testid='delivery-option-radio']
    Run Keyword If    ${has_delivery_option}    Log To Console    WARN: delivery-option-radio still present.

    Wait Until Element Is Visible    ${BTN_CONTINUE_TO_PAYMENT}    10s
    Element Should Be Disabled       ${BTN_CONTINUE_TO_PAYMENT}
    Log To Console    OK: Continue to payment is disabled → cannot proceed to payment.
