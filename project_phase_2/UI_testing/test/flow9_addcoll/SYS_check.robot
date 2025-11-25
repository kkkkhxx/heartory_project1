*** Settings ***
Documentation     TC: Customer login → go to store → open category → verify product
Library           SeleniumLibrary    timeout=30s
Suite Setup       Open Store Browser
Suite Teardown    Close All Browsers


*** Variables ***
${STORE_URL}            http://10.34.112.158:8000/dk/account
${CATEGORY_NAME}        Merch
${PRODUCT_EXPECTED}     sikkhim

${INPUT_EMAIL}          xpath=//input[@name='email']
${INPUT_PASSWORD}       xpath=//input[@name='password']
${BTN_SIGNIN}           xpath=//button[@data-testid='sign-in-button']

# Navigation buttons
${BTN_NAV_MENU}         xpath=//button[@data-testid='nav-menu-button']
${LINK_STORE}           xpath=//a[@data-testid='store-link']
${FALLBACK_STORE}       xpath=//a[contains(@href,'/dk/store')]

# Category link in footer
${FOOTER_CATEGORY_LINK}    xpath=//a[@data-testid='category-link' and normalize-space()='${CATEGORY_NAME}']

# Product title selector
${PRODUCT_TITLE}        xpath=//p[@data-testid='product-title' and normalize-space()='${PRODUCT_EXPECTED}']


*** Test Cases ***
TC_Check_Product_In_Store_With_Login
    Go To Store Home
    Login Customer
    Go To Store Home
    Scroll To Footer Categories
    Open Category In Footer    ${CATEGORY_NAME}
    Verify Product In Category    ${PRODUCT_EXPECTED}



*** Keywords ***

# ================================================
# OPEN BROWSER
# ================================================
Open Store Browser
    Open Browser    ${STORE_URL}    chrome
    Maximize Browser Window
    Sleep    2s


# ================================================
# NAVIGATE TO STORE HOME
# ================================================
Go To Store Home
    Wait Until Element Is Visible    ${BTN_NAV_MENU}    30s
    Click Element    ${BTN_NAV_MENU}
    Sleep    1s

    ${has_store}=    Run Keyword And Return Status    Page Should Contain Element    ${LINK_STORE}
    IF    ${has_store}
        Click Element    ${LINK_STORE}
    ELSE
        Click Element    ${FALLBACK_STORE}
    END

    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class,'skeleton')]    30s
    Sleep    1s


# ================================================
# LOGIN CUSTOMER (อิงจาก TC7.2)
# ================================================
Login Customer
    Log To Console      Logging in customer...
    Click Element    xpath=//a[contains(@href,'account')]

    Wait Until Element Is Visible    ${INPUT_EMAIL}    30s
    Input Text    ${INPUT_EMAIL}       eatburger@example.com
    Input Text    ${INPUT_PASSWORD}    1234

    Wait Until Element Is Visible    ${BTN_SIGNIN}    20s
    Click Element    ${BTN_SIGNIN}

    Wait Until Page Contains Element    xpath=//div[contains(.,'Hello')]    30s
    Log To Console      Login success


# ================================================
# SCROLL TO FOOTER CATEGORIES
# ================================================
Scroll To Footer Categories
    Log To Console      Scrolling to footer...
    Execute JavaScript    window.scrollTo(0, document.body.scrollHeight);
    Sleep    2s
    Wait Until Page Contains Element    ${FOOTER_CATEGORY_LINK}    20s


# ================================================
# OPEN CATEGORY
# ================================================
Open Category In Footer
    [Arguments]    ${CATEGORY}
    ${LINK}=    Set Variable    xpath=//a[@data-testid='category-link' and normalize-space()='${CATEGORY}']
    Wait Until Element Is Visible    ${LINK}    20s
    Click Element    ${LINK}
    Sleep    1s
    Log To Console      Opened category: ${CATEGORY}


# ================================================
# VERIFY PRODUCT
# ================================================
Verify Product In Category
    [Arguments]    ${PRODUCT}
    ${PRODUCT_X}=    Set Variable    xpath=//p[@data-testid='product-title' and normalize-space()='${PRODUCT}']

    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class,'skeleton')]    20s
    Sleep    1s

    Wait Until Element Is Visible    ${PRODUCT_X}    20s
    Log To Console      Product found in category: ${PRODUCT}
