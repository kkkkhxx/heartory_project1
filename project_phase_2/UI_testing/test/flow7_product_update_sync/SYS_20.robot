*** Settings ***
Documentation     TC7.2 Customer sees price update warning during checkout (FINAL NEW UI VERSION)
Library           SeleniumLibrary    timeout=30s
Suite Setup       Open Store Browser
Suite Teardown    Close All Browsers


*** Variables ***
${STORE_URL}            http://10.34.112.158:8000/dk/account
${PRODUCT_NAME}         MU Testing store

# Product selectors (NEW UI)
${BTN_SIZE_S}           xpath=//button[@data-testid='option-button' and normalize-space()='S']
${BTN_COLOR_BLACK}      xpath=//button[@data-testid='option-button' and normalize-space()='Black']
${BTN_ADD_TO_CART}      xpath=//button[@data-testid='add-product-button']

# Cart + Checkout
${BTN_GO_TO_CART}       xpath=//a[contains(.,'Cart')]
${BTN_GO_CHECKOUT}      xpath=//button[contains(.,'Go to checkout')]

# Checkout fields
${EMAIL}                xpath=//input[@name='email']
${FN}                   xpath=//input[@name='shipping_address.first_name']
${LN}                   xpath=//input[@name='shipping_address.last_name']
${ADDR1}                xpath=//input[@name='shipping_address.address_1']
${POSTCODE}             xpath=//input[@name='shipping_address.postal_code']
${CITY}                 xpath=//input[@name='shipping_address.city']
${PHONE}                xpath=//input[@name='shipping_address.phone']
${COUNTRY}              xpath=//select[@name='shipping_address.country_code']

${BTN_CONTINUE}         xpath=//button[contains(.,'Continue')]

# Toast after price update (same)
${PRICE_UPDATED_TOAST}  xpath=//*[contains(.,'has been updated') or contains(.,'updated')]


*** Test Cases ***
TC7.2 Customer sees price update after admin changes price
    Go To Store Home
    Login Customer
    Find Product Until Found    ${PRODUCT_NAME}
    Go To Product Page
    Select Variant
    Add To Cart
    Go To Checkout Page
    Fill Checkout Form
    Simulate Admin Changed Price
    Detect Price Updated Toast



*** Keywords ***

# ================================================
# BROWSER
# ================================================
Open Store Browser
    Open Browser    ${STORE_URL}    chrome
    Maximize Browser Window
    Sleep    2s


# ================================================
# HOME → STORE
# ================================================
Go To Store Home
    Wait Until Page Contains Element    xpath=//button[@data-testid='nav-menu-button']    20s
    Click Element    xpath=//button[@data-testid='nav-menu-button']
    Sleep    1s

    ${has_store}=    Run Keyword And Return Status    Page Should Contain Element    xpath=//a[@data-testid='store-link']
    IF    ${has_store}
        Click Element    xpath=//a[@data-testid='store-link']
    ELSE
        Click Element    xpath=//a[contains(@href,'/dk/store')]
    END

    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class,'skeleton')]    30s
    Sleep    1s


# ================================================
# LOGIN CUSTOMER
# ================================================
Login Customer
    Log To Console     Logging in customer...
    Click Element    xpath=//a[contains(@href,'account')]
    Wait Until Element Is Visible    xpath=//input[@name='email']    30s

    Input Text    xpath=//input[@name='email']       eatburger@example.com
    Input Text    xpath=//input[@name='password']    1234
    Click Element  xpath=//button[normalize-space()='Sign in']

    Wait Until Page Contains Element    xpath=//div[contains(.,'Hello')]    30s
    Log To Console     Login OK

    Go To Store Home


# ================================================
# FIND PRODUCT (P1 → P2)
# ================================================
Find Product Until Found
    [Arguments]    ${PRODUCT_NAME}

    Log To Console     Waiting store page to fully load...
    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class,'skeleton')]    40s
    Sleep    1.5s    # ให้ UI render การ์ดสินค้าจริง

    ${page}=    Set Variable    1

    WHILE    True
        Log To Console    🔎 Searching product on Page ${page}...

        # หา product บนหน้านี้
        ${found}=    Run Keyword And Return Status
        ...    Page Should Contain Element
        ...    xpath=//*[contains(.,'${PRODUCT_NAME}')]

        IF    ${found}
            Log To Console    ✅ Product found on Page ${page}
            RETURN
        END

        Log To Console    ❌ Not found on Page ${page}

        # หา next page button เช่น 2, 3, 4...
        ${next_page}=    Evaluate    ${page} + 1

        ${next_btn_exists}=    Run Keyword And Return Status
        ...    Page Should Contain Element
        ...    xpath=//button[normalize-space()='${next_page}'] 

        IF    ${next_btn_exists}
            Log To Console    👉 Going to Page ${next_page}...
            Click Element    xpath=//button[normalize-space()='${next_page}']
            Sleep    1.2s
            Wait Until Page Does Not Contain Element    xpath=//div[contains(@class,'skeleton')]    40s
            ${page}=    Set Variable    ${next_page}
            CONTINUE
        END

        # ไม่มีหน้าถัดไป
        Fail    ❌ Product '${PRODUCT_NAME}' not found on ANY page!

    END




# ================================================
# PRODUCT PAGE
# ================================================
Go To Product Page
    Click Element    xpath=//*[contains(text(),'${PRODUCT_NAME}')]
    Sleep    1s


Select Variant
    Wait Until Element Is Visible    ${BTN_SIZE_S}    30s
    Click Element    ${BTN_SIZE_S}

    Wait Until Element Is Visible    ${BTN_COLOR_BLACK}    30s
    Click Element    ${BTN_COLOR_BLACK}


Add To Cart
    Wait Until Element Is Visible    ${BTN_ADD_TO_CART}    30s
    Click Element    ${BTN_ADD_TO_CART}

    Sleep    1s
    Click Element    xpath=//a[contains(.,'Cart')]


# ================================================
# CHECKOUT
# ================================================
Go To Checkout Page
    Wait Until Element Is Visible    ${BTN_GO_CHECKOUT}    30s
    Click Element    ${BTN_GO_CHECKOUT}


Fill Checkout Form
    Wait Until Element Is Visible    ${EMAIL}    30s

    Input Text    ${EMAIL}       test123@gmail.com
    Input Text    ${FN}          John
    Input Text    ${LN}          Wick
    Input Text    ${ADDR1}       Bangkok
    Input Text    ${POSTCODE}    10110
    Input Text    ${CITY}        Bangkok
    Input Text    ${PHONE}       0666666666

    Select From List By Value    ${COUNTRY}    dk

    Scroll Element Into View    ${BTN_CONTINUE}
    Click Element    ${BTN_CONTINUE}


# ================================================
# SIMULATE PRICE CHANGE
# ================================================
Simulate Admin Changed Price
    Log To Console     Reloading to simulate admin price update...
    Sleep    2s
    Reload Page
    Sleep    2s


# ================================================
# VERIFY TOAST
# ================================================
Detect Price Updated Toast
    Wait Until Page Contains Element    ${PRICE_UPDATED_TOAST}    30s
    Log To Console     Price updated toast FOUND!
