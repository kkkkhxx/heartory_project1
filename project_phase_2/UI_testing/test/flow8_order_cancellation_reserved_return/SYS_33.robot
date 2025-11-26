*** Settings ***
Documentation     Combined E2E Test: Admin Check -> Customer Order -> Admin Check -> Cancel
Library           SeleniumLibrary    run_on_failure=Capture Page Screenshot
Library           String
Resource          ../../pages/admin/AdminLogin.robot
Resource          ../../config/env.robot

*** Variables ***
# ==============================================================================
# ADMIN VARIABLES
${LOC_ORDERS_MENU}           xpath=//*[contains(text(),'Orders')]
${LOC_FIRST_ORDER_ROW}       xpath=//table/tbody/tr[1] 
${LOC_MENU_BUTTON}              xpath=//div[@class='flex items-center gap-x-4']/button
${LOC_CANCEL_OPTION}         xpath=//*[contains(text(),'Cancel')]
${LOC_CONTINUE_BTN}          xpath=//button[contains(.,'Continue')]
${LOC_INVENTORY_MENU}        xpath=//*[contains(text(),'Inventory')]
${LOC_INVENTORY_SEARCH}      xpath=//input[contains(@placeholder,'Search') or contains(@class,'search')]
${LOC_M_WHITE_ROW}           xpath=//tr[contains(.,'M / White')]
${LOC_M_WHITE_LINK}          xpath=//tr[contains(.,'M / White')]//a
${LOC_RESERVED_VALUE}        xpath=//tbody//tr[td[1]//text()[contains(.,'European Warehouse')]]/td[2]
${TEST_VARIANT}              M / White

# ==============================================================================
# CUSTOMER VARIABLES
# ==============================================================================
${STORE_URL}                 http://10.34.112.158:8000/dk/store
${CART_URL}                  http://10.34.112.158:8000/dk/cart
${CUSTOMER_EMAIL}            eatburger@example.com
${CUSTOMER_PASSWORD}         1234

# Menu & Navigation
${MENU_BUTTON}               xpath=//button[contains(.,'Menu')]
${STORE_LINK}                xpath=//a[@data-testid='store-link' and contains(.,'Store')]

# Login elements
${ACCOUNT_LINK}              xpath=//a[contains(.,'Account')]
${LOGIN_EMAIL_INPUT}         css=input[name="email"]
${LOGIN_PASSWORD_INPUT}      css=input[type="password"]
${LOGIN_SUBMIT_BTN}          xpath=//button[normalize-space()='Sign in']

# Product selection
${PRODUCT_MU_TEST_STORE}     xpath=//p[@data-testid='product-title' and contains(.,'MU Testing store')]/ancestor::a[1]
${SIZE_M_BUTTON}             xpath=//button[normalize-space()='M']
${COLOR_WHITE_BUTTON}        xpath=//button[normalize-space()='White']
${ADD_TO_CART_BUTTON}        xpath=//button[contains(.,'Add to cart')]

# Cart & Checkout
${CART_LINK}                 xpath=//a[@data-testid='nav-cart-link' or @data-testid='cart-link']
${CHECKOUT_BUTTON}           xpath=//button[contains(.,'Go to checkout')]
${CONTINUE_TO_DELIVERY}      xpath=//button[@data-testid='submit-address-button']
${CONTINUE_TO_PAYMENT}       xpath=//button[@data-testid='submit-delivery-option-button']
${CONTINUE_TO_REVIEW}        xpath=//button[@data-testid='submit-payment-button']
${PLACE_ORDER_BUTTON}        xpath=//button[@data-testid='submit-order-button']

# Forms
${FIRST_NAME_INPUT}          xpath=//input[contains(@name,'first_name')]
${LAST_NAME_INPUT}           xpath=//input[contains(@name,'last_name')]
${ADDRESS_INPUT}             xpath=//input[@name='shipping_address.address_1']
${CITY_INPUT}                xpath=//input[contains(@name,'city')]
${POSTAL_CODE_INPUT}         xpath=//input[contains(@name,'postal')]
${COUNTRY_SELECT}            xpath=//select[contains(@name,'country')]
${COUNTRY_DROPDOWN}          xpath=//button[contains(@id,'headlessui-listbox-button') and .//span[contains(.,'Country') or contains(.,'Country/region')]]
${COUNTRY_OPTION_FRANCE}     xpath=//li[contains(@id,'headlessui-listbox-option') and .//span[contains(.,'France')]]

# Payment/Shipping
${SHIPPING_RADIO}            xpath=//span[@data-testid='delivery-option-radio']//button[@data-testid='radio-button']
${FIRST_SHIPPING_OPTION}     xpath=(//span[@data-testid='delivery-option-radio'])[1]//button[@data-testid='radio-button']
${PAYMENT_RADIOGROUP}        xpath=//div[@role='radiogroup']
${MANUAL_PAYMENT_RADIO}      xpath=//div[@role='radiogroup']//button[@data-testid='radio-button']

*** Test Cases ***
TC8.1 Full Flow: Admin Check -> Customer Order -> Admin Check -> Cancel
    [Documentation]    ทดสอบ full loop: เช็คของ(0) -> สั่งของ -> เช็คของ(2) -> ยกเลิก -> เช็คของ(0)
    [Tags]    TC8.1    E2E    Integration

    # PART 1: Admin Login & Initial Check
    Log To Console    \n[STEP 1] Admin Initial Check
    # เปิด Admin โดยตั้งชื่อ Alias ว่า ADMIN
    Open Admin Browser With Alias    ADMIN
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Sleep    2s
    
    # เช็คของก่อนสั่ง (ควรเป็น 0)
    ${initial_reserved}=    Get Reserved Quantity With Verification
    Should Be Equal As Numbers    ${initial_reserved}    0
    Log    Reserved ก่อนยกเลิก: ${initial_reserved}

    # PART 2: Customer Order
    Log To Console    \n[STEP 2] Customer Placing Order
    # เปิด Customer โดยตั้งชื่อ Alias ว่า CUSTOMER
    Open Customer Browser With Alias    CUSTOMER
    
    Navigate To Store Via Menu
    Select Product MU Test Store
    Select Size M And Color White
    Add To Cart Twice
    Go To Cart Page
    Complete Checkout Process
    Verify Order Placed Successfully
    
    # ปิดหน้า Customer ทิ้งไปเลยเมื่อจบงาน
    Close Browser

    # PART 3: Admin Check & Cancel
    Log To Console    \n[STEP 3] Admin Verify & Cancel
    # สลับกลับมาที่หน้า Admin ที่เปิดค้างไว้
    Switch Browser    ADMIN
    
    # Refresh เพื่อเห็น Order ใหม่
    Reload Page
    Sleep    3s

    # เช็คของหลังสั่ง (ควรเป็น 2)
    ${reserved_after_order}=    Get Reserved Quantity With Verification
    Should Be Equal As Numbers    ${reserved_after_order}    2
    Log    Reserved หลังสั่งซื้อ: ${reserved_after_order}

    # ยกเลิก Order ล่าสุด
    Cancel Latest Order

    # เช็คของหลังยกเลิก (ควรกลับเป็น 0)
    ${final_reserved}=    Get Reserved Quantity With Verification
    Should Be Equal As Numbers    ${final_reserved}    0
    Log    Reserved หลังยกเลิก: ${final_reserved}

    Log    TEST TC8.1 PASSED: Flow สมบูรณ์แบบ

    [Teardown]    Close All Browsers

*** Keywords ***

# KEYWORDS: ADMIN
Open Admin Browser With Alias
    [Arguments]    ${alias_name}
    Open Browser    about:blank    chrome    alias=${alias_name}
    Maximize Browser Window
    Go To    ${ADMIN_URL}

Get Reserved Quantity With Verification
    [Documentation]    เข้าไปดู Detail และดึงค่า Reserved กลับมาหน้า List เสมอ
    # ไปที่หน้า Inventory
    Wait Until Page Contains Element    ${LOC_INVENTORY_MENU}    10s
    Click Element    ${LOC_INVENTORY_MENU}
    Sleep    2s

    # รอให้หน้า Inventory โหลดเสร็จ
    Wait Until Page Contains    Inventory    10s
    
    # หาแถวของ M / White
    Wait Until Page Contains Element    ${LOC_M_WHITE_ROW}    10s
    
    # คลิกเข้าไปดูรายละเอียด
    Click Element    ${LOC_M_WHITE_LINK}
    Sleep    2s

    # รอจนหน้าโหลดและมีตาราง Locations
    Wait Until Page Contains    European Warehouse    10s
    
    # ดึงค่า Reserved
    Wait Until Page Contains Element    ${LOC_RESERVED_VALUE}    10s
    ${reserved_text}=    Get Text    ${LOC_RESERVED_VALUE}
    Log    Reserved found: ${reserved_text}
    
    # แปลงเป็นตัวเลข
    ${reserved_qty}=    Convert To Integer    ${reserved_text}
    
    # สำคัญ: ต้องกลับไปหน้า Inventory เพื่อ reset state
    Click Element    ${LOC_INVENTORY_MENU}
    Sleep    2s
    
    RETURN    ${reserved_qty}

Cancel Latest Order
    [Documentation]    ยกเลิก Order ล่าสุด (แถวบนสุด)
    # ไปที่หน้า Orders
    Click Element    ${LOC_ORDERS_MENU}
    Wait Until Page Contains    Orders    10s
    Sleep    2s

    # Refresh หน้า 1 ครั้งเพื่อความชัวร์
    Reload Page
    Sleep    3s

    # คลิกที่ order ล่าสุด (แถวแรก)
    Wait Until Page Contains Element    ${LOC_FIRST_ORDER_ROW}    10s
    Click Element    ${LOC_FIRST_ORDER_ROW}
    Sleep    2s

    # คลิกเมนูจุด 3 จุด
    Wait Until Element Is Visible    ${LOC_MENU_BUTTON}    10s
    Scroll Element Into View         ${LOC_MENU_BUTTON}
    Sleep    0.3s

    ${clicked}=    Run Keyword And Return Status    Click Element    ${LOC_MENU_BUTTON}

    IF    not ${clicked}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${LOC_MENU_BUTTON}
    END

    Sleep    1s

    # เลือก Cancel จากเมนู
    Wait Until Page Contains Element    ${LOC_CANCEL_OPTION}    10s
    Click Element    ${LOC_CANCEL_OPTION}
    Sleep    1s

    # ยืนยันการยกเลิกโดยกด Continue
    Wait Until Page Contains Element    ${LOC_CONTINUE_BTN}    10s
    Click Element    ${LOC_CONTINUE_BTN}
    Sleep    2s

    # Refresh หน้าเพื่ออัพเดทค่า Reserved
    Reload Page
    Sleep    3s
    
    # กลับไปที่หน้า Orders อีกครั้ง
    Click Element    ${LOC_ORDERS_MENU}
    Sleep    2s

# KEYWORDS: CUSTOMER
Open Customer Browser With Alias
    [Arguments]    ${alias_name}
    Open Browser    ${STORE_URL}    chrome    alias=${alias_name}
    Maximize Browser Window
    Set Selenium Speed    0.3s
    
    # Login Flow
    Wait Until Element Is Visible    ${ACCOUNT_LINK}    20s
    Click Element    ${ACCOUNT_LINK}
    
    Wait Until Element Is Visible    ${LOGIN_EMAIL_INPUT}    10s
    Input Text    ${LOGIN_EMAIL_INPUT}    ${CUSTOMER_EMAIL}
    Input Text    ${LOGIN_PASSWORD_INPUT}    ${CUSTOMER_PASSWORD}
    Click Element    ${LOGIN_SUBMIT_BTN}
    
    Wait Until Page Contains    Account    10s
    Log    Customer logged in successfully

Navigate To Store Via Menu
    Wait Until Element Is Visible    ${MENU_BUTTON}    10s
    Click Element    ${MENU_BUTTON}
    Sleep    1s
    Wait Until Element Is Visible    ${STORE_LINK}    10s
    Click Element    ${STORE_LINK}
    Wait Until Page Contains    All products    15s

Select Product MU Test Store
    # Search logic: ลองหาหน้าปัจจุบัน ถ้าไม่เจอให้ลอง loop หน้าถัดไป
    ${product_found}=    Search Product In Current Page
    IF    ${product_found}    RETURN

    FOR    ${page_number}    IN RANGE    2    999
        Log    Searching page ${page_number}
        ${page_button}=    Set Variable    xpath=//div[@data-testid='product-pagination']/button[normalize-space()='${page_number}' and not(@disabled)]
        
        ${page_exists}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${page_button}    3s
        IF    not ${page_exists}    Exit For Loop

        Click Element    ${page_button}
        Sleep    2s
        
        ${product_found}=    Search Product In Current Page
        IF    ${product_found}    RETURN
    END
    Fail    Product MU Testing Store not found in pages 1-5

Search Product In Current Page
    FOR    ${i}    IN RANGE    2
        ${product_visible}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${PRODUCT_MU_TEST_STORE}    1s
        IF    ${product_visible}
            Scroll Element Into View    ${PRODUCT_MU_TEST_STORE}
            Click Element    ${PRODUCT_MU_TEST_STORE}
            Wait Until Page Contains    Select Size    10s
            RETURN    ${True}
        END
        Execute Javascript    window.scrollBy(0, 400)
        Sleep    0.5s
    END
    Execute Javascript    window.scrollTo(0, 0)
    RETURN    ${False}

Select Size M And Color White
    Wait Until Element Is Visible    ${SIZE_M_BUTTON}    10s
    Click Element    ${SIZE_M_BUTTON}
    Wait Until Element Is Visible    ${COLOR_WHITE_BUTTON}    10s
    Click Element    ${COLOR_WHITE_BUTTON}

Add To Cart Twice
    Wait Until Element Is Visible    ${ADD_TO_CART_BUTTON}    10s
    Click Element    ${ADD_TO_CART_BUTTON}
    Sleep    1s
    Click Element    ${ADD_TO_CART_BUTTON}
    Sleep    1s
    # Verify Cart count
    Wait Until Element Is Visible    ${CART_LINK}    5s
    ${cart_text}=    Get Text    ${CART_LINK}
    Should Contain    ${cart_text}    2

Go To Cart Page
    Go To    ${CART_URL}
    Wait Until Page Contains    Cart    30s

Complete Checkout Process
    Wait Until Element Is Visible    ${CHECKOUT_BUTTON}    30s
    Click Button    ${CHECKOUT_BUTTON}

    # Address
    Wait Until Element Is Visible    ${FIRST_NAME_INPUT}    30s
    Input Text    ${FIRST_NAME_INPUT}    test
    Input Text    ${LAST_NAME_INPUT}     test
    Input Text    ${ADDRESS_INPUT}       MU
    Input Text    ${CITY_INPUT}          Salaya
    Input Text    ${POSTAL_CODE_INPUT}   12345
    
    # Country Selection (Try-Catch style)
    Run Keyword And Ignore Error    Select From List By Label    ${COUNTRY_SELECT}    France
    Run Keyword And Ignore Error    Click Element    ${COUNTRY_DROPDOWN}
    Run Keyword And Ignore Error    Click Element    ${COUNTRY_OPTION_FRANCE}

    Click Button    ${CONTINUE_TO_DELIVERY}

    # Shipping
    Wait Until Element Is Visible    ${SHIPPING_RADIO}    30s
    Click Element    ${FIRST_SHIPPING_OPTION}
    Wait Until Element Is Enabled    ${CONTINUE_TO_PAYMENT}    30s
    Click Button    ${CONTINUE_TO_PAYMENT}

    # Payment
    Wait Until Element Is Visible    ${PAYMENT_RADIOGROUP}    30s
    Click Element    ${MANUAL_PAYMENT_RADIO}
    Wait Until Element Is Enabled    ${CONTINUE_TO_REVIEW}    30s
    Click Button    ${CONTINUE_TO_REVIEW}

    # Submit
    Wait Until Element Is Visible    ${PLACE_ORDER_BUTTON}    30s
    Click Button    ${PLACE_ORDER_BUTTON}

Verify Order Placed Successfully
    Wait Until Page Contains    Your order was placed successfully.    40s
    Sleep    5s