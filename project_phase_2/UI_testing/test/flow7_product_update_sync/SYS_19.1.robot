*** Settings ***
Documentation     Check updated price of MU Testing store after admin changed price
Library           SeleniumLibrary    timeout=30s
Suite Setup       Open Store Browser
Suite Teardown    Close All Browsers


*** Variables ***
${STORE_URL}                 http://10.34.112.158:8000/dk/account
${PRODUCT_NAME}              MU Testing store
${UPDATED_PRICE}             7

# Login UI
${LOGIN_EMAIL}               xpath=//input[@name='email']
${LOGIN_PASSWORD}            xpath=//input[@name='password']
${BTN_SIGNIN}                xpath=//button[normalize-space()='Sign in']

# Store Navigation
${BTN_MENU}                  xpath=//button[@data-testid='nav-menu-button']
${BTN_STORE_LINK}            xpath=//a[@data-testid='store-link']
${BTN_STORE_FALLBACK}        xpath=//a[contains(@href,'/dk/store')]

# Product UI
${PRODUCT_TITLE}             xpath=//p[@data-testid='product-title' and contains(.,'${PRODUCT_NAME}')]
${PRODUCT_PRICE_SELECTOR}    xpath=//span[@data-testid='product-price' and contains(., '${UPDATED_PRICE}')]


*** Test Cases ***
TC_Check_Product_Updated_Price
    Go To Store Home
    Login Customer
    Find Product Until Found    ${PRODUCT_NAME}
    Go To Product Page
    Verify Product Price Updated


*** Keywords ***

# ========================
# BROWSER
# ========================
Open Store Browser
    Open Browser    ${STORE_URL}    chrome
    Maximize Browser Window
    Sleep    2s


# ========================
# HOME
# ========================
Go To Store Home
    Wait Until Element Is Visible    ${BTN_MENU}    20s
    Click Element    ${BTN_MENU}
    Sleep    1s

    ${has_store}=    Run Keyword And Return Status    Page Should Contain Element    ${BTN_STORE_LINK}
    IF    ${has_store}
        Click Element    ${BTN_STORE_LINK}
    ELSE
        Click Element    ${BTN_STORE_FALLBACK}
    END

    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class,'skeleton')]    30s
    Sleep    1s


# ========================
# LOGIN
# ========================
Login Customer
    Click Element    xpath=//a[contains(@href,'account')]
    Wait Until Element Is Visible    ${LOGIN_EMAIL}    30s

    Input Text    ${LOGIN_EMAIL}       eatburger@example.com
    Input Text    ${LOGIN_PASSWORD}    1234

    Click Element    ${BTN_SIGNIN}
    Wait Until Page Contains Element    xpath=//div[contains(.,'Hello')]    30s

    Go To Store Home


# ========================
# FIND PRODUCT
# ========================
Find Product Until Found
    [Arguments]    ${NAME}

    Wait Until Page Does Not Contain Element    xpath=//div[contains(@class,'skeleton')]    40s
    Sleep    1s

    ${page}=    Set Variable    1

    WHILE    True
        ${found}=    Run Keyword And Return Status
        ...    Page Should Contain Element
        ...    xpath=//*[contains(.,'${NAME}')]
        IF    ${found}
            RETURN
        END

        ${next}=    Evaluate    ${page} + 1

        ${has_next}=    Run Keyword And Return Status
        ...    Page Should Contain Element
        ...    xpath=//button[normalize-space()='${next}']

        IF    ${has_next}
            Click Element    xpath=//button[normalize-space()='${next}']
            Sleep    1s
            ${page}=    Set Variable    ${next}
            CONTINUE
        END

        Fail    Product '${NAME}' not found
    END


# ========================
# PRODUCT PAGE
# ========================
Go To Product Page
    Click Element    ${PRODUCT_TITLE}
    Sleep    1s


# ========================
# CHECK PRICE
# ========================
Verify Product Price Updated
    Wait Until Element Is Visible    ${PRODUCT_PRICE_SELECTOR}    20s
    Log To Console    💰 Price updated correctly → ${UPDATED_PRICE}.00
