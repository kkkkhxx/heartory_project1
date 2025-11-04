# *** Settings ***
# Library    SeleniumLibrary
# Resource   ../../config/Env.robot
# Resource   ../../pages/admin/AdminLogin.robot

# *** Variables ***
# # ===== TODO: ปรับให้ตรง DOM ของคุณ =====
# # Login
# ${ADMIN_LOGIN_USER}        css=input[name="username"]                         # ช่องยูสเซอร์
# ${ADMIN_LOGIN_PASS}        css=input[name="password"]                         # ช่องรหัสผ่าน
# ${ADMIN_LOGIN_BTN}         xpath=//button[normalize-space(.)="Sign in"]       # ปุ่มล็อกอิน

# # เมนู Orders
# ${ADMIN_MENU_ORDERS}       xpath=//a[contains(normalize-space(.),"Orders")]   # เมนู Orders

# # ตาราง Orders (ต้องมีคอลัมน์ Fulfillment)
# # TODO: เปลี่ยนให้ชี้ไปยังตารางจริงของคุณ เช่น data-testid หรือ class ที่ใช้จริง
# ${ORDERS_TABLE}            xpath=//table[contains(@class,"orders")]           # ตำแหน่งตารางโดยรวม
# # แถวแรกที่คอลัมน์ Fulfillment เป็น "Not fulfilled"
# # หมายเหตุ: ถ้า header ไม่ใช่ <th> ให้ปรับ XPath ส่วน header เอง
# ${ROW_FIRST_NOT_FULFILLED}    xpath=(//table[contains(@class,"orders")]//tr[.//td[contains(normalize-space(.),"Not fulfilled")]])[1]

# # หน้า Order detail – โซน "Unfulfilled Items" และปุ่ม/ทริกเกอร์ Radix
# # กดปุ่ม id ที่เป็น radix-:rd0:
# ${BTN_RADIX_RD0}           xpath=//*[@id='radix-:rd0:']                        # ปุ่มแรกที่กดแล้วทำให้มี aria-controls โผล่
# # หลังจากกดจะมี element ที่มี aria-controls="radix-:rd1:" ให้กดอีกรอบเพื่อเข้า modal
# ${TRIGGER_ARIA_RD1}        xpath=//*[@aria-controls='radix-:rd1:']

# # ภายใน Modal "Create Fulfillment"
# # TODO: ปรับ locator ให้ตรงกับของจริงในโปรเจกต์ (แนะนำใช้ data-testid)
# ${MODAL_FULFILLMENT}       xpath=//*[@role="dialog" and .//*[contains(normalize-space(.),"Create Fulfillment")]]
# ${DROP_LOCATION}           xpath=(//*[@role="combobox" or @data-testid="location-select"])[1]
# ${OPT_FIRST_IN_LIST}       xpath=(//*[@role="option" or @data-radix-collection-item])[1]
# ${DROP_SHIPPING_METHOD}    xpath=(//*[@role="combobox" or @data-testid="shipping-method-select"])[1]
# ${OPT_EXPRESS_SHIPPING}    xpath=//*[contains(@role,"option") and normalize-space(.)="Express Shipping"]
# ${BTN_CREATE_FULFILLMENT}  xpath=//button[normalize-space(.)="Create Fulfillment"]

# # Toast / สถานะสำเร็จ
# # TODO: แก้ให้ตรง toast ของคุณ
# ${ADMIN_TOAST_SUCCESS}     css=.toast.toast-success, [data-testid="toast-success"]
# ${ADMIN_TOAST_ERROR}       css=.toast.toast-error, [data-testid="toast-error"]

# *** Keywords ***
# Admin Login
#     [Documentation]    ล็อกอินฝั่งแอดมินด้วยข้อมูลจาก Env.robot
#     Switch Browser    ADMIN
#     Wait Until Element Is Visible    ${ADMIN_LOGIN_USER}     10s
#     Input Text         ${ADMIN_LOGIN_USER}    ${ADMIN_USER}
#     Input Password     ${ADMIN_LOGIN_PASS}    ${ADMIN_PASS}
#     Click Button       ${ADMIN_LOGIN_BTN}
#     Wait Until Element Is Visible    ${ADMIN_MENU_ORDERS}    10s

# Admin Open Orders Page
#     [Documentation]    เข้าเมนู Orders
#     Switch Browser    ADMIN
#     Click Element     ${ADMIN_MENU_ORDERS}
#     Wait Until Element Is Visible    ${ORDERS_TABLE}    10s

# Admin Open First Not Fulfilled Order
#     [Documentation]    เปิดออเดอร์แรกที่คอลัมน์ Fulfillment เป็น "Not fulfilled"
#     # หากตารางมี paging/โหลดแบบ lazy ให้เพิ่มการรอที่เหมาะสม
#     Wait Until Element Is Visible    ${ROW_FIRST_NOT_FULFILLED}    10s
#     Click Element     ${ROW_FIRST_NOT_FULFILLED}

# Admin Open Fulfillment Modal From Unfulfilled Items
#     [Documentation]    ในหน้า Order detail: หา "Unfulfilled Items" แล้วกดปุ่มตาม flow Radix เพื่อเปิด Modal
#     # 1) คลิกปุ่ม id=radix-:rd0:
#     Wait Until Element Is Visible    ${BTN_RADIX_RD0}    10s
#     Click Element     ${BTN_RADIX_RD0}
#     # 2) จากนั้นจะมี trigger ที่มี aria-controls="radix-:rd1:" ให้กดเพื่อเปิด modal
#     Wait Until Element Is Visible    ${TRIGGER_ARIA_RD1}    10s
#     Click Element     ${TRIGGER_ARIA_RD1}
#     # 3) รอ modal โผล่
#     Wait Until Element Is Visible    ${MODAL_FULFILLMENT}  10s

# Admin Fill Fulfillment Form And Submit
#     [Documentation]    เลือก Location (อันแรก) + Shipping method = Express Shipping จากนั้นกด Create Fulfillment
#     # เลือก Location (อันแรก)
#     Wait Until Element Is Visible    ${DROP_LOCATION}    10s
#     Click Element     ${DROP_LOCATION}
#     Wait Until Element Is Visible    ${OPT_FIRST_IN_LIST}    5s
#     Click Element     ${OPT_FIRST_IN_LIST}
#     # เลือก Shipping method = Express Shipping
#     Wait Until Element Is Visible    ${DROP_SHIPPING_METHOD}   10s
#     Click Element     ${DROP_SHIPPING_METHOD}
#     # ถ้าชื่อ option ไม่ตรง "Express Shipping" ให้แก้ข้อความใน ${OPT_EXPRESS_SHIPPING}
#     ${has_named}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${OPT_EXPRESS_SHIPPING}    3s
#     Run Keyword If    ${has_named}    Click Element    ${OPT_EXPRESS_SHIPPING}
#     Run Keyword If    not ${has_named}    Click Element    ${OPT_FIRST_IN_LIST}
#     # Create Fulfillment
#     Click Button      ${BTN_CREATE_FULFILLMENT}
#     # รอ success (ถ้าไม่มี toast ให้เปลี่ยนเป็น element อย่าง badge หรือรายการ Fulfillment ที่เพิ่มใหม่)
#     Wait Until Keyword Succeeds    5x    1s    Page Should Contain Element    ${ADMIN_TOAST_SUCCESS}

# Admin Create Fulfillment For First Unfulfilled Order
#     [Documentation]    Flow ครบ: Login -> Orders -> เปิดออเดอร์ Not fulfilled แรก -> เปิด modal -> เลือก Location/Shipping -> Create
#     Admin Login
#     Admin Open Orders Page
#     Admin Open First Not Fulfilled Order
#     Admin Open Fulfillment Modal From Unfulfilled Items
#     Admin Fill Fulfillment Form And Submit

# *** Test Cases ***
# TC Admin Create Fulfillment (Happy Path)
#     [Tags]    admin    fulfillment    happy
#     Admin Create Fulfillment For First Unfulfilled Order
