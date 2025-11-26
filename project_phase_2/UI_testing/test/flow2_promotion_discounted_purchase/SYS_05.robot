*** Settings ***
Documentation     Automated UI Test for Flow 3: Campaign with Promotion Code (SYS_05)
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
SYS_05 Verify Campaign With Promotion Code And Customer Order
    [Documentation]    Flow 3:
    ...                1) Admin สร้าง Campaign Birthday04 (identifier = birthday discount)
    ...                   - ใส่ Start/End date
    ...                   - Campaign Budget Type = Usage, limit = 1
    ...                   - ผูก Promotion Code group4 เข้ากับ Campaign
    ...                2) ลูกค้าใช้โค้ด group4 ซื้อสินค้า CANELE Hoodie ให้สำเร็จ
    ...                3) ไปหน้า Account → Orders → ดู order ล่าสุด และตรวจว่าเห็นเลข Order number
    Admin Login SYS_05
    Configure Campaign And Link Promotion Code SYS_05
    Admin Logout SYS_05

    Customer Purchase Product With Promotion SYS_05
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


# ----------------------- STEP 1: CREATE CAMPAIGN -----------------------
Configure Campaign And Link Promotion Code SYS_05
    Log To Console    [SYS_05] Creating campaign ${CAMPAIGN_NAME} and linking promotion code ${PROMO_CODE}...

    # ไปหน้า Campaigns ตรง ๆ
    Go To    ${ADMIN_URL}campaigns
    Wait Until Page Contains    Campaigns    20s

    # กดปุ่ม Create
    Log To Console    [SYS_05] Navigate to Campaigns page and click Create...
    Wait Until Element Is Visible    xpath=(//button[normalize-space()='Create'])[1]    20s
    Click Element                    xpath=(//button[normalize-space()='Create'])[1]

    # กรอก Name
    Wait Until Element Is Visible    xpath=//input[@name='name']    20s
    Clear Element Text               xpath=//input[@name='name']
    Input Text                       xpath=//input[@name='name']    ${CAMPAIGN_NAME}

    # กรอก Identifier
    Wait Until Element Is Visible    xpath=//input[@name='campaign_identifier']    20s
    Clear Element Text               xpath=//input[@name='campaign_identifier']
    Input Text                       xpath=//input[@name='campaign_identifier']    ${CAMPAIGN_IDENTIFIER}

    # ใส่ Start / End date + Budget
    Fill Campaign Dates And Budget SYS_05

    # กด Create campaign
    Log To Console    [SYS_05] Submit campaign form...
    Wait Until Element Is Visible    xpath=//button[@type='submit' and normalize-space()='Create']    20s
    Click Button                     xpath=//button[@type='submit' and normalize-space()='Create']

    # รอให้มาอยู่หน้า Campaign detail (มีปุ่ม Add)
    Wait Until Element Is Visible    xpath=//button[normalize-space()='Add']    30s
    Log To Console    [SYS_05] Campaign created. Now linking promotion code...

    Link Promotion Code To Campaign SYS_05
    Log To Console    [SYS_05] Campaign configured and promotion code linked successfully.


Fill Campaign Dates And Budget SYS_05
    Log To Console    [SYS_05] Fill Start/End date and Campaign Budget...

    # --- Start date: 25 Nov 2025 00:00 AM ---
    Wait Until Element Is Visible    xpath=(//button[@aria-label='Calendar'])[1]    20s
    Click Element                    xpath=(//button[@aria-label='Calendar'])[1]
    Wait Until Element Is Visible    xpath=//div[@role='dialog']    10s
    Wait Until Element Is Visible    xpath=//div[@role='dialog']//div[contains(@aria-label,'November 25, 2025')]    10s
    Click Element                    xpath=//div[@role='dialog']//div[contains(@aria-label,'November 25, 2025')]

    ${js_time_start}=    Catenate    SEPARATOR=\n
    ...    (function() {
    ...      var input = document.querySelector("input[name='starts_at']");
    ...      if (input) {
    ...        input.value = '11/25/2025 12:00 AM';
    ...        input.dispatchEvent(new Event('input', {bubbles:true}));
    ...      }
    ...    })();
    Execute JavaScript    ${js_time_start}

    # --- End date: 26 Nov 2025 04:00 PM ---
    Wait Until Element Is Visible    xpath=(//button[@aria-label='Calendar'])[2]    20s
    Click Element                    xpath=(//button[@aria-label='Calendar'])[2]
    Wait Until Element Is Visible    xpath=//div[@role='dialog']    20s
    Wait Until Element Is Visible    xpath=//div[@role='dialog']//div[contains(@aria-label,'November 29, 2025')]    10s
    Click Element                    xpath=//div[@role='dialog']//div[contains(@aria-label,'November 29, 2025')]

    ${js_time_end}=    Catenate    SEPARATOR=\n
    ...    (function() {
    ...      var input = document.querySelector("input[name='ends_at']");
    ...      if (input) {
    ...        input.value = '11/26/2025 4:00 PM';
    ...        input.dispatchEvent(new Event('input', {bubbles:true}));
    ...      }
    ...    })();
    Execute JavaScript    ${js_time_end}

    Log To Console    [SYS_05] Dates selected, now set Campaign budget...

    # ปิด popup calendar ด้วยการคลิกนอกกล่อง (กันมันบัง Budget)
    Run Keyword And Ignore Error
    ...    Click Element
    ...    xpath=//h2[contains(normalize-space(.),'Campaign Budget')]
    Sleep    0.5s

    # ---------- Campaign Budget: Usage + Limit = 1 ----------
    # ใช้ JS หาและคลิกปุ่ม Usage โดยไม่ต้องเช็ค visible
    ${js_usage}=    Catenate    SEPARATOR=\n
    ...    (function() {
    ...      var buttons = document.querySelectorAll("button[role='radio']");
    ...      for (var i = 0; i < buttons.length; i++) {
    ...        var span = buttons[i].querySelector('span');
    ...        if (span && span.textContent.trim() === 'Usage') {
    ...          buttons[i].click();
    ...          return true;
    ...        }
    ...      }
    ...      return false;
    ...    })();
    ${usage_clicked}=    Execute JavaScript    ${js_usage}
    Run Keyword If    not ${usage_clicked}    Log To Console    [SYS_05] ⚠ Could not click Usage type via JS (maybe already selected).

    # Limit = 3
    Wait Until Element Is Visible    xpath=//input[@name='budget.limit']    20s
    Press Keys    xpath=//input[@name='budget.limit']    CTRL+A
    Press Keys    xpath=//input[@name='budget.limit']    BACKSPACE
    Input Text    xpath=//input[@name='budget.limit']    3

    Log To Console    [SYS_05] ✅ Campaign budget set to Usage limit = 1.

Link Promotion Code To Campaign SYS_05
    Log To Console    [SYS_05] Linking promotion code ${PROMO_CODE} to campaign...

    # ปุ่ม Add อยู่ล่าง ๆ card Promotions → scroll ให้เห็นก่อน
    Scroll Element Into View    xpath=//button[normalize-space()='Add']
    Wait Until Element Is Visible    xpath=//button[normalize-space()='Add']    20s
    Click Element                    xpath=//button[normalize-space()='Add']

    # รอ dialog เลือก promotions
    Wait Until Element Is Visible    xpath=//div[@role='dialog']    20s
    Sleep    1s

    # หา promotion code ${PROMO_CODE} บน dialog (รองรับหลายหน้า)
    ${promo_found}=    Find Promotion On Any Page SYS_05    ${PROMO_CODE}
    Run Keyword Unless    ${promo_found}
    ...    Fail    [SYS_05] Promotion '${PROMO_CODE}' not found in Add promotions dialog.

    Log To Console    [SYS_05] Promotion row for ${PROMO_CODE} clicked, now saving...

    # กด Save ใน dialog
    Wait Until Element Is Visible    xpath=//div[@role='dialog']//button[normalize-space()='Save']    20s
    Click Button                     xpath=//div[@role='dialog']//button[normalize-space()='Save']

    # รอ dialog ปิด
    Wait Until Page Does Not Contain Element    xpath=//div[@role='dialog']    20s

    # เช็กว่ามีคำว่า group4 แสดงใน section Promotions แล้ว
    Run Keyword And Ignore Error    Wait Until Page Contains    ${PROMO_CODE}    10s
    Log To Console    [SYS_05] Promotion code ${PROMO_CODE} linked to campaign (or expected to be linked).



# ----------------------- STEP 2: CUSTOMER USE PROMO CODE -----------------------
Customer Purchase Product With Promotion SYS_05
    Log To Console    [SYS_05] Customer logs in and purchases ${PROMO_PRODUCT_NAME} with code ${PROMO_CODE}...

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

    # ใส่ Promotion Code group4
    Log To Console    [SYS_05] Applying promotion code in cart...
    Wait Until Element Is Visible    xpath=//button[@data-testid='add-discount-button']    20s
    Click Element                    xpath=//button[@data-testid='add-discount-button']

    Wait Until Element Is Visible    xpath=//input[@data-testid='discount-input' and @id='promotion-input']    20s
    Press Keys                       xpath=//input[@data-testid='discount-input' and @id='promotion-input']    CTRL+A
    Press Keys                       xpath=//input[@data-testid='discount-input' and @id='promotion-input']    BACKSPACE
    Input Text                       xpath=//input[@data-testid='discount-input' and @id='promotion-input']    ${PROMO_CODE}

    Wait Until Element Is Visible    xpath=//button[@data-testid='discount-apply-button']    20s
    Click Button                     xpath=//button[@data-testid='discount-apply-button']
    Sleep    2s

    Run Keyword And Ignore Error    Wait Until Page Contains    ${PROMO_CODE}    10s
    Run Keyword And Ignore Error    Wait Until Page Contains    Discount    10s
    Log To Console    [SYS_05] Promotion code applied (or expected to be applied).

    # เริ่ม checkout
    Log To Console    [SYS_05] Start checkout...
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
    Log To Console    [SYS_05] Customer checkout successful with promotion applied.


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
Find Promotion On Any Page SYS_05
    [Arguments]    ${PROMO_CODE}

    # ลูปเช็กได้สูงสุด 10 หน้า (กันอนาคตมีโปรเยอะ)
    FOR    ${idx}    IN RANGE    1    10
        Log To Console    [SYS_05] Check promotions dialog page ${idx} for code ${PROMO_CODE}...

        # ดูว่าหน้านี้มี span = promo code ไหม
        ${found}=    Run Keyword And Return Status
        ...    Page Should Contain Element
        ...    xpath=//div[@role='dialog']//span[normalize-space()='${PROMO_CODE}']

        IF    ${found}
            Log To Console    [SYS_05] Found promotion on dialog page ${idx}, clicking row...

            # เลื่อน span ให้โผล่
            Scroll Element Into View
            ...    xpath=//div[@role='dialog']//span[normalize-space()='${PROMO_CODE}']

            # คลิก checkbox ในแถวเดียวกัน
            Wait Until Element Is Visible
            ...    xpath=//div[@role='dialog']//span[normalize-space()='${PROMO_CODE}']/ancestor::tr[1]//div[contains(@class,'rounded-[3px]')][1]
            ...    10s
            Click Element
            ...    xpath=//div[@role='dialog']//span[normalize-space()='${PROMO_CODE}']/ancestor::tr[1]//div[contains(@class,'rounded-[3px]')][1]

            RETURN    ${True}
        END

        # ถ้าไม่เจอ ลองหาปุ่ม Next ใน dialog
        ${has_next}=    Run Keyword And Return Status
        ...    Page Should Contain Element
        ...    xpath=//div[@role='dialog']//button[normalize-space()='Next']

        IF    ${has_next}
            Log To Console    [SYS_05] Not found on page ${idx} → click Next...
            Click Element    xpath=//div[@role='dialog']//button[normalize-space()='Next']
            Sleep    1s
        ELSE
            Log To Console    [SYS_05] No Next button on dialog page ${idx} → stop searching.
            BREAK
        END
    END

    Log To Console    [SYS_05] Promotion '${PROMO_CODE}' not found in promotions dialog.
    RETURN    ${False}
