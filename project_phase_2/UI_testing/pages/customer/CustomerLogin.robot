*** Settings ***
Library           SeleniumLibrary    timeout=10s    implicit_wait=0.3
Resource          ../../config/env.robot


*** Variables ***
${CUS_LOC_USERNAME}        css=input[name="email"]
${CUS_LOC_PASSWORD}        css=input[name="password"]
${CUS_LOC_SUBMIT}          css=button[type="submit"]
${CUS_LOC_NAV_ACCOUNT}     css=a[data-testid="nav-account-link"]


*** Keywords ***
Open Customer Browser
    [Documentation]    เปิดเบราว์เซอร์ด้วย alias=CUSTOMER และเข้า ${CUSTOMER_URL}
    Open Browser    about:blank    ${BROWSER}    alias=CUSTOMER
    Set Window Size    ${VIEWPORT_W}    ${VIEWPORT_H}
    Go To    ${CUSTOMER_URL}

Customer Page Should Be Visible
    [Documentation]    เช็คว่าหน้า store โหลดแล้ว และมีปุ่ม Account ให้กด
    Switch Browser    CUSTOMER
    Wait Until Element Is Visible    ${CUS_LOC_NAV_ACCOUNT}    10s

Customer Login
    [Arguments]    ${CUS_USER_HAM}    ${CUS_PASS_HAM}
    # ให้แน่ใจว่าใช้ browser CUSTOMER
    Switch Browser    CUSTOMER

    # ถ้าต้องการเริ่มจากหน้า store เสมอ
    Go To    ${CUSTOMER_URL}

    # เช็คว่าปุ่ม Account โผล่ = หน้า store โหลดแล้ว
    Customer Page Should Be Visible

    # กดปุ่ม Account เพื่อเปิดหน้า / popup login
    Click Element     ${CUS_LOC_NAV_ACCOUNT}

    # รอให้ช่อง email โผล่ก่อนค่อยพิมพ์
    Wait Until Element Is Visible    ${CUS_LOC_USERNAME}    10s

    # พิมพ์ email / password
    Input Text       ${CUS_LOC_USERNAME}    ${CUS_USER_HAM}
    Input Text       ${CUS_LOC_PASSWORD}    ${CUS_PASS_HAM}

    # กดปุ่ม submit ฟอร์ม login (ตัวที่คุณประกาศไว้)
    Click Button     ${CUS_LOC_SUBMIT}

    # รอให้กลับมาเห็นปุ่ม Account อีกครั้ง (ใน state logged in)
    Wait Until Element Is Visible   ${CUS_LOC_NAV_ACCOUNT}    15s

Select Account Menu
    [Arguments]    ${menu_name}
    [Documentation]    menu_name: Profile, Addresses, Orders, Log out
    Switch Browser    CUSTOMER
    ${locator}=    Set Variable
    ...    xpath=//*[@data-testid="account-nav"]//li[normalize-space(.)='${menu_name}']
    Wait Until Element Is Visible    ${locator}    10s
    Click Element    ${locator}