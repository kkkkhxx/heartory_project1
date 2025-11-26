*** Settings ***
Library           SeleniumLibrary    run_on_failure=Capture Page Screenshot
Library           String
Resource          ../../config/env.robot

*** Variables ***
${STORE_URL}                 http://10.34.112.158:8000/dk/store
${CART_URL}                  http://10.34.112.158:8000/dk/cart

# Menu & Navigation
${MENU_BUTTON}               xpath=//button[contains(.,'Menu')]
${STORE_LINK}                xpath=//a[@data-testid='store-link' and contains(.,'Store')]

# Product selection
${PRODUCT_MU_TEST_STORE}     xpath=//p[@data-testid='product-title' and contains(.,'MU Testing store')]/ancestor::a[1]
${SIZE_M_BUTTON}             xpath=//button[@data-testid='option-button' and normalize-space()='M']
${COLOR_WHITE_BUTTON}        xpath=//button[@data-testid='option-button' and normalize-space()='White']
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


*** Keywords ***
Wait Until Store Products Loaded
    [Documentation]    รอให้ skeleton หาย เพื่อให้การ์ดสินค้าขึ้นครบ
    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class,'skeleton')]    30s
    Sleep    1s

Navigate To Store Via Menu
    Wait Until Element Is Visible    ${MENU_BUTTON}    10s
    Click Element    ${MENU_BUTTON}
    Sleep    1s
    Wait Until Element Is Visible    ${STORE_LINK}    10s
    Click Element    ${STORE_LINK}
    Wait Until Store Products Loaded
    Wait Until Page Contains    All products    15s

Search Product In Current Page
    [Documentation]    หา MU Testing store ในหน้าปัจจุบัน ถ้าเจอจะ Scroll + Click แล้ว return True
    ${found}=    Run Keyword And Return Status
    ...    Wait Until Element Is Visible    ${PRODUCT_MU_TEST_STORE}    5s

    IF    ${found}
        Log To Console    Found product MU Testing store in current page
        Scroll Element Into View    ${PRODUCT_MU_TEST_STORE}
        Sleep    0.5s
        Click Element    ${PRODUCT_MU_TEST_STORE}
        Sleep    1s
        RETURN    True
    END
    Log To Console    MU Testing store not found in current page
    RETURN    False

Select Product MU Test Store
    [Documentation]    หา product MU Testing store โดยไล่ page 1,2,3,... ไปจนเจอ
    Log To Console    Selecting product MU Testing store with pagination...
    ${current_page}=    Set Variable    1
    ${max_pages}=      Set Variable    6
    # หน้าปัจจุบัน (หลังเข้าหน้า Store) = page 1
    Wait Until Store Products Loaded
    ${found}=    Search Product In Current Page
    IF    ${found}
        RETURN
    END
    # ถ้าไม่เจอ ลองเปลี่ยนหน้า 2..max_pages
    WHILE    ${current_page} < ${max_pages}
        ${next_page}=    Evaluate    ${current_page} + 1
        Log To Console    Trying page ${next_page}...
        ${next_btn_locator}=    Set Variable    xpath=//button[normalize-space()='${next_page}']
        ${next_exists}=    Run Keyword And Return Status
        ...    Wait Until Element Is Visible    ${next_btn_locator}    5s
        IF    not ${next_exists}
            Fail    Cannot find pagination button for page ${next_page}. Product MU Testing store not found.
        END
        Click Element    ${next_btn_locator}
        Sleep    1s
        Wait Until Store Products Loaded
        ${found}=    Search Product In Current Page
        IF    ${found}
            RETURN
        END
        ${current_page}=    Set Variable    ${next_page}
    END
    Fail    Product MU Testing store not found within ${max_pages} pages!

Select Size M And Color White
    [Documentation]    เลือก Size = M และ Color = White (ต้องเจอ ถ้าไม่เจอให้ fail เลย)

    # ----- เลือก Size M -----
    Wait Until Element Is Visible    ${SIZE_M_BUTTON}    10s
    Scroll Element Into View         ${SIZE_M_BUTTON}
    Sleep    0.3s
    Click Element                    ${SIZE_M_BUTTON}
    Sleep    0.5s

    # ----- เลือก Color White -----
    Wait Until Element Is Visible    ${COLOR_WHITE_BUTTON}    10s
    Scroll Element Into View         ${COLOR_WHITE_BUTTON}
    Sleep    0.3s
    Click Element                    ${COLOR_WHITE_BUTTON}
    Sleep    0.5s

Add To Cart Twice
    [Documentation]    กด Add to cart 2 ครั้ง (เพื่อล็อก Reserved = 2)
    Wait Until Element Is Visible    ${ADD_TO_CART_BUTTON}    20s
    Click Element    ${ADD_TO_CART_BUTTON}
    Sleep    1s
    Click Element    ${ADD_TO_CART_BUTTON}
    Sleep    2s

Go To Cart Page
    [Documentation]    ไปหน้า Cart จากปุ่มบน Navbar ถ้าไม่ได้ให้ใช้ URL ตรง
    ${cart_clicked}=    Run Keyword And Return Status
    ...    Click Element    ${CART_LINK}
    IF    not ${cart_clicked}
        Go To    ${CART_URL}
    END
    Wait Until Page Contains    Cart    10s

Complete Checkout Process
    [Documentation]    กรอกที่อยู่ + เลือก Shipping + Payment + Place order ให้ครบ

    # ----- Address / Shipping Address -----
    Wait Until Element Is Visible    ${CHECKOUT_BUTTON}    20s
    Click Element    ${CHECKOUT_BUTTON}

    Wait Until Element Is Visible    ${FIRST_NAME_INPUT}    20s
    Input Text    ${FIRST_NAME_INPUT}      Hammy
    Input Text    ${LAST_NAME_INPUT}       Burger
    Input Text    ${ADDRESS_INPUT}         Bangkok
    Input Text    ${CITY_INPUT}            Bangkok
    Input Text    ${POSTAL_CODE_INPUT}     10110

    ${country_selected}=    Run Keyword And Return Status
    ...    Select From List By Value    ${COUNTRY_SELECT}    dk
    IF    not ${country_selected}
        Log    Could not select country by value, please adjust locator or value
    END

    Click Element    ${CONTINUE_TO_DELIVERY}

    # ----- Delivery -----
    Wait Until Element Is Visible    ${FIRST_SHIPPING_OPTION}    20s
    Click Element    ${FIRST_SHIPPING_OPTION}
    Sleep    1s
    Click Element    ${CONTINUE_TO_PAYMENT}

    # ----- Payment + Review & Submit (แยกไปเป็น keyword ย่อย) -----
    Select Payment And Review
    Submit Order

Select Payment And Review
    [Documentation]    เลือกวิธีจ่ายเงิน แล้วไปหน้า Review (พยายามคลิก radio ให้สุดชีวิต)
    # รอให้โซน payment โผล่มาก่อน
    Wait Until Element Is Visible    ${PAYMENT_RADIOGROUP}    20s
    Scroll Element Into View         ${PAYMENT_RADIOGROUP}
    Sleep    0.5s
    # ลองคลิก radio แบบปกติก่อน
    ${clicked}=    Run Keyword And Return Status
    ...    Click Element    ${MANUAL_PAYMENT_RADIO}
    IF    not ${clicked}
        Log To Console    Normal click on payment radio failed, trying JS click...
        ${radio_el}=    Get WebElement    ${MANUAL_PAYMENT_RADIO}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${radio_el}
        Sleep    0.5s
    END
    # เผื่อมี animation / validate ก่อนปุ่มถัดไป enable
    Wait Until Element Is Enabled    ${CONTINUE_TO_REVIEW}    20s
    Scroll Element Into View         ${CONTINUE_TO_REVIEW}
    Sleep    0.3s
    Click Element    ${CONTINUE_TO_REVIEW}

Submit Order
    [Documentation]    กดปุ่ม Place order (กัน overlay nextjs-portal มาบัง)
    Wait Until Element Is Visible    ${PLACE_ORDER_BUTTON}    20s
    Wait Until Element Is Enabled    ${PLACE_ORDER_BUTTON}    20s
    Scroll Element Into View         ${PLACE_ORDER_BUTTON}
    Sleep    0.5s
    # ลองคลิกแบบปกติก่อน
    ${clicked}=    Run Keyword And Return Status
    ...    Click Element    ${PLACE_ORDER_BUTTON}
    IF    not ${clicked}
        Log To Console    Normal click on submit-order-button intercepted, trying JS click after removing overlay...
        # พยายามลบ nextjs-portal (dev overlay) ถ้ามี
        Execute Javascript    const el=document.querySelector('nextjs-portal'); if(el){el.remove();}

        Sleep    0.3s

        # ใช้ JS click ยิงตรงไปที่ปุ่ม
        ${btn}=    Get WebElement    ${PLACE_ORDER_BUTTON}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${btn}
        Sleep    0.5s
    END

Verify Order Placed Successfully
    [Documentation]    เช็คว่า Order ถูกสร้างสำเร็จจากข้อความบนหน้า Confirm
    Wait Until Page Contains    Your order was placed successfully.    30s
    Log To Console    Customer checkout successful!

Customer Full Purchase Flow
    [Documentation]    ไป Store → หา MU Testing store แบบเปลี่ยนหน้า → 2 ชิ้น → Checkout → Verify
    Navigate To Store Via Menu
    Select Product MU Test Store
    Select Size M And Color White
    Add To Cart Twice
    Go To Cart Page
    Complete Checkout Process
    Verify Order Placed Successfully
