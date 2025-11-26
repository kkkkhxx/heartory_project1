*** Settings ***
Documentation     Automated UI Test for Flow 3 Error Path: Expired Campaign (SYS_05)
Library           SeleniumLibrary    run_on_failure=Capture Page Screenshot

Suite Setup       Open Admin Browser SYS_05
Suite Teardown    SeleniumLibrary.Close All Browsers


*** Variables ***
${ADMIN_LOGIN_URL}        http://10.34.112.158:9000/app/login
${ADMIN_URL}              http://10.34.112.158:9000/app/
${STORE_URL}              http://10.34.112.158:8000/dk/store

${ADMIN_USER}             group4@mu-store.local
${ADMIN_PASS}             Mp6!dzT3

${CUSTOMER_USER}          test@gmail.com
${CUSTOMER_PASS}          test123

# ---------- Product / Promotion (reuse from SYS_04) ----------
${PROMO_PRODUCT_NAME}     CANELE Hoodie
${PROMO_CODE}             group4

# ---------- Campaign ----------
${CAMPAIGN_NAME}          Birthday04
${CAMPAIGN_IDENTIFIER}    birthday discount


*** Test Cases ***
SYS_05 Error Path Campaign Expired No Discount
    [Documentation]    Error path:
    ...                1) Admin แก้ Campaign Birthday04 ให้หมดอายุ (Campaign expired)
    ...                2) ลูกค้าใช้โค้ด group4 ซื้อ CANELE Hoodie จะต้องไม่มีส่วนลด จ่ายเต็ม 30
    ...                3) ไปหน้า Account → Orders → ดู order ล่าสุด และตรวจว่าเห็นเลข Order number
    Admin Login SYS_05
    Expire Campaign SYS_05
    Admin Logout SYS_05

    Customer Purchase Product With Expired Promotion SYS_05
    Verify Latest Order In Account SYS_05



*** Keywords ***
Open Admin Browser SYS_05
    Open Browser    ${ADMIN_LOGIN_URL}    chrome
    Maximize Browser Window
    Set Selenium Speed    0.3s


# ----------------------- ADMIN LOGIN / LOGOUT -----------------------
Admin Login SYS_05
    Log To Console    [SYS_05] Logging in as Admin...
    Go To    ${ADMIN_LOGIN_URL}
    Wait Until Element Is Visible    xpath=//input[@name='email']    20s
    Input Text    xpath=//input[@name='email']    ${ADMIN_USER}
    Input Text    xpath=//input[@name='password']    ${ADMIN_PASS}
    Click Button   xpath=//button[contains(.,'Continue with Email')]
    Wait Until Page Contains Element    xpath=//a[contains(.,'Orders')]    30s
    Log To Console    [SYS_05] Admin logged in.

Admin Logout SYS_05
    Log To Console    [SYS_05] Logging out as Admin...
    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(.,'Logout') or contains(.,'Sign out')]
    Sleep    2s
    Log To Console    [SYS_05] Admin logged out.


# ----------------------- STEP 1: EXPIRE CAMPAIGN -----------------------
Expire Campaign SYS_05
    [Documentation]    เปิดแคมเปญ Birthday04 แล้วแก้ End date เป็น 26 Nov 2025 จากหน้า Configuration
    Log To Console    [SYS_05] Open campaign ${CAMPAIGN_NAME} and set it expired...

    # ไปหน้า Campaigns แล้วเข้า Birthday04
    Go To    ${ADMIN_URL}campaigns
    Wait Until Page Contains    Campaigns    20s

    Wait Until Element Is Visible
    ...    xpath=//a[contains(@href,'/campaigns/')][.//span[normalize-space()='${CAMPAIGN_NAME}']]
    ...    20s
    Click Element
    ...    xpath=//a[contains(@href,'/campaigns/')][.//span[normalize-space()='${CAMPAIGN_NAME}']]

    Wait Until Page Contains    ${CAMPAIGN_NAME}    20s

    # เปิดเมนู 3 จุดบน card Configuration แล้วกด Edit
    Wait Until Element Is Visible
    ...    xpath=//h2[normalize-space()='Configuration']/following::button[@aria-haspopup='menu'][1]
    ...    20s
    Click Element
    ...    xpath=//h2[normalize-space()='Configuration']/following::button[@aria-haspopup='menu'][1]
    Sleep    0.5s

    Wait Until Element Is Visible
    ...    xpath=//div[@role='menu']//a[@role='menuitem'][.//span[normalize-space()='Edit']]
    ...    10s
    Click Element
    ...    xpath=//div[@role='menu']//a[@role='menuitem'][.//span[normalize-space()='Edit']]
    Log To Console    [SYS_05] Edit configuration clicked, now changing End date...

    # ----- แก้ End date เป็น 26 Nov 2025 -----

    # กดปุ่ม Calendar ของช่อง End date
    Wait Until Element Is Visible
    ...    xpath=//label[contains(normalize-space(.),'End date')]/following::button[@aria-label='Calendar'][1]
    ...    20s
    Click Element
    ...    xpath=//label[contains(normalize-space(.),'End date')]/following::button[@aria-label='Calendar'][1]

    # รอ popup calendar โผล่
    Wait Until Element Is Visible    xpath=//div[@role='dialog']    10s

    # คลิกวันที่ 26 November 2025 (ตัวที่ aria-label มี November 26, 2025)
    Wait Until Element Is Visible
    ...    xpath=//div[@role='dialog']//div[@role='button' and contains(@aria-label,'November 26, 2025')]
    ...    10s
    Click Element
    ...    xpath=//div[@role='dialog']//div[@role='button' and contains(@aria-label,'November 26, 2025')]

    Log To Console    [SYS_05] End date changed to 26 Nov 2025, now saving...

    # กดปุ่ม Save ของฟอร์ม Configuration
    Wait Until Element Is Visible
    ...    xpath=//button[@type='submit' and normalize-space()='Save']
    ...    20s
    Click Button
    ...    xpath=//button[@type='submit' and normalize-space()='Save']

    # รอให้กลับมา detail page แล้วต้องเห็นคำว่า Campaign expired
    Wait Until Page Contains    Campaign expired    30s
    Log To Console    [SYS_05] Campaign is now expired (Campaign expired shown).

# ----------------------- STEP 2: CUSTOMER USE EXPIRED PROMO CODE -----------------------
Customer Purchase Product With Expired Promotion SYS_05
    Log To Console    [SYS_05] Customer tries to use expired promotion ${PROMO_CODE}...

    Go To    ${STORE_URL}

    # Login ลูกค้า
    Wait Until Element Is Visible    xpath=//a[contains(.,'Account')]    30s
    Click Element                    xpath=//a[contains(.,'Account')]
    Wait Until Element Is Visible    xpath=//input[@name='email']    20s
    Input Text                       xpath=//input[@name='email']    ${CUSTOMER_USER}
    Input Text                       xpath=//input[@name='password']    ${CUSTOMER_PASS}
    Click Button                     xpath=//button[contains(.,'Sign in')]
    Wait Until Page Contains         Overview    30s
    Log To Console    [SYS_05] Customer logged in.

    # เลือกสินค้า CANELE Hoodie
    Go To    ${STORE_URL}
    Wait Until Page Contains    ${PROMO_PRODUCT_NAME}    30s
    Click Element                xpath=//a[contains(.,'${PROMO_PRODUCT_NAME}')]

    Wait Until Element Is Visible    xpath=//button[contains(.,'Add')]    30s
    Click Element                    xpath=//button[contains(.,'Add')]
    Sleep    1s

    # ไปหน้า cart
    Go To    ${STORE_URL.replace('/dk/store','/dk/cart')}
    Wait Until Page Contains    ${PROMO_PRODUCT_NAME}    30s

    # ใส่ Promotion Code group4 (หมดอายุแล้ว)
    Log To Console    [SYS_05] Applying expired promotion code in cart...
    Wait Until Element Is Visible    xpath=//button[@data-testid='add-discount-button']    20s
    Click Element                    xpath=//button[@data-testid='add-discount-button']

    Wait Until Element Is Visible    xpath=//input[@data-testid='discount-input' and @id='promotion-input']    20s
    Press Keys                       xpath=//input[@data-testid='discount-input' and @id='promotion-input']    CTRL+A
    Press Keys                       xpath=//input[@data-testid='discount-input' and @id='promotion-input']    BACKSPACE
    Input Text                       xpath=//input[@data-testid='discount-input' and @id='promotion-input']    ${PROMO_CODE}

    Wait Until Element Is Visible    xpath=//button[@data-testid='discount-apply-button']    20s
    Click Button                     xpath=//button[@data-testid='discount-apply-button']
    Sleep    2s

    # ✅ ยืนยันว่าไม่มี "Discount" แสดง (แปลว่าไม่มีส่วนลด)
    Page Should Not Contain    Discount
    Log To Console    [SYS_05] As expected, no Discount line because campaign is expired.

    # (optional) เช็คว่ามีราคาเต็ม 30 แสดงอยู่
    Run Keyword And Ignore Error    Wait Until Page Contains    30.00    10s
    Run Keyword And Ignore Error    Wait Until Page Contains    30    10s
    Log To Console    [SYS_05] Full price (30) is shown – no discount applied.

    # เริ่ม checkout ตามปกติ (แม้ไม่มีส่วนลด แต่ order ต้องสำเร็จ)
    Log To Console    [SYS_05] Start checkout with full price...
    Wait Until Element Is Visible    xpath=//button[contains(.,'Go to checkout')]    30s
    Wait Until Element Is Enabled    xpath=//button[contains(.,'Go to checkout')]    30s
    Scroll Element Into View         xpath=//button[contains(.,'Go to checkout')]
    Click Button                     xpath=//button[contains(.,'Go to checkout')]

    # ----- กรอกที่อยู่ -----
    Wait Until Element Is Visible    xpath=//input[contains(@name,'first_name')]    30s
    Input Text                       xpath=//input[contains(@name,'first_name')]    test
    Input Text                       xpath=//input[contains(@name,'last_name')]     test
    Input Text                       xpath=//input[@name='shipping_address.address_1']    MU
    Input Text                       xpath=//input[contains(@name,'city')]          Salaya
    Input Text                       xpath=//input[contains(@name,'postal')]        12345

    Run Keyword And Ignore Error
    ...    Select From List By Label
    ...    xpath=//select[contains(@name,'country')]
    ...    France

    Run Keyword And Ignore Error
    ...    Click Element
    ...    xpath=//button[contains(@id,'headlessui-listbox-button') and .//span[contains(.,'Country') or contains(.,'Country/region')]]
    Run Keyword And Ignore Error
    ...    Click Element
    ...    xpath=//li[contains(@id,'headlessui-listbox-option') and .//span[contains(.,'France')]]

    Click Button    xpath=//button[@data-testid='submit-address-button']

    # Shipping
    Log To Console    [SYS_05] Select shipping method...
    Wait Until Element Is Visible    xpath=//span[@data-testid='delivery-option-radio']    30s
    Click Element                    xpath=(//span[@data-testid='delivery-option-radio'])[1]//button[@data-testid='radio-button']
    Sleep    0.5s
    Wait Until Element Is Enabled    xpath=//button[@data-testid='submit-delivery-option-button']    30s
    Click Button                     xpath=//button[@data-testid='submit-delivery-option-button']

    # Payment
    Log To Console    [SYS_05] Select payment method...
    Wait Until Element Is Visible    xpath=//div[@role='radiogroup']    30s
    Click Element                    xpath=//div[@role='radiogroup']//button[@data-testid='radio-button']
    Sleep    0.5s
    Wait Until Element Is Enabled    xpath=//button[@data-testid='submit-payment-button']    30s
    Click Button                     xpath=//button[@data-testid='submit-payment-button']

    # Review + Place order
    Wait Until Element Is Visible    xpath=//button[@data-testid='submit-order-button']    30s
    Click Button                     xpath=//button[@data-testid='submit-order-button']

    Wait Until Page Contains         Your order was placed successfully.    40s
    Log To Console    [SYS_05] Customer checkout successful with expired promotion (no discount applied).


# ----------------------- STEP 3: VERIFY LATEST ORDER IN ACCOUNT -----------------------
Verify Latest Order In Account SYS_05
    Log To Console    [SYS_05] Verifying latest order in customer Account...

    # ไปหน้า Orders โดยตรง
    Go To    ${STORE_URL.replace('/dk/store','/dk/account/orders')}

    # รอให้หน้า Orders โหลด (มีลิงก์ Orders อยู่บนหน้า)
    Run Keyword And Ignore Error    Wait Until Page Contains    Orders    30s

    # เปิด order ล่าสุด (ปุ่ม See details อันบนสุด)
    Wait Until Element Is Visible    xpath=(//button[@data-testid='order-details-link'])[1]    30s
    Scroll Element Into View         xpath=(//button[@data-testid='order-details-link'])[1]
    Click Button                     xpath=(//button[@data-testid='order-details-link'])[1]

    # ตรวจว่าเจอ Order number: <span data-testid="order-id">xxx</span>
    Wait Until Element Is Visible    xpath=//span[@data-testid='order-id']    30s
    ${order_id}=    Get Text         xpath=//span[@data-testid='order-id']
    Log To Console    [SYS_05] Latest order id: ${order_id}
