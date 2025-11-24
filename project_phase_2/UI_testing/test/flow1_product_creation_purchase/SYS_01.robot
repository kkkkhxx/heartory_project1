
*** Settings ***
Documentation     Automated UI Test for Flow 1: Product Creation & Purchase (SYS_01)
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
${PRODUCT_DESC}       A warm and cozy jacket
${PRODUCT_PRICE}      20


*** Test Cases ***
SYS_01 Verify Admin Can Create Product And Customer Can Purchase
    [Documentation]    ตรวจสอบว่า Admin สร้างสินค้าใหม่ ลูกค้าเห็นใน Store เพิ่มลงตะกร้า และสั่งซื้อสำเร็จ
    Admin Login
    Create New Product
    Admin Logout
    Customer Purchase Product
    Verify New Order In Admin


*** Keywords ***
Open All Browsers
    Open Browser    ${ADMIN_LOGIN_URL}    chrome
    Maximize Browser Window
    Set Selenium Speed    0.3s


# ----------------------- ADMIN LOGIN / LOGOUT -----------------------
Admin Login
    Log To Console    Logging in as Admin
    Go To    ${ADMIN_LOGIN_URL}
    Wait Until Element Is Visible    xpath=//input[@name='email']    20s
    Input Text    xpath=//input[@name='email']    ${ADMIN_USER}
    Input Text    xpath=//input[@name='password']    ${ADMIN_PASS}
    Click Button   xpath=//button[contains(.,'Continue with Email')]
    Wait Until Page Contains Element    xpath=//a[contains(.,'Products')]    30s
    Log To Console    Admin logged in.

Admin Logout
    Log To Console    Logging out as Admin
    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(.,'Logout') or contains(.,'Sign out')]
    Sleep    2s


# ----------------------- CREATE PRODUCT + INVENTORY -----------------------
Create New Product
    Log To Console    Creating new product

    # ไปหน้า Products แล้วกด Create
    Click Element    xpath=//a[contains(.,'Products')]
    Wait Until Page Contains Element    xpath=//a[contains(.,'Create')]    20s
    Click Element    xpath=//a[contains(.,'Create')]
    Wait Until Page Contains    Details    20s
    Sleep    1s

    # ===== กรอก Title =====
    Log To Console    Filling Title
    Wait Until Element Is Visible    xpath=(//input[@name='title'])[last()]    20s
    Input Text    xpath=(//input[@name='title'])[last()]    ${PRODUCT_NAME}
    Sleep    0.5s

    # ===== กรอก Description =====
    Log To Console    Filling Description
    Wait Until Element Is Visible    xpath=(//textarea[@name='description'])[last()]    20s
    Input Text    xpath=(//textarea[@name='description'])[last()]    ${PRODUCT_DESC}
    Sleep    0.5s
    Capture Page Screenshot

    # ===== ไปแท็บ Organize =====
    Log To Console    Go to Organize tab
    Click Element    xpath=(//button[@role='tab' and contains(normalize-space(.),'Organize')])[last()]
    Sleep    1s
    Capture Page Screenshot

    # ===== ไปแท็บ Variants =====
    Log To Console    Go to Variants tab
    Click Element    xpath=(//button[@role='tab' and contains(normalize-space(.),'Variants')])[last()]
    Wait Until Page Contains Element    xpath=//input[@name='variants.0.prices.eur']    30s
    Capture Page Screenshot

    # ===== ตั้งราคา + เปิด Manage inventory =====
    Set Variant Prices
    Sleep    1s
    Capture Page Screenshot

    # ===== Publish =====
    Log To Console    Publishing product
    Click Button    xpath=//button[@data-name='publish-button' or contains(.,'Publish')]
    Wait Until Page Contains    Published    30s
    Capture Page Screenshot

    # กลับไปหน้า Products แล้วใช้ keyword หา product บนทุกหน้า
    Go To    ${ADMIN_URL}products
    Find Product On Any Page    ${PRODUCT_NAME}
    Log To Console    Product created and visible in Products list.
    Capture Page Screenshot

    # ===== ตั้ง Stock (Inventory quantity = 20) =====
    Configure Inventory Items For New Product


# ----------------------- CUSTOMER FLOW -----------------------
Customer Purchase Product
    Log To Console    Customer buying product
    Go To    ${STORE_URL}

    # ----- Customer Login -----
    Wait Until Element Is Visible    xpath=//a[contains(.,'Account')]    30s
    Click Element    xpath=//a[contains(.,'Account')]
    Wait Until Element Is Visible    xpath=//input[@name='email']    20s
    Input Text    xpath=//input[@name='email']    ${CUSTOMER_USER}
    Input Text    xpath=//input[@name='password']    ${CUSTOMER_PASS}
    Click Button   xpath=//button[contains(.,'Sign in')]
    Wait Until Page Contains    Overview    30s
    Log To Console    Customer logged in.

    # ----- กลับไปหน้า Store แล้วเลือก product -----
    Go To    ${STORE_URL}
    Wait Until Page Contains    ${PRODUCT_NAME}    30s
    Click Element    xpath=//a[contains(.,'${PRODUCT_NAME}')]
    Wait Until Element Is Visible    xpath=//button[contains(.,'Add')]    30s
    Click Element    xpath=//button[contains(.,'Add')]
    Sleep    1s

    # ----- ไปหน้า cart -----
    Go To    http://10.34.112.158:8000/dk/cart
    Wait Until Page Contains    ${PRODUCT_NAME}    30s
    Log To Console    Product in cart.

    # ================= CHECKOUT FLOW ================
    Log To Console    Start checkout...
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

    # --- เลือก Country = France ---
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

    # ----- Continue to delivery -----
    Click Button    xpath=//button[@data-testid='submit-address-button']

    # ----- เลือก Standard Shipping → Continue to payment -----
    Log To Console    Select shipping method
    Wait Until Element Is Visible    xpath=//span[@data-testid='delivery-option-radio']    30s
    Click Element    xpath=(//span[@data-testid='delivery-option-radio'])[1]//button[@data-testid='radio-button']
    Sleep    0.5s
    Wait Until Element Is Enabled    xpath=//button[@data-testid='submit-delivery-option-button']    30s
    Click Button     xpath=//button[@data-testid='submit-delivery-option-button']

    # ----- เลือก Manual Payment → Continue to review -----
    Log To Console    💳 Select payment method...
    Wait Until Element Is Visible    xpath=//div[@role='radiogroup']    30s
    Click Element    xpath=//div[@role='radiogroup']//button[@data-testid='radio-button']
    Sleep    0.5s
    Wait Until Element Is Enabled    xpath=//button[@data-testid='submit-payment-button']    30s
    Click Button     xpath=//button[@data-testid='submit-payment-button']

    # ----- Review + Place order -----
    Wait Until Element Is Visible    xpath=//button[@data-testid='submit-order-button']    30s
    Click Button     xpath=//button[@data-testid='submit-order-button']

    Wait Until Page Contains    Your order was placed successfully.    40s
    Log To Console    Customer checkout successful.


# ----------------------- VERIFY ORDER IN ADMIN -----------------------
Verify New Order In Admin
    Log To Console    Verifying new order in Admin...
    Admin Login

    Click Element    xpath=//a[contains(.,'Orders')]
    Wait Until Element Is Visible    xpath=(//table//tbody//tr)[1]    40s
    Click Element    xpath=(//table//tbody//tr)[1]
    Wait Until Page Contains    ${CUSTOMER_USER}    40s

    Log To Console    New order from ${CUSTOMER_USER} is visible in Admin Orders.
    Admin Logout


# ----------------------- VARIANT PRICE + INVENTORY HELPERS -----------------------
Set Variant Prices
    Log To Console    Setting variant prices via grid...

    # รอ cell ราคา EUR แถวแรก
    Wait Until Element Is Visible    xpath=//div[@role='gridcell' and @data-row-index='0' and @data-column-index='6']    20s

    # --- ตั้งราคา EUR ---
    Log To Console    Set EUR price...
    Click Element    xpath=//div[@role='gridcell' and @data-row-index='0' and @data-column-index='6']
    Wait Until Element Is Visible    xpath=//input[@name='variants.0.prices.eur']    10s
    Press Keys       xpath=//input[@name='variants.0.prices.eur']    CTRL+A
    Press Keys       xpath=//input[@name='variants.0.prices.eur']    BACKSPACE
    Input Text       xpath=//input[@name='variants.0.prices.eur']    ${PRODUCT_PRICE}
    Press Keys       xpath=//input[@name='variants.0.prices.eur']    ENTER
    Sleep    0.5s

    # --- ตั้งราคา USD (ถ้ามี) ---
    Log To Console    Set USD price (if present)...
    Run Keyword And Ignore Error    Set USD Price

    # --- เปิด checkbox Manage inventory ---
    Log To Console    Enable manage inventory for variant...
    Run Keyword And Ignore Error
    ...    Click Element
    ...    xpath=//button[@role='checkbox' and @data-field='variants.0.manage_inventory']
    Sleep    0.5s


Set USD Price
    Click Element    xpath=//div[@role='gridcell' and @data-row-index='0' and @data-column-index='7']
    Wait Until Element Is Visible    xpath=//input[@name='variants.0.prices.usd']    10s
    Press Keys       xpath=//input[@name='variants.0.prices.usd']    CTRL+A
    Press Keys       xpath=//input[@name='variants.0.prices.usd']    BACKSPACE
    Input Text       xpath=//input[@name='variants.0.prices.usd']    ${PRODUCT_PRICE}
    Press Keys       xpath=//input[@name='variants.0.prices.usd']    ENTER
    Sleep    0.5s


Configure Inventory Items For New Product
    Log To Console    Configuring inventory items for ${PRODUCT_NAME}

    # ใช้ keyword หา product บนทุกหน้า (เผื่อไปอยู่หน้า 2)
    Find Product On Any Page    ${PRODUCT_NAME}

    # ตอนนี้อยู่หน้าที่มี product แล้ว → คลิกเข้า edit product
    Click Element    xpath=//tr[.//a[contains(normalize-space(.),'${PRODUCT_NAME}')]]
    Wait Until Page Contains    Variants    20s

    # ===== ตั้งค่า Shipping profile ให้เป็น Default =====
    Configure Shipping Profile For Product

    # ===== คลิกแถว Default variant เพื่อไปหน้า Variant detail =====
    Log To Console    Open Default variant row
    Wait Until Element Is Visible
    ...    xpath=//tbody//tr[.//td[contains(normalize-space(.),'Default variant')]]
    ...    20s
    Click Element
    ...    xpath=//tbody//tr[.//td[contains(normalize-space(.),'Default variant')]]

    # รอหน้า variant detail
    Wait Until Page Contains    Inventory items    20s

    # ===== เปิดเมนูสามจุดของการ์ด Inventory items แล้วเลือก Manage inventory items =====
    Log To Console    Open Manage inventory items menu
    Click Element
    ...    xpath=//h2[contains(.,'Inventory items')]/following::button[contains(@aria-haspopup,'menu')][1]

    Wait Until Element Is Visible
    ...    xpath=//div[@role='menu']//*[contains(normalize-space(.),'Manage inventory items')]
    ...    10s
    Click Element
    ...    xpath=//div[@role='menu']//*[contains(normalize-space(.),'Manage inventory items')]

    # ===== หน้า manage-items =====
    Log To Console    Select 2nd inventory item in dropdown

    # รอให้ quantity field โผล่
    Wait Until Element Is Visible    xpath=//input[@name='inventory.0.required_quantity']    20s

    # เปิด dropdown Item
    Click Element    xpath=//input[@name='inventory.0.inventory_item_id']/parent::div
    Sleep    0.5s

    # เลือก option ตัวที่ 2
    Wait Until Element Is Visible
    ...    xpath=(//div[@role='listbox']//div[@role='option'])[2]
    ...    10s
    Click Element
    ...    xpath=(//div[@role='listbox']//div[@role='option'])[2]
    Sleep    0.5s

    # ตั้ง Quantity = 20 แล้ว Save
    Log To Console    Set inventory quantity to 20
    Press Keys    xpath=//input[@name='inventory.0.required_quantity']    CTRL+A
    Press Keys    xpath=//input[@name='inventory.0.required_quantity']    BACKSPACE
    Input Text    xpath=//input[@name='inventory.0.required_quantity']    20

    Click Button  xpath=//button[normalize-space()='Save']

    Wait Until Page Contains    Inventory items    20s
    Log To Console    Inventory item (option 2) with quantity 20 has been set.
    Go To    ${ADMIN_URL}products


Configure Shipping Profile For Product
    Log To Console    Configure shipping profile to default

    # รอ card "Shipping configuration"
    Wait Until Element Is Visible
    ...    xpath=//h2[contains(normalize-space(.),'Shipping configuration')]
    ...    20s

    # ปุ่มสามจุด
    Click Element
    ...    xpath=//h2[contains(normalize-space(.),'Shipping configuration')]/following::button[contains(@aria-haspopup,'menu')][1]

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
    ...    xpath=//h2[contains(normalize-space(.),'Shipping configuration')]
    ...    20s

    Log To Console    Shipping profile set to default for ${PRODUCT_NAME}.


# ----------------------- HELPERS -----------------------
Find Product On Any Page
    [Arguments]    ${PRODUCT_NAME}

    Log To Console    🔎 Searching product on Page 1...
    # รอให้ skeleton/loading หายก่อน
    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class,'skeleton')]    20s

    ${found_page1}=    Run Keyword And Return Status
    ...    Page Should Contain Element
    ...    xpath=//*[contains(text(),'${PRODUCT_NAME}')]

    IF    ${found_page1}
        Log To Console    ✅ Product found on Page 1
        RETURN
    END

    Log To Console    ❌ Not on Page 1 → click Next

    # ถ้าไม่เจอ ให้กดปุ่ม Next (หรือปุ่มเลข 2 ถ้าเค้าใช้เลข)
    Wait Until Element Is Visible
    ...    xpath=//button[normalize-space()='Next' or normalize-space()='2']
    ...    20s
    Click Element
    ...    xpath=//button[normalize-space()='Next' or normalize-space()='2']
    Sleep    1s

    # รอให้หน้า 2 โหลดเสร็จ
    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class,'skeleton')]    20s

    ${found_page2}=    Run Keyword And Return Status
    ...    Page Should Contain Element
    ...    xpath=//*[contains(text(),'${PRODUCT_NAME}')]

    Should Be True    ${found_page2}    msg=❌ Product not found on Page 2!
    Log To Console    ✅ Found product on Page 2

