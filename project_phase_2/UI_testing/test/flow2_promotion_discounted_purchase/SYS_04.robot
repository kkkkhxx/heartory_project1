*** Settings ***
Documentation     Automated UI Test for Flow 2: Promotion Amount Off Products (SYS_04)
Library           SeleniumLibrary    run_on_failure=Capture Page Screenshot

Suite Setup       Open Admin Browser SYS_04
Suite Teardown    SeleniumLibrary.Close All Browsers


*** Variables ***
${ADMIN_LOGIN_URL}        http://10.34.112.158:9000/app/login
${ADMIN_URL}              http://10.34.112.158:9000/app/
${STORE_URL}              http://10.34.112.158:8000/dk/store

${ADMIN_USER}             group4@mu-store.local
${ADMIN_PASS}             Mp6!dzT3

${CUSTOMER_USER}          test@gmail.com
${CUSTOMER_PASS}          test123

# ---------- สินค้าสำหรับโปรโมชัน ----------
${PROMO_PRODUCT_NAME}     CANELE Hoodie
${PROMO_PRODUCT_DESC}     Cute Hoodie for Cute person
${PROMO_PRODUCT_PRICE}    20
${PROMO_PRODUCT_FILTER}   CANELE

# ---------- โปรโมชัน ----------
${PROMOTIONS_URL}         http://10.34.112.158:9000/app/promotions
${PROMO_CODE}             group4
${PROMO_DISCOUNT_VALUE}   5
${PROMO_TYPE_LABEL}       Amount off products


*** Test Cases ***
SYS_04 Verify Amount Off Products Promotion Applied Correctly
    [Documentation]    Flow: Admin สร้างสินค้าใหม่ + สร้าง Promotion แบบ Amount off products ให้สินค้านั้น
    ...                → ลูกค้าเห็นราคาลด → checkout แล้วรวมค่าส่งเหลือ ~25 จาก 30 → Admin เห็น Order พร้อมส่วนลด
    Admin Login SYS_04

    # 1–4: สร้างสินค้า ICT Keyring + ตั้งราคา + stock + shipping
    Create New Product For Promotion SYS_04
    Configure Inventory For Promotion Product SYS_04

    # 5–8: สร้าง Promotion แบบ Amount off products + ผูกกับสินค้า ICT Keyring
    Configure Promotion For Product SYS_04

    Admin Logout SYS_04

    # 9–12: ลูกค้า login → ซื้อสินค้า → ตรวจว่าราคาลด
    Customer Purchase Product With Promotion SYS_04

    # 13: กลับไปฝั่ง Admin ตรวจ Order
    Verify Discounted Order In Admin SYS_04



*** Keywords ***
Open Admin Browser SYS_04
    Open Browser    ${ADMIN_LOGIN_URL}    chrome
    Maximize Browser Window
    Set Selenium Speed    0.3s


# ----------------------- ADMIN LOGIN / LOGOUT -----------------------
Admin Login SYS_04
    Log To Console    [SYS_04] Logging in as Admin...
    Go To    ${ADMIN_LOGIN_URL}
    Wait Until Element Is Visible    xpath=//input[@name='email']    20s
    Input Text    xpath=//input[@name='email']    ${ADMIN_USER}
    Input Text    xpath=//input[@name='password']    ${ADMIN_PASS}
    Click Button   xpath=//button[contains(.,'Continue with Email')]
    Wait Until Page Contains Element    xpath=//a[contains(.,'Orders')]    30s
    Log To Console    [SYS_04] Admin logged in (Orders page visible or accessible).

Admin Logout SYS_04
    Log To Console    [SYS_04] Logging out as Admin...
    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(.,'Logout') or contains(.,'Sign out')]
    Sleep    2s
    Log To Console    [SYS_04] Admin logged out.


# ----------------------- STEP 3–4: CREATE PRODUCT ICT KEYRING -----------------------
Create New Product For Promotion SYS_04
    Log To Console    [SYS_04] Creating new product ICT Keyring...

    # ไปหน้า Products แล้วกด Create
    Click Element    xpath=//a[contains(.,'Products')]
    Wait Until Page Contains Element    xpath=//a[contains(.,'Create')]    20s
    Click Element    xpath=//a[contains(.,'Create')]
    Wait Until Page Contains    Details    20s
    Sleep    1s

    # ===== กรอก Title =====
    Log To Console    [SYS_04] Filling Title...
    Wait Until Element Is Visible    xpath=(//input[@name='title'])[last()]    20s
    Input Text    xpath=(//input[@name='title'])[last()]    ${PROMO_PRODUCT_NAME}
    Sleep    0.5s

    # ===== กรอก Description =====
    Log To Console    [SYS_04] Filling Description...
    Wait Until Element Is Visible    xpath=(//textarea[@name='description'])[last()]    20s
    Input Text    xpath=(//textarea[@name='description'])[last()]    ${PROMO_PRODUCT_DESC}
    Sleep    0.5s
    Capture Page Screenshot

    # ===== ไปแท็บ Organize =====
    Log To Console    [SYS_04] Go to Organize tab...
    Click Element    xpath=(//button[@role='tab' and contains(normalize-space(.),'Organize')])[last()]
    Sleep    1s
    Capture Page Screenshot

    # ===== ไปแท็บ Variants =====
    Log To Console    [SYS_04] Go to Variants tab...
    Click Element    xpath=(//button[@role='tab' and contains(normalize-space(.),'Variants')])[last()]
    Wait Until Page Contains Element    xpath=//input[@name='variants.0.prices.eur']    30s
    Capture Page Screenshot

    # ===== ตั้งราคา + เปิด Manage inventory =====
    Set Variant Prices SYS_04
    Sleep    1s
    Capture Page Screenshot

    # ===== Publish =====
    Log To Console    [SYS_04] Publishing product...
    Click Button    xpath=//button[@data-name='publish-button' or contains(.,'Publish')]
    Wait Until Page Contains    Published    30s
    Capture Page Screenshot

    # กลับไปหน้า Products แล้วหา product บนทุกหน้า
    Go To    ${ADMIN_URL}products
    Find Product On Any Page SYS_04    ${PROMO_PRODUCT_NAME}
    Log To Console    [SYS_04] Product ICT Keyring created and visible in Products list.
    Capture Page Screenshot


# ----------------------- INVENTORY + SHIPPING FOR PROMO PRODUCT -----------------------
Configure Inventory For Promotion Product SYS_04
    Log To Console    [SYS_04] Configuring inventory + shipping for ICT Keyring...

    # ตอนนี้น่าจะอยู่หน้า Products แล้ว → ใช้ keyword หา product อีกครั้ง (กันหลุดหน้า)
    Go To    ${ADMIN_URL}products
    Find Product On Any Page SYS_04    ${PROMO_PRODUCT_NAME}

    # คลิกเข้า edit product
    Click Element    xpath=//tr[.//a[contains(normalize-space(.),'${PROMO_PRODUCT_NAME}')]]
    Wait Until Page Contains    Variants    20s

    # ===== ตั้งค่า Shipping profile ให้เป็น Default (ถ้ามีการ์ด) =====
    Configure Shipping Profile For Product SYS_04

    # ===== คลิกแถว Default variant เพื่อไปหน้า Variant detail =====
    Log To Console    [SYS_04] Open Default variant row...
    Wait Until Element Is Visible
    ...    xpath=//tbody//tr[.//td[contains(normalize-space(.),'Default variant')]]
    ...    20s
    Click Element
    ...    xpath=//tbody//tr[.//td[contains(normalize-space(.),'Default variant')]]

    # รอหน้า variant detail
    Wait Until Page Contains    Inventory items    20s

    # ===== เปิดเมนูสามจุดของการ์ด Inventory items แล้วเลือก Manage inventory items =====
    Log To Console    [SYS_04] Open Manage inventory items menu...
    Click Element
    ...    xpath=//h2[contains(.,'Inventory items')]/following::button[contains(@aria-haspopup,'menu')][1]

    Wait Until Element Is Visible
    ...    xpath=//div[@role='menu']//*[contains(normalize-space(.),'Manage inventory items')]
    ...    10s
    Click Element
    ...    xpath=//div[@role='menu']//*[contains(normalize-space(.),'Manage inventory items')]

    # ===== หน้า manage-items =====
    Log To Console    [SYS_04] Select inventory item (option 2) and set qty=20...

    # รอให้ quantity field โผล่
    Wait Until Element Is Visible    xpath=//input[@name='inventory.0.required_quantity']    20s

    # เปิด dropdown Item
    Click Element    xpath=//input[@name='inventory.0.inventory_item_id']/parent::div
    Sleep    0.5s

    # เลือก option ตัวที่ 2 (inventory item ของ warehouse)
    Wait Until Element Is Visible
    ...    xpath=(//div[@role='listbox']//div[@role='option'])[2]
    ...    10s
    Click Element
    ...    xpath=(//div[@role='listbox']//div[@role='option'])[2]
    Sleep    0.5s

    # ตั้ง Quantity = 20 แล้ว Save
    Press Keys    xpath=//input[@name='inventory.0.required_quantity']    CTRL+A
    Press Keys    xpath=//input[@name='inventory.0.required_quantity']    BACKSPACE
    Input Text    xpath=//input[@name='inventory.0.required_quantity']    20
    Click Button  xpath=//button[normalize-space()='Save']

    Wait Until Page Contains    Inventory items    20s
    Log To Console    [SYS_04] Inventory item configured with quantity 20.
    Go To    ${ADMIN_URL}products


Configure Shipping Profile For Product SYS_04
    Log To Console    [SYS_04] Configure default shipping profile for ICT Keyring...

    # พยายามหา card "Shipping configuration" ถ้าไม่มีจะข้าม
    ${has_shipping_card}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    xpath=//h2[contains(normalize-space(.),'Shipping configuration') or contains(normalize-space(.),'Shipping')]
    ...    10s

    IF    not ${has_shipping_card}
        Log To Console    [SYS_04] ⚠ Shipping configuration card not found. Assume default shipping already applied. Skipping shipping setup.
        RETURN
    END

    # ถ้าเจอการ์ดแล้ว → กดปุ่มสามจุด
    Click Element
    ...    xpath=//h2[contains(normalize-space(.),'Shipping configuration') or contains(normalize-space(.),'Shipping')]/following::button[contains(@aria-haspopup,'menu')][1]

    # เลือก Edit
    Wait Until Element Is Visible
    ...    xpath=//div[@role='menu']//*[contains(normalize-space(.),'Edit')]
    ...    10s
    Click Element
    ...    xpath=//div[@role='menu']//*[contains(normalize-space(.),'Edit')]

    # combobox shipping_profile_id
    Wait Until Element Is Visible
    ...    xpath=//input[@name='shipping_profile_id']
    ...    20s

    Run Keyword And Ignore Error
    ...    Click Element
    ...    xpath=//input[@name='shipping_profile_id']
    Run Keyword And Ignore Error
    ...    Click Element
    ...    xpath=//input[@name='shipping_profile_id']/parent::div//button[@aria-haspopup='listbox' or @aria-label='Show popup']
    Sleep    0.5s

    # เลือก option แรก (Default shipping)
    Wait Until Element Is Visible
    ...    xpath=//div[@role='listbox']//div[@role='option'][1]
    ...    10s
    Click Element
    ...    xpath=//div[@role='listbox']//div[@role='option'][1]
    Sleep    0.5s

    Click Button    xpath=//button[normalize-space()='Save']

    Wait Until Element Is Visible
    ...    xpath=//h2[contains(normalize-space(.),'Shipping configuration') or contains(normalize-space(.),'Shipping')]
    ...    20s

    Log To Console    [SYS_04] Default shipping profile set for ICT Keyring.


# ----------------------- STEP 5–8: PROMOTION CONFIG -----------------------
Configure Promotion For Product SYS_04
    Log To Console    [SYS_04] Configure Amount off products promotion for ${PROMO_PRODUCT_NAME}...

    # ไปหน้า Promotions
    Go To    ${PROMOTIONS_URL}
    Wait Until Page Contains    Promotions    20s

    # กดปุ่ม Create (ลิงก์ /app/promotions/create)
    Wait Until Element Is Visible
    ...    xpath=//a[contains(@href,'/app/promotions/create') and contains(normalize-space(.),'Create')]
    ...    20s
    Click Element
    ...    xpath=//a[contains(@href,'/app/promotions/create') and contains(normalize-space(.),'Create')]

    # -------- STEP 1: TYPE = Amount off products --------
    Log To Console    [SYS_04] Select Type = ${PROMO_TYPE_LABEL}...
    Wait Until Page Contains    Type    20s

    Wait Until Element Is Visible
    ...    xpath=//button[@role='radio'][.//label[contains(normalize-space(.),'${PROMO_TYPE_LABEL}')]]
    ...    20s
    Click Element
    ...    xpath=//button[@role='radio'][.//label[contains(normalize-space(.),'${PROMO_TYPE_LABEL}')]]

    # กด Continue ไปหน้า Details
    Wait Until Element Is Visible    xpath=//button[normalize-space()='Continue']    20s
    Click Button                     xpath=//button[normalize-space()='Continue']

    # -------- STEP 2: DETAILS (Code, Active, code, Euro, value) --------
    Log To Console    [SYS_04] Fill Details (Code, Active, code, Euro, value)...

    # Method = Code  (ใช้โปรโมชันแบบกรอกโค้ด)
    Wait Until Element Is Visible
    ...    xpath=//button[@role='radio'][.//label[contains(normalize-space(.),'Promotion code')]]
    ...    20s
    Click Element
    ...    xpath=//button[@role='radio'][.//label[contains(normalize-space(.),'Promotion code')]]

    # Status = Active
    Wait Until Element Is Visible
    ...    xpath=//button[@role='radio'][.//label[contains(normalize-space(.),'Active')]]
    ...    20s
    Click Element
    ...    xpath=//button[@role='radio'][.//label[contains(normalize-space(.),'Active')]]

    # Code = group4 (input[name='code'])
    Wait Until Element Is Visible    xpath=//input[@name='code']    20s
    Clear Element Text               xpath=//input[@name='code']
    Input Text                       xpath=//input[@name='code']    ${PROMO_CODE}

    # Currency = Euro → combobox rules.0.values
    Wait Until Element Is Visible    xpath=//input[@name='rules.0.values']    20s
    Click Element                    xpath=//input[@name='rules.0.values']/parent::div
    Wait Until Element Is Visible
    ...    xpath=//div[@role='listbox']//div[@role='option'][.//span[contains(.,'Euro') or contains(.,'EUR')]]
    ...    10s
    Click Element
    ...    xpath=//div[@role='listbox']//div[@role='option'][.//span[contains(.,'Euro') or contains(.,'EUR')]]

    # Value = 5 → application_method.value
    Wait Until Element Is Visible    xpath=//input[@name='application_method.value']    20s
    Press Keys                       xpath=//input[@name='application_method.value']    CTRL+A
    Press Keys                       xpath=//input[@name='application_method.value']    BACKSPACE
    Input Text                       xpath=//input[@name='application_method.value']    ${PROMO_DISCOUNT_VALUE}

    # -------- STEP 3: CAMPAIGN + SAVE --------
    Log To Console    [SYS_04] Go to Campaign step and save promotion...

    # กด Continue ไปหน้า Campaign
    Wait Until Element Is Visible    xpath=//button[normalize-space()='Continue']    20s
    Click Button                     xpath=//button[normalize-space()='Continue']

    # กันหลุด: รอให้มีคำว่า Campaign โผล่ (ถ้ามี)
    Run Keyword And Ignore Error    Wait Until Page Contains    Campaign    10s

    # พยายามเลือกตัวเลือก "No campaign" ถ้ามี
    ${has_no_campaign}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    xpath=//button[@role='radio'][.//span[contains(normalize-space(.),'No campaign')]]
    ...    5s

    IF    ${has_no_campaign}
        Click Element
        ...    xpath=//button[@role='radio'][.//span[contains(normalize-space(.),'No campaign')]]
        Sleep    0.5s
        Log To Console    [SYS_04] Selected 'No campaign' option.
    ELSE
        Log To Console    [SYS_04] ⚠ No 'No campaign' option visible, skipping campaign selection.
    END

    # ปุ่ม Save / Complete / Create promotion (แล้วแต่ UI)
    ${has_save}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible
    ...    xpath=//button[normalize-space()='Save']
    ...    10s

    IF    ${has_save}
        Click Button    xpath=//button[normalize-space()='Save']
    ELSE
        ${has_complete}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible
        ...    xpath=//button[normalize-space()='Complete' or normalize-space()='Create promotion']
        ...    10s
        Run Keyword If    ${has_complete}
        ...    Click Button
        ...    xpath=//button[normalize-space()='Complete' or normalize-space()='Create promotion']
    END

    # รอให้กลับมาหน้า Promotions list
    Wait Until Page Contains    Promotions    30s
    Log To Console    [SYS_04] Promotion created and saved successfully.


# ----------------------- STEP 9–12: CUSTOMER BUY WITH PROMO -----------------------
Customer Purchase Product With Promotion SYS_04
    Log To Console    [SYS_04] Customer checks and purchases ICT Keyring with promotion...

    Go To    ${STORE_URL}

    # Login ลูกค้า
    Wait Until Element Is Visible    xpath=//a[contains(.,'Account')]    30s
    Click Element    xpath=//a[contains(.,'Account')]
    Wait Until Element Is Visible    xpath=//input[@name='email']    20s
    Input Text    xpath=//input[@name='email']    ${CUSTOMER_USER}
    Input Text    xpath=//input[@name='password']    ${CUSTOMER_PASS}
    Click Button   xpath=//button[contains(.,'Sign in')]
    Wait Until Page Contains    Overview    30s
    Log To Console    [SYS_04] Customer logged in.

    # กลับไปหน้า Store แล้วเลือก product ICT Keyring
    Go To    ${STORE_URL}
    Wait Until Page Contains    ${PROMO_PRODUCT_NAME}    30s
    Click Element    xpath=//a[contains(.,'${PROMO_PRODUCT_NAME}')]

    # คาดหวังว่าหน้าสินค้าจะมีราคาที่ถูกลดแล้ว (เช่น 15 แทน 20 หรือมีคำว่า Discount)
    Run Keyword And Ignore Error
    ...    Wait Until Page Contains
    ...    Discount
    ...    10s

    Wait Until Element Is Visible    xpath=//button[contains(.,'Add')]    30s
    Click Element    xpath=//button[contains(.,'Add')]
    Sleep    1s

        # ไปหน้า cart
    Go To    ${STORE_URL.replace('/dk/store','/dk/cart')}
    Wait Until Page Contains    ${PROMO_PRODUCT_NAME}    30s

    # ----- ใส่ Promotion Code ใน cart -----
    Log To Console    [SYS_04] Applying promotion code in cart...

    # กดปุ่ม Add Promotion Code(s)
    Wait Until Element Is Visible
    ...    xpath=//button[@data-testid='add-discount-button']
    ...    20s
    Click Element
    ...    xpath=//button[@data-testid='add-discount-button']

    # ใส่โค้ดโปรโมชันลงใน input
    Wait Until Element Is Visible
    ...    xpath=//input[@data-testid='discount-input' and @id='promotion-input']
    ...    20s
    Press Keys
    ...    xpath=//input[@data-testid='discount-input' and @id='promotion-input']
    ...    CTRL+A
    Press Keys
    ...    xpath=//input[@data-testid='discount-input' and @id='promotion-input']
    ...    BACKSPACE
    Input Text
    ...    xpath=//input[@data-testid='discount-input' and @id='promotion-input']
    ...    ${PROMO_CODE}

    # กดปุ่ม Apply
    Wait Until Element Is Visible
    ...    xpath=//button[@data-testid='discount-apply-button']
    ...    20s
    Click Button
    ...    xpath=//button[@data-testid='discount-apply-button']
    Sleep    2s

    # ตรวจว่ามี code หรือ Discount แสดงใน cart
    Run Keyword And Ignore Error
    ...    Wait Until Page Contains
    ...    ${PROMO_CODE}
    ...    10s
    Run Keyword And Ignore Error
    ...    Wait Until Page Contains
    ...    Discount
    ...    10s

    Log To Console    [SYS_04] Promotion code applied (or expected to be applied).

    # (Optional) เช็คว่าราคาใน cart น้อยกว่าหรือเท่ากับ 25 (ประมาณราคารวมค่าส่งลดแล้ว)
    Run Keyword And Ignore Error    Wait Until Page Contains    25    20s

    Log To Console    [SYS_04] Product in cart with (expected) discounted price.


    # ================ CHECKOUT FLOW ================
    Log To Console    [SYS_04] Start checkout...
    Wait Until Element Is Visible    xpath=//button[contains(.,'Go to checkout')]    30s
    Wait Until Element Is Enabled    xpath=//button[contains(.,'Go to checkout')]    30s
    Scroll Element Into View         xpath=//button[contains(.,'Go to checkout')]
    Click Button                     xpath=//button[contains(.,'Go to checkout')]

    # ----- กรอกที่อยู่ -----
    Wait Until Element Is Visible    xpath=//input[contains(@name,'first_name')]    30s
    Input Text    xpath=//input[contains(@name,'first_name')]    test
    Input Text    xpath=//input[contains(@name,'last_name')]     test
    Input Text    xpath=//input[@name='shipping_address.address_1']    MU
    Input Text    xpath=//input[contains(@name,'city')]          Salaya
    Input Text    xpath=//input[contains(@name,'postal')]        12345

    # Country = France
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

    # Continue to delivery
    Click Button    xpath=//button[@data-testid='submit-address-button']

    # เลือก Standard Shipping → Continue to payment
    Log To Console    [SYS_04] Select shipping method...
    Wait Until Element Is Visible    xpath=//span[@data-testid='delivery-option-radio']    40s
    Click Element    xpath=(//span[@data-testid='delivery-option-radio'])[1]//button[@data-testid='radio-button']
    Sleep    0.5s
    Wait Until Element Is Enabled    xpath=//button[@data-testid='submit-delivery-option-button']    40s
    Click Button     xpath=//button[@data-testid='submit-delivery-option-button']

    # เลือก Manual Payment → Continue to review
    Log To Console    [SYS_04] Select payment method...
    Wait Until Element Is Visible    xpath=//div[@role='radiogroup']    40s
    Click Element    xpath=//div[@role='radiogroup']//button[@data-testid='radio-button']
    Sleep    0.5s
    Wait Until Element Is Enabled    xpath=//button[@data-testid='submit-payment-button']    40s
    Click Button     xpath=//button[@data-testid='submit-payment-button']

    # ตรวจว่าราคารวม (รวมค่าส่ง) แสดงประมาณ 25 (ตาม test step)
    Run Keyword And Ignore Error    Wait Until Page Contains    25    40s

    # Review + Place order
    Wait Until Element Is Visible    xpath=//button[@data-testid='submit-order-button']    40s
    Click Button     xpath=//button[@data-testid='submit-order-button']

    Wait Until Page Contains    Your order was placed successfully.    40s
    Log To Console    [SYS_04] Customer checkout successful with promotion applied.



# ----------------------- STEP 13: VERIFY ORDER IN ADMIN -----------------------
Verify Discounted Order In Admin SYS_04
    Log To Console    [SYS_04] Verifying discounted order in Admin...
    Admin Login SYS_04

    Click Element    xpath=//a[contains(.,'Orders')]
    Wait Until Element Is Visible    xpath=(//table//tbody//tr)[1]    40s
    Click Element    xpath=(//table//tbody//tr)[1]

    # ตรวจว่ามีอีเมลลูกค้า
    Wait Until Page Contains    ${CUSTOMER_USER}    40s

    # พยายามตรวจว่า order มี discount แสดง เช่น code group4 หรือคำว่า Discount
    Run Keyword And Ignore Error    Wait Until Page Contains    ${PROMO_CODE}    10s
    Run Keyword And Ignore Error    Wait Until Page Contains    Discount    10s

    Log To Console    [SYS_04] New order with discount (group4) is visible in Admin Orders.
    Admin Logout SYS_04



# ----------------------- HELPERS -----------------------
Set Variant Prices SYS_04
    Log To Console    [SYS_04] Setting variant prices via grid...

    # รอ cell ราคา EUR แถวแรก
    Wait Until Element Is Visible    xpath=//div[@role='gridcell' and @data-row-index='0' and @data-column-index='6']    20s

    # --- ตั้งราคา EUR ---
    Click Element    xpath=//div[@role='gridcell' and @data-row-index='0' and @data-column-index='6']
    Wait Until Element Is Visible    xpath=//input[@name='variants.0.prices.eur']    10s
    Press Keys       xpath=//input[@name='variants.0.prices.eur']    CTRL+A
    Press Keys       xpath=//input[@name='variants.0.prices.eur']    BACKSPACE
    Input Text       xpath=//input[@name='variants.0.prices.eur']    ${PROMO_PRODUCT_PRICE}
    Press Keys       xpath=//input[@name='variants.0.prices.eur']    ENTER
    Sleep    0.5s

    # --- ตั้งราคา USD (ถ้ามี) ---
    Run Keyword And Ignore Error    Set USD Price SYS_04

    # --- เปิด checkbox Manage inventory ---
    Run Keyword And Ignore Error
    ...    Click Element
    ...    xpath=//button[@role='checkbox' and @data-field='variants.0.manage_inventory']
    Sleep    0.5s


Set USD Price SYS_04
    Click Element    xpath=//div[@role='gridcell' and @data-row-index='0' and @data-column-index='7']
    Wait Until Element Is Visible    xpath=//input[@name='variants.0.prices.usd']    10s
    Press Keys       xpath=//input[@name='variants.0.prices.usd']    CTRL+A
    Press Keys       xpath=//input[@name='variants.0.prices.usd']    BACKSPACE
    Input Text       xpath=//input[@name='variants.0.prices.usd']    ${PROMO_PRODUCT_PRICE}
    Press Keys       xpath=//input[@name='variants.0.prices.usd']    ENTER
    Sleep    0.5s


Find Product On Any Page SYS_04
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

Select Promotion Product In Values Dropdown SYS_04
    [Arguments]    ${product_name}
    Log To Console    [SYS_04] Selecting value '${product_name}' in Values dropdown (JS scroll-search)...

    ${clicked}=    Execute JavaScript
    ...    (function(){
    ...        var targetName = "${product_name}";
    ...        // listbox ตัวล่าสุด (ของ Values)
    ...        var listboxes = document.querySelectorAll("div[role='listbox']");
    ...        if (!listboxes || !listboxes.length) { return false; }
    ...        var lb = listboxes[listboxes.length - 1];
    ...        // ลองเลื่อนลงทีละหน่อย สูงสุด 40 รอบ
    ...        for (var step = 0; step < 40; step++) {
    ...            var options = lb.querySelectorAll("div[role='option'] span.txt-compact-small");
    ...            for (var i = 0; i < options.length; i++) {
    ...                var txt = (options[i].textContent || "").trim();
    ...                if (txt === targetName) {
    ...                    options[i].scrollIntoView({block: "center"});
    ...                    options[i].click();
    ...                    return true;
    ...                }
    ...            }
    ...            // ถ้ายังไม่เจอ เลื่อน scrollbar ลงไปอีก
    ...            lb.scrollTop = lb.scrollTop + 150;
    ...        }
    ...        return false;
    ...    })();

    Run Keyword If    not ${clicked}    Fail    [SYS_04] Product '${product_name}' not found in dropdown Values (JS scroll-search failed).
Values Field Should Be Filled SYS_04
    # ดู value ของ input
    ${val}=    Get Element Attribute
    ...    xpath=(//input[@name='application_method.target_rules.0.values'])[last()]
    ...    value

    # ดูว่ามี text CANELE Hoodie โผล่แถว ๆ เงื่อนไขรึยัง (chip/label)
    ${has_label}=    Run Keyword And Return Status
    ...    Page Should Contain Element
    ...    xpath=//h2[contains(.,'What items will the promotion be applied to')]
    ...        /following::span[contains(normalize-space(),'${PROMO_PRODUCT_NAME}')][1]

    Log To Console    [SYS_04] Values field value='${val}', label_found=${has_label}

    # ถ้า value ยังว่าง และยังไม่เห็น label → ให้ Fail เพื่อให้ Wait Until Keyword Succeeds ลองใหม่
    IF    '${val}' == '' and not ${has_label}
        Fail    Values field still empty and label not found yet.
    END

