*** Settings ***
Documentation     TC3.1 – ตรวจค่าจัดส่งตามพื้นที่ 
...               Flow:
...               1) Admin login → ไปหน้า Locations & Shipping → Sweden Warehouse → ดู Manage areas ของ out/in service
...               2) Customer (eatburger) login → เลือกสินค้า dolly → Add to cart → ไป cart → Go to checkout
...               3) หน้า Shipping Address → Edit:
...                  - เลือกประเทศ Sweden → Continue → เห็น "ในพื้นที่" และราคา 5
...                  - เลือกประเทศ Germany → Continue → เห็น "นอกพื้นที่" และราคา 15
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

# ===== Admin – Locations & Shipping =====
${ADMIN_MENU_SETTINGS}              xpath=//a[contains(normalize-space(.),'Settings')]
${ADMIN_MENU_LOCATIONS_SHIPPING}    xpath=//a[contains(normalize-space(.),'Locations & Shipping')]
${SWEDEN_WAREHOUSE_VIEW_DETAILS}    xpath=//p[normalize-space(.)='Sweden Warehouse']/ancestor::div[contains(@class,'shadow-elevation-card-rest')]//a[normalize-space(.)='View details']

# ===== Shipping areas cards =====
${BTN_MENU_IN}     xpath=//p[contains(normalize-space(.),'in service shipping')]/ancestor::div[contains(@class,'flex flex-row')][1]//button[@aria-haspopup='menu']
${BTN_MENU_OUT}    xpath=//p[contains(normalize-space(.),'out of service shipping')]/ancestor::div[contains(@class,'flex flex-row')][1]//button[@aria-haspopup='menu']
${LINK_MANAGE_AREAS}    xpath=//a[normalize-space(.)='Manage areas']
${TEXT_AREAS_TITLE}     Areas

# ===== Storefront / Customer =====
${BTN_ACCOUNT_OR_LOGIN}             xpath=//a[contains(.,'Account') or contains(.,'Sign in') or contains(.,'Log in')] | //button[contains(.,'Account') or contains(.,'Sign in') or contains(.,'Log in')]
${LOGIN_EMAIL_INPUT}                css=input[name="email"]
${LOGIN_PASSWORD_INPUT}             css=input[type="password"]
${LOGIN_SUBMIT_BTN}                 xpath=//button[normalize-space(.)='Continue'] | //button[contains(normalize-space(.),'Sign in')]

${CARD_PRODUCT_DOLLY}               xpath=//p[@data-testid='product-title' and normalize-space(.)='dolly']/ancestor::a[1]
${BTN_ADD_TO_CART}                  xpath=//button[contains(normalize-space(.),'Add')]
${BTN_OPEN_CART}                    css=a[data-testid="nav-cart-link"]
${BTN_SUBMIT_ADDRESS}               xpath=//button[@data-testid='submit-address-button']
${BTN_EDIT_SHIPPING_ADDRESS}        xpath=(//button[normalize-space(.)='Edit'])[1]
${PAGE_BODY}                        xpath=//body

${INPUT_FIRST_NAME}                 xpath=//input[contains(@name,'first_name')]
${INPUT_LAST_NAME}                  xpath=//input[contains(@name,'last_name')]
${INPUT_ADDRESS_1}                  xpath=//input[@name='shipping_address.address_1']
${INPUT_CITY}                       xpath=//input[contains(@name,'city')]
${INPUT_POSTAL_CODE}                xpath=//input[contains(@name,'postal')]
${INPUT_PHONE}                      xpath=//input[contains(@name,'phone')]
${SELECT_COUNTRY}                   xpath=//select[contains(@name,'country') or contains(@id,'country')]


*** Test Cases ***
TC3_1_Happy_Shipping_Fee_By_Area
    [Documentation]    Admin ตรวจ manage areas และ customer ตรวจราคาส่งตามประเทศ Sweden/Germany
    # ----- Admin -----
    Admin Login
    Admin Go To Sweden Warehouse
    Admin View Manage Areas

    # ----- Customer -----
    Customer Login As Eatburger
    Customer Start Checkout With Dolly

    # Sweden = ในพื้นที่ / 5
    Fill Or Edit Shipping Address Country    Sweden
    ${txt_se}=    Get DeliveryPage Text
    Assert InArea Five    ${txt_se}

    # Germany = นอกพื้นที่ / 15
    Fill Or Edit Shipping Address Country    Germany
    ${txt_de}=    Get DeliveryPage Text
    Assert OutArea Fifteen    ${txt_de}


*** Keywords ***
# ======================= COMMON =======================
Open All Browsers
    Open Browser    about:blank    chrome
    Maximize Browser Window
    Set Selenium Timeout  25s
    Set Selenium Speed    0.3s

Click Element With Retry
    [Arguments]    ${locator}
    Wait Until Keyword Succeeds    3x    2s    Click Element    ${locator}

Click Checkout Button
    ${has_testid}=    Run Keyword And Return Status    Wait Until Element Is Visible    css=[data-testid="checkout-button"]    8s
    IF    ${has_testid}
        Click Element With Retry    css=[data-testid="checkout-button"]
        RETURN
    END

    ${CHECKOUT_LOCATOR}=    xpath=(//a[contains(@href,'/checkout')] | //button[contains(.,'Checkout')])
    Click Element With Retry    ${CHECKOUT_LOCATOR}


# ======================= ADMIN =======================
Admin Login
    Go To    ${ADMIN_LOGIN_URL}
    Wait Until Element Is Visible    xpath=//input[@name='email']    20s
    Input Text    xpath=//input[@name='email']    ${ADMIN_USER}
    Input Text    xpath=//input[@name='password']    ${ADMIN_PASS}
    Click Button   xpath=//button[contains(.,'Continue with Email')]
    Wait Until Page Contains Element    ${ADMIN_MENU_SETTINGS}    30s

Admin Go To Sweden Warehouse
    Click Element    ${ADMIN_MENU_SETTINGS}
    Wait Until Element Is Visible    ${ADMIN_MENU_LOCATIONS_SHIPPING}
    Click Element    ${ADMIN_MENU_LOCATIONS_SHIPPING}
    Wait Until Element Is Visible    ${SWEDEN_WAREHOUSE_VIEW_DETAILS}
    Click Element    ${SWEDEN_WAREHOUSE_VIEW_DETAILS}
    Wait Until Page Contains Element    xpath=//h1[normalize-space(.)='Sweden Warehouse']

Admin View Manage Areas
    Wait Until Page Contains Element    xpath=//h2[normalize-space(.)='Shipping']
    Scroll Element Into View            xpath=//h2[normalize-space(.)='Shipping']
    Sleep    1s

    # ----- in service -----
    Wait Until Element Is Visible    ${BTN_MENU_IN}
    Scroll Element Into View         ${BTN_MENU_IN}
    Click Element With Retry         ${BTN_MENU_IN}
    Wait Until Element Is Visible    ${LINK_MANAGE_AREAS}
    Click Element With Retry         ${LINK_MANAGE_AREAS}
    Wait Until Page Contains         ${TEXT_AREAS_TITLE}
    Go Back
    Sleep    1s

    # ----- out of service -----
    Wait Until Element Is Visible    ${BTN_MENU_OUT}
    Scroll Element Into View         ${BTN_MENU_OUT}
    Click Element With Retry         ${BTN_MENU_OUT}
    Wait Until Element Is Visible    ${LINK_MANAGE_AREAS}
    Click Element With Retry         ${LINK_MANAGE_AREAS}
    Wait Until Page Contains         ${TEXT_AREAS_TITLE}
    Go Back


# ======================= CUSTOMER =======================
Customer Login As Eatburger
    Go To    ${STORE_HOME_URL}
    Wait Until Element Is Visible    ${BTN_ACCOUNT_OR_LOGIN}
    Click Element With Retry         ${BTN_ACCOUNT_OR_LOGIN}
    Wait Until Element Is Visible    ${LOGIN_EMAIL_INPUT}
    Input Text       ${LOGIN_EMAIL_INPUT}       ${CUSTOMER_EMAIL}
    Input Text       ${LOGIN_PASSWORD_INPUT}    ${CUSTOMER_PASSWORD}
    Click Element With Retry     ${LOGIN_SUBMIT_BTN}
    Sleep    1.5s

Customer Start Checkout With Dolly
    Go To    ${STORE_STORE_URL}
    Wait Until Page Contains Element    xpath=//h1[@data-testid='store-page-title']

    ${page_buttons}=    Get WebElements    xpath=//div[@data-testid='product-pagination']//button
    ${total_pages}=     Get Length    ${page_buttons}

    FOR    ${idx}    IN RANGE    ${total_pages}
        ${found}=    Run Keyword And Return Status
        ...    Wait Until Page Contains Element    ${CARD_PRODUCT_DOLLY}    4s
        IF    ${found}
            Click Element With Retry    ${CARD_PRODUCT_DOLLY}
            Exit For Loop
        END

        ${next_page}=    Evaluate    ${idx} + 2
        ${has_next}=     Run Keyword And Return Status
        ...    Page Should Contain Element    xpath=//button[normalize-space(.)='${next_page}']
        IF    ${has_next}
            Click Element With Retry    xpath=//button[normalize-space(.)='${next_page}']
            Sleep    0.8s
        END
    END

    Wait Until Element Is Visible    ${BTN_ADD_TO_CART}
    Click Element With Retry         ${BTN_ADD_TO_CART}

    Click Element With Retry         ${BTN_OPEN_CART}
    Wait Until Location Contains     /cart

    Click Checkout Button
    Wait Until Location Contains     /checkout


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


Get DeliveryPage Text
    ${txt}=    Get Text    ${PAGE_BODY}
    RETURN    ${txt}


Assert InArea Five
    [Arguments]    ${page_txt}
    Should Contain    ${page_txt}    ในพื้นที่
    Should Contain    ${page_txt}    5

Assert OutArea Fifteen
    [Arguments]    ${page_txt}
    Should Contain    ${page_txt}    นอกพื้นที่
    Should Contain    ${page_txt}    15
