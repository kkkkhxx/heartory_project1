*** Settings ***
Library           SeleniumLibrary    timeout=10s    implicit_wait=0.3
Resource          ../../config/Env.robot
Resource          ../../pages/admin/AdminLogin.robot
Suite Setup       Open Admin Browser
Suite Teardown    Close All Browsers

*** Variables ***
# ===== TODO: ปรับให้ตรง DOM ของคุณ =====
# Login (หน้า Admin)
${ADMIN_LOGIN_USER}        css=input[name="email"]                         # ช่องยูสเซอร์
${ADMIN_LOGIN_PASS}        css=input[name="password"]                      # ช่องรหัสผ่าน
${ADMIN_LOGIN_BTN}         xpath=//button[normalize-space(.)="Continue with Email"]       # ปุ่มล็อกอิน
${ADMIN_DASH_TAG}          xpath=//aside//*[contains(normalize-space(.),"Orders")]

# เมนู Orders
${ADMIN_MENU_ORDERS}       xpath=//a[contains(normalize-space(.),"Orders")]   # เมนู Orders

# ตาราง Orders (ต้องมีคอลัมน์ Fulfillment)
# แนะนำ: ใส่ data-testid ในหน้าเว็บจริง แล้วอ้างด้วย [data-testid="orders-table"]
${ORDERS_TABLE}            xpath=//table[contains(@class,"text-ui-fg-subtle txt-compact-small relative w-full")]

# แถวแรกที่คอลัมน์ Fulfillment เป็น "Not fulfilled"
# ${ROW_FIRST_NOT_FULFILLED}    xpath=(//table[.//th or .//thead]//tr[.//td[contains(normalize-space(.),"Not fulfilled")]])[1]
# แถวแรกที่ Not fulfilled และมี Order Total (ไม่เป็น '-')
${ROW_FIRST_NOT_FULFILLED}    xpath=(//table[.//th[normalize-space(.)='Fulfillment'] and .//th[normalize-space(.)='Order Total']]//tbody/tr[contains(normalize-space(.//td[count(preceding-sibling::td)=count(ancestor::table[1]//th[normalize-space(.)='Fulfillment']/preceding-sibling::th)]),'Not fulfilled') and normalize-space(.//td[count(preceding-sibling::td)=count(ancestor::table[1]//th[normalize-space(.)='Order Total']/preceding-sibling::th)])!='-'])[1]

# เซลล์ Order Total ของแถวนั้น
${ORDER_TOTAL_TD}    Set Variable    xpath=${ROW_FIRST_NOT_FULFILLED}//td[count(preceding-sibling::td)=count(ancestor::table[1]//th[normalize-space(.)='Order Total']/preceding-sibling::th)]


# หน้า Order detail – โซน "Unfulfilled Items" และปุ่ม/ทริกเกอร์ Radix (ตัวอย่าง)
${SECTION_UNFULFILLED}      xpath=//*[self::section or self::div][.//h2[normalize-space(.)="Unfulfilled Items"]]
# ใช้ [name()='svg'] เพื่อกันเคส SVG namespace
${BTN_UNFULFILLED_ICON}    xpath=(//*[self::section or self::div][ .//h2[normalize-space(.)='Unfulfilled Items'] ][ not(ancestor::aside) ])//*[normalize-space(.)='Awaiting fulfillment']/ancestor::*[self::div or self::section][1]//button[.//*[name()='svg']][not(ancestor::aside)][last()]
${PANEL_ANY}                xpath=//*[@role='menu' or @role='listbox' or @data-radix-popper-content or contains(@data-state,'open')]

# ภายใน Modal "Create Fulfillment"
${MODAL_FULFILLMENT}       xpath=//*[@role="dialog"]
${DROP_LOCATION_INPUT}     xpath=(//*[@role="dialog"]//div[.//*[normalize-space(.)="Location"]])//*[@role="combobox"][1]
${OPT_FIRST_IN_LIST}       xpath=(//*[@role="option" or @data-radix-collection-item])[1]
${DROP_SHIPPING_METHOD}    xpath=(//*[@role="combobox" or @data-testid="shipping-method-select"])[1]
${OPT_EXPRESS_SHIPPING}    xpath=//*[contains(@role,"option") and normalize-space(.)="Express Shipping"]
${BTN_CREATE_FULFILLMENT}  xpath=//button[normalize-space(.)="Create Fulfillment"]

# Toast / สถานะสำเร็จ
# แนะนำ: ใช้ data-testid ให้เสถียรกว่า
${ADMIN_TOAST_SUCCESS}     css=.toast.toast-success, [data-testid="toast-success"]
${ADMIN_TOAST_ERROR}       css=.toast.toast-error, [data-testid="toast-error"]
# Indicators หลัง Create Fulfillment
${BADGE_AWAITING}          xpath=(//*[normalize-space(.)='Awaiting fulfillment'][not(ancestor::aside)])[1]
${BADGE_FULFILLED}         xpath=(//*[contains(@class,'badge') and normalize-space(.)='Fulfilled' or normalize-space(.)='Shipped'])[1]
${MODAL_ANY}               xpath=//*[@role='dialog']


# ====== เพิ่มเติมสำหรับเมนู ======
${MENU_FULFILL_ITEMS}      xpath=(//*[@role='menu' or @role='listbox']//*[normalize-space(translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'))='fulfill items'])[1]

*** Keywords ***
Admin Open Orders Page
    [Documentation]    เข้าเมนู Orders
    Switch Browser    ADMIN
    Click Element     ${ADMIN_MENU_ORDERS}
    Wait Until Element Is Visible    ${ORDERS_TABLE}    10s

Admin Open First Not Fulfilled Order
    [Documentation]    เปิดออเดอร์แรกที่คอลัมน์ Fulfillment เป็น "Not fulfilled"
    Wait Until Element Is Visible    ${ROW_FIRST_NOT_FULFILLED}    10s
    Click Element     ${ROW_FIRST_NOT_FULFILLED}

# ====== ปรับ keyword นี้ให้สกรอลกลางจอ + กัน header ทับ ======
Scroll Section Unfulfilled Into View
    [Documentation]    เลื่อนให้ส่วน Unfulfilled Items อยู่กลางจอ + กัน sticky header
    Wait Until Page Contains Element    ${SECTION_UNFULFILLED}    15s
    # ใช้คีย์เวิร์ดที่รับ locator เป็นสตริง เพื่อตัดปัญหา WebElement
    Scroll Element Into View            ${SECTION_UNFULFILLED}
    Sleep    200ms
    Execute Javascript    window.scrollBy(0, -80);

Click Element Safely
    [Arguments]    ${locator}
    Wait Until Keyword Succeeds    5x    1s    Element Should Be Visible    ${locator}
    ${ok}=    Run Keyword And Return Status    Click Element    ${locator}
    Run Keyword If    not ${ok}    Click Via JS    ${locator}

Click Via JS
    [Arguments]    ${locator}
    # ใช้ driver.find_element ผ่าน SeleniumLibrary JS bridge เพื่อเลี่ยงส่ง WebElement จากฝั่ง Robot
    Execute Javascript    return window.robotReady = true;
    ${el}=    Get WebElement    ${locator}
    # ถ้ายังชน ให้คลิกด้วย center point แทน (ทางเลือก)
    ${ok}=    Run Keyword And Return Status    Execute Javascript    arguments[0].click();    ${el}
    Run Keyword If    not ${ok}    Click Element    ${locator}

# ====== คลิกปุ่มที่มี svg ภายในโซน Unfulfilled ======
Open Unfulfilled Action Trigger
    [Documentation]    คลิกปุ่ม (มี svg) ภายในโซน Unfulfilled Items เพื่อเปิดเมนู/ตัวเลือก
    Scroll Section Unfulfilled Into View
    Wait Until Element Is Visible    ${BTN_UNFULFILLED_ICON}    5s
    ${ok}=    Run Keyword And Return Status    Click Element    ${BTN_UNFULFILLED_ICON}
    Run Keyword If    not ${ok}    Click Via JS    ${BTN_UNFULFILLED_ICON}
    Wait Until Page Contains Element    ${PANEL_ANY}    5s

# ====== ถ้าเปิดเป็นเมนูก่อน ให้เลือก Fulfill items เพื่อเปิดโมดัล ======
Open Fulfill Modal If Needed
    [Documentation]    คลิก "Fulfill items" หรือออปชันแรก เพื่อเปิดโมดัลถ้ายังไม่เปิด
    ${modal_ready}=    Run Keyword And Return Status    Page Should Contain Element    ${MODAL_FULFILLMENT}
    Run Keyword If    ${modal_ready}    Return From Keyword

    ${has_menu}=    Run Keyword And Return Status    Page Should Contain Element    ${MENU_FULFILL_ITEMS}
    Run Keyword If    ${has_menu}    Click Element    ${MENU_FULFILL_ITEMS}
    Run Keyword If    not ${has_menu}    Click Element    ${OPT_FIRST_IN_LIST}

    Wait Until Page Contains Element    ${MODAL_FULFILLMENT}    7s

Open Location Dropdown (In Fulfillment Modal)
    [Documentation]    เปิด dropdown ของฟิลด์ Location ภายในโมดัล Fulfillment (ลองปุ่มก่อน แล้วค่อย fallback combobox)
    Wait Until Page Contains Element    ${MODAL_FULFILLMENT}    10s

    # ลองคลิกปุ่มก่อน (ตาม DOM ในรูป)
    ${has_btn}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${DROP_LOCATION_INPUT}    2s
    Run Keyword If    ${has_btn}    Run Keywords
    ...    Click Element    ${DROP_LOCATION_INPUT}
    ...    AND    Wait Until Page Contains Element    ${PANEL_ANY}    5s
    Run Keyword If    ${has_btn}    Return From Keyword

    # Fallback: ถ้าเป็น combobox จริง
    Wait Until Element Is Visible    ${DROP_LOCATION_INPUT}    5s
    Click Element    ${DROP_LOCATION_INPUT}
    Wait Until Page Contains Element    ${PANEL_ANY}    5s

Select Location In Dropdown
    [Arguments]    ${name}=European Warehouse
    ${target}=    Set Variable If    '${name}'!=''    xpath=//*[contains(@role,'option') and normalize-space(.)='${name}']    ${OPT_FIRST_IN_LIST}
    ${has_named}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${target}    2s
    Run Keyword If    ${has_named}        Click Element    ${target}
    Run Keyword If    not ${has_named}    Click Element    ${OPT_FIRST_IN_LIST}

Verify Fulfillment Succeeded
    [Documentation]    แพสเมื่อพบ "อย่างน้อยหนึ่ง" จาก: toast success / โมดัลปิด / badge Awaiting หาย / มีคำว่า Shipped/Fulfilled
    # รอให้โมดัลปิดก่อน (ถ้าปิด)
    Run Keyword And Ignore Error    Wait Until Page Does Not Contain Element    ${MODAL_ANY}    10s

    Wait Until Keyword Succeeds    10x    1s    Check Any Success Indicator

Check Any Success Indicator
    ${ok1}=    Run Keyword And Return Status    Page Should Contain Element         ${ADMIN_TOAST_SUCCESS}
    ${ok2}=    Run Keyword And Return Status    Page Should Not Contain Element     ${BADGE_AWAITING}
    ${ok3}=    Run Keyword And Return Status    Page Should Contain Element         ${BADGE_FULFILLED}
    ${ok4}=    Run Keyword And Return Status    Page Should Contain                 Shipped
    ${ok5}=    Run Keyword And Return Status    Page Should Contain                 Fulfilled
    Run Keyword If    ${ok1} or ${ok2} or ${ok3} or ${ok4} or ${ok5}    Return From Keyword
    Fail    No success indicators found yet.

Admin Fill Fulfillment Form And Submit
    [Documentation]    เลือก Location + Shipping method -> Create Fulfillment
    Wait Until Page Contains Element    ${MODAL_FULFILLMENT}    10s
    # ===== Location =====
    Open Location Dropdown (In Fulfillment Modal)
    Select Location In Dropdown    European Warehouse
    # ===== Shipping method =====
    Wait Until Element Is Visible    ${DROP_SHIPPING_METHOD}   10s
    Click Element     ${DROP_SHIPPING_METHOD}
    ${has_named}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${OPT_EXPRESS_SHIPPING}    3s
    Run Keyword If    ${has_named}         Click Element    ${OPT_EXPRESS_SHIPPING}
    Run Keyword If    not ${has_named}     Click Element    ${OPT_FIRST_IN_LIST}
    # ===== Create Fulfillment =====
    Click Button      ${BTN_CREATE_FULFILLMENT}
    Wait Until Keyword Succeeds    5x    1s    Page Should Contain Element    ${ADMIN_TOAST_SUCCESS}

    # ✅ ยืนยันความสำเร็จแบบหลายสัญญาณ (ไม่ยึดติดกับ toast อย่างเดียว)
    Verify Fulfillment Succeeded

Admin Create Fulfillment For First Unfulfilled Order
    [Documentation]    Flow ครบ: Login -> Orders -> เปิดออเดอร์ Not fulfilled แรก -> เปิดเมนู/โมดัล -> เลือก Location/Shipping -> Create
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Admin Open Orders Page
    Admin Open First Not Fulfilled Order
    Scroll Section Unfulfilled Into View
    Open Unfulfilled Action Trigger
    Open Fulfill Modal If Needed
    Open Location Dropdown (In Fulfillment Modal)
    Admin Fill Fulfillment Form And Submit


*** Test Cases ***
TC4_1_Happy_Update_To_Shipped
    [Tags]    admin    fulfillment    happy
    Admin Create Fulfillment For First Unfulfilled Order
