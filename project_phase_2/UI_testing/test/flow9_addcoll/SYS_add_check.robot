*** Settings ***
Documentation     TC: Admin should be able to ADD product into category (PASS when checkbox exists)
Library           SeleniumLibrary
Resource          ../../pages/admin/AdminLogin.robot

Suite Setup       Open Admin Browser
Suite Teardown    Close All Browsers


*** Variables ***
${ADMIN_URL}             http://10.34.112.158:9000/app/orders

# Sidebar
${BTN_PRODUCTS}          xpath=//a[contains(@href,'/app/products') and .//p[text()='Products']]
${BTN_CATEGORIES}        xpath=//a[contains(@href,'/app/categories') and .//p[text()='Categories']]

# Login
${BTN_CONTINUE_EMAIL}    xpath=//button[contains(.,'Continue with Email')]
${INPUT_EMAIL}           xpath=//input[@name='email']
${INPUT_PASSWORD}        xpath=//input[@name='password']
${BTN_SIGNIN}            xpath=//button[normalize-space()='Continue']

# Category tab
${BTN_CATEGORY_TAB}      xpath=//p[normalize-space()='Categories']
${CATEGORY_ITEM_MERCH}   xpath=//span[normalize-space()='Merch']

# Inside Merch
${BTN_CATEGORY_MENU}     xpath=//h2[normalize-space()='Products']/following::button[@aria-haspopup='menu'][1]
${BTN_ADD_PRODUCT}       xpath=//a[@role='menuitem' and contains(.,'Add')]
${INPUT_ADD_SEARCH}      xpath=//input[@type='search' and @name='q']

# Checkbox for product
${CHECKBOX_BY_TITLE}     xpath=//span[normalize-space()='sikkhim']/ancestor::tr//button[@role='checkbox']


*** Keywords ***
Open Admin Browser
    Open Browser    ${ADMIN_URL}    chrome
    Maximize Browser Window
    Sleep    1s

Go To Products Page
    Wait Until Element Is Visible    ${BTN_PRODUCTS}    20s
    Click Element    ${BTN_PRODUCTS}

Go To Categories Page
    Wait Until Element Is Visible    ${BTN_CATEGORIES}    20s
    Click Element    ${BTN_CATEGORIES}

Open Category Tab
    Wait Until Element Is Visible    ${BTN_CATEGORY_TAB}    20s
    Click Element    ${BTN_CATEGORY_TAB}

Select Category Merch
    Wait Until Element Is Visible    ${CATEGORY_ITEM_MERCH}    20s
    Click Element    ${CATEGORY_ITEM_MERCH}

Open Merch Menu
    Wait Until Element Is Visible    ${BTN_CATEGORY_MENU}    20s
    Click Element                    ${BTN_CATEGORY_MENU}
    Sleep    500ms

Click Add Inside Merch
    Wait Until Element Is Visible    ${BTN_ADD_PRODUCT}    20s
    Click Element    ${BTN_ADD_PRODUCT}

Search Product
    [Arguments]    ${KEYWORD}
    Wait Until Element Is Visible    ${INPUT_ADD_SEARCH}    20s
    Input Text    ${INPUT_ADD_SEARCH}    ${KEYWORD}
    Sleep    7s


Verify Checkbox Exists (PASS If Yes)
    ${exists}=    Run Keyword And Return Status    Page Should Contain Element    ${CHECKBOX_BY_TITLE}

    IF    ${exists}
        Log To Console    ✔ Checkbox found → PASS (Admin CAN add)
        Pass Execution    Product checkbox visible — Add is possible.
    END

    Fail    ❌ Checkbox NOT found → FAIL (Expected Add possible)


*** Test Cases ***
TC_Admin_Can_Add_Product_Into_Category
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Go To Products Page
    Go To Categories Page
    Open Category Tab
    Select Category Merch
    Open Merch Menu
    Click Add Inside Merch
    Search Product    sikkhim
    Verify Checkbox Exists (PASS If Yes)
