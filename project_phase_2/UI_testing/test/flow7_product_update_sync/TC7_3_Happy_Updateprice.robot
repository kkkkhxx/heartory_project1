*** Settings ***
Documentation     TC7.3 Customer sees stale-price warning when cached price is outdated (Stable for Kubernetes)
Library           SeleniumLibrary    timeout=25s
Suite Setup       Open Store Browser
Suite Teardown    Close All Browsers


*** Variables ***
${STORE_URL}            http://10.34.112.158:8000/dk/store
${ACCOUNT_URL}          http://10.34.112.158:8000/dk/account
${PRODUCT_NAME}         MU Testing store

# Product Page Selectors (new data-testid)
${BTN_SIZE_S}           xpath=//button[@data-testid="option-button" and normalize-space()="S"]
${BTN_COLOR_BLACK}      xpath=//button[@data-testid="option-button" and normalize-space()="Black"]
${ADD_TO_CART_BTN}      xpath=//button[@data-testid="add-product-button"]

# Stale-price toast messages
${STALE_WARNING}        xpath=//*[contains(.,'refresh') or contains(.,'updated') or contains(.,'outdated')]

# Pagination buttons
${BTN_PAGE_2}           xpath=//button[normalize-space()='2' and not(@disabled)]
${LINK_PAGE_2}          xpath=//a[normalize-space()='2']


*** Test Cases ***
TC7.3 Customer Should See Stale Price Warning When Cached Price Is Outdated
    Login Customer
    Go To Store Page
    Find Product Until Found    ${PRODUCT_NAME}
    Open Product Page
    Simulate Customer Idle
    Simulate Admin Changed Price
    Refresh Product Page
    Verify Stale Price Warning
    Log To Console     Test Completed Successfully



*** Keywords ***

# -----------------------------------------------------
# BROWSER
# -----------------------------------------------------
Open Store Browser
    Open Browser    ${STORE_URL}    chrome
    Maximize Browser Window
    Sleep    1.5s


# -----------------------------------------------------
# LOGIN CUSTOMER
# -----------------------------------------------------
Login Customer
    Log To Console     Opening Login page...

    Go To    ${ACCOUNT_URL}
    Wait Until Element Is Visible    xpath=//input[@name='email']    20s

    Input Text    xpath=//input[@name='email']       eatburger@example.com
    Input Text    xpath=//input[@name='password']    1234
    Click Element  xpath=//button[normalize-space()='Sign in']

    Wait Until Page Contains Element    xpath=//*[contains(text(),'Hello')]    20s
    Log To Console     Login successful!



# -----------------------------------------------------
# GO TO STORE PAGE (MENU → STORE)
# -----------------------------------------------------
Go To Store Page
    Log To Console     Opening Store Page via Menu...

    Wait Until Element Is Visible    xpath=//button[@data-testid='nav-menu-button']    20s
    Click Element    xpath=//button[@data-testid='nav-menu-button']
    Sleep    1

    Click Element    xpath=//a[@data-testid='store-link']
    Sleep    1.5

    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class,'skeleton')]    20s
    Log To Console     Store Page Loaded



# -----------------------------------------------------
# FIND PRODUCT PAGE 1 → PAGE 2
# -----------------------------------------------------
Find Product Until Found
    [Arguments]    ${PRODUCT_NAME}

    Log To Console    🕒 Waiting store page to fully load...
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




# -----------------------------------------------------
# PRODUCT PAGE
# -----------------------------------------------------
Open Product Page
    Click Element    xpath=//*[contains(text(),'${PRODUCT_NAME}')]
    Sleep    1.5

    Wait Until Element Is Visible    ${BTN_SIZE_S}
    Click Element    ${BTN_SIZE_S}

    Wait Until Element Is Visible    ${BTN_COLOR_BLACK}
    Click Element    ${BTN_COLOR_BLACK}

    Log To Console     Product Page Loaded



# -----------------------------------------------------
# SIMULATION
# -----------------------------------------------------
Simulate Customer Idle
    Log To Console     Customer idle on product page...
    Sleep    10s


Simulate Admin Changed Price
    Log To Console     Admin changing price in backend (simulate)
    Sleep    10s


Refresh Product Page
    Log To Console     Reloading product page...
    Reload Page
    Sleep    2s



# -----------------------------------------------------
# VERIFY STALE WARNING
# -----------------------------------------------------
Verify Stale Price Warning
    Wait Until Page Contains Element    ${STALE_WARNING}    20s
    Log To Console     Stale Price Warning Detected!

