*** Settings ***
Library           SeleniumLibrary    timeout=10s    implicit_wait=0.3
Resource          ../../config/env.robot
Suite Setup       Open Customer Browser
Suite Teardown    Close All Browsers


*** Variables ***
${LOC_USERNAME}        css=input[name="email"]
${LOC_PASSWORD}        css=input[name="password"]
${LOC_SUBMIT}          css=button[type="submit"]

${LOC_NAV_ACCOUNT}     css=a[data-testid="nav-account-link"]
${LOC_DASHBOARD_TAG}   xpath=//*[@data-testid="account-nav"]//*[contains(normalize-space(.),'Orders')]


*** Keywords ***
Open Customer Browser
    [Documentation]    เปิดเบราว์เซอร์ด้วย alias=CUSTOMER และเข้า ${CUSTOMER_URL}
    Open Browser    about:blank    ${BROWSER}    alias=CUSTOMER
    Set Window Size    ${VIEWPORT_W}    ${VIEWPORT_H}
    Go To    ${CUSTOMER_URL}
    Wait Until Element Is Visible    ${LOC_NAV_ACCOUNT}    10s

Customer Page Should Be Visible
    [Documentation]    เช็คว่าหน้า store โหลดแล้ว และมีปุ่ม Account ให้กด
    Switch Browser    CUSTOMER
    Wait Until Element Is Visible    ${LOC_NAV_ACCOUNT}    10s

Customer Login
    [Arguments]    ${user}    ${pass}
    [Documentation]    Login เป็น customer ด้วย email/password ที่ส่งเข้ามา
    Switch Browser    CUSTOMER

    # 1) เข้า homepage /dk (กันกรณีหลุดไปหน้าอื่นมาก่อน)
    Go To    ${CUSTOMER_URL}
    Customer Page Should Be Visible

    # 2) คลิกปุ่ม Account บน navbar
    Click Element    ${LOC_NAV_ACCOUNT}

    # 3) รอให้ฟอร์ม login โผล่ แล้วกรอกข้อมูล
    Wait Until Element Is Visible    ${LOC_USERNAME}    10s
    Input Text       ${LOC_USERNAME}    ${user}
    Input Text       ${LOC_PASSWORD}    ${pass}
    Click Button     ${LOC_SUBMIT}

    # 4) รอให้หน้า Account/Orders โหลด
    Wait Until Element Is Visible   ${LOC_DASHBOARD_TAG}    15s

Select Account Menu
    [Arguments]    ${menu_name}
    [Documentation]    menu_name: Profile, Addresses, Orders, Log out
    Switch Browser    CUSTOMER
    ${locator}=    Set Variable
    ...    xpath=//*[@data-testid="account-nav"]//li[normalize-space(.)='${menu_name}']
    Wait Until Element Is Visible    ${locator}    10s
    Click Element    ${locator}
