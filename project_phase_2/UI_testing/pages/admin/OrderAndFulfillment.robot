# *** Settings ***
# Library    SeleniumLibrary
# Resource   ../../config/Env.robot
# Resource   ../../pages/admin/AdminLogin.robot

# *** Variables ***
# # ===== TODO: เปลี่ยน locator ให้ตรง DOM ของคุณ =====
# # Login
# ${ADMIN_LOGIN_USER}       css=input[name="username"]                   # ช่องยูสเซอร์
# ${ADMIN_LOGIN_PASS}       css=input[name="password"]                   # ช่องรหัสผ่าน
# ${ADMIN_LOGIN_BTN}        xpath=//button[normalize-space(.)="Sign in"] # ปุ่มล็อกอิน

# # เมนู/หน้า Orders
# ${ADMIN_MENU_ORDERS}      xpath=//a[contains(.,"Orders")]              # เมนู Orders
# ${ADMIN_SEARCH_INPUT}     css=input[placeholder="Search"]              # กล่องค้นหา Order No
# ${ADMIN_SEARCH_BTN}       xpath=//button[contains(.,"Search")]         # ปุ่มค้นหา
# ${ADMIN_ROW_FIRST}        xpath=(//tr[contains(@class,"order-row")])[1]# แถวผลลัพธ์แรก
# ${ADMIN_STATUS_SELECT}    css=select[name="orderStatus"]               # เลือกสถานะ
# ${ADMIN_SAVE_STATUS_BTN}  xpath=//button[contains(.,"Save")]           # ปุ่ม Save/Update
# ${ADMIN_STATUS_BADGE}     css=[data-testid="status-badge"]             # ป้ายสถานะในหน้า detail
# ${ADMIN_TOAST_SUCCESS}    css=.toast.toast-success                     # Toast สำเร็จ
# ${ADMIN_TOAST_ERROR}      css=.toast.toast-error                       # Toast ผิดพลาด

# *** Keywords ***
# Admin Login
#     [Documentation]    ล็อกอินฝั่งแอดมิน
#     Switch Browser    ADMIN
#     Wait Until Element Is Visible    ${ADMIN_LOGIN_USER}
#     Input Text         ${ADMIN_LOGIN_USER}    ${ADMIN_USER}
#     Input Password     ${ADMIN_LOGIN_PASS}    ${ADMIN_PASS}
#     Click Button       ${ADMIN_LOGIN_BTN}
#     Wait Until Page Contains Element    ${ADMIN_MENU_ORDERS}

# Admin Open Order Detail By Number    ${order_no}
#     [Documentation]    เข้าเมนู Orders -> ค้นหา -> เปิดรายละเอียดออเดอร์
#     Switch Browser    ADMIN
#     Click Element     ${ADMIN_MENU_ORDERS}
#     Wait Until Element Is Visible    ${ADMIN_SEARCH_INPUT}
#     Clear Element Text    ${ADMIN_SEARCH_INPUT}
#     Input Text        ${ADMIN_SEARCH_INPUT}    ${order_no}
#     Click Button      ${ADMIN_SEARCH_BTN}
#     Wait Until Element Is Visible    ${ADMIN_ROW_FIRST}
#     Click Element     ${ADMIN_ROW_FIRST}

# Admin Update Status To    ${new_status}
#     [Documentation]    เปลี่ยนสถานะแล้วกดบันทึก
#     Wait Until Element Is Visible    ${ADMIN_STATUS_SELECT}
#     Select From List By Label    ${ADMIN_STATUS_SELECT}    ${new_status}
#     Click Button      ${ADMIN_SAVE_STATUS_BTN}
#     # รอให้มี toast success หรือ badge เปลี่ยน
#     ${ok}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${ADMIN_TOAST_SUCCESS}    4s
#     Run Keyword If    not ${ok}    Wait Until Element Is Visible    ${ADMIN_STATUS_BADGE}    5s

# Admin Should Not Allow Delivered If Not Shipped
#     [Documentation]    ตรวจว่าถูกบล็อคเมื่อพยายามตั้ง Delivered โดยยังไม่ Shipped
#     Wait Until Element Is Visible    ${ADMIN_STATUS_SELECT}
#     Select From List By Label    ${ADMIN_STATUS_SELECT}    ${STATUS_DELIVERED}
#     Click Button      ${ADMIN_SAVE_STATUS_BTN}
#     ${saw_error}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${ADMIN_TOAST_ERROR}    3s
#     ${badge_is_delivered}=    Run Keyword And Return Status    Element Text Should Be    ${ADMIN_STATUS_BADGE}    ${STATUS_DELIVERED}
#     Should Be True    ${saw_error} or not ${badge_is_delivered}    msg=Admin ไม่ควรอัปเดตเป็น Delivered ได้ก่อน Shipped
