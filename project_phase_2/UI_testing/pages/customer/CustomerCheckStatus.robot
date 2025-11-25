*** Settings ***
Library           SeleniumLibrary    timeout=10s    implicit_wait=0.3
Resource          ../../config/env.robot


*** Variables ***
${ORDER_DETAILS_CONTAINER}    xpath=//div[@data-testid='order-details-container']


*** Keywords ***
Click First Customer Order
    [Documentation]    คลิกออเดอร์รายการแรกสุดในหน้า Customer Account
    Wait Until Element Is Visible    xpath=//ul[@data-testid='orders-wrapper']    15s
    # เลือก <a> ของ order แรก
    ${order_first}=    Set Variable    xpath=(//li[@data-testid='order-wrapper'])[1]//a
    Scroll Element Into View    ${order_first}
    Sleep    0.3s
    Click Element    ${order_first}
    Log To Console    Clicked first order in customer orders list

Verify Shipped Order Details
    [Documentation]    ตรวจข้อมูลในหน้า order details ว่าตรงกับออเดอร์ Hammy / MU Testing store
    # รอให้ container หลักขึ้น
    Wait Until Element Is Visible    ${ORDER_DETAILS_CONTAINER}    15s
    Scroll Element Into View         ${ORDER_DETAILS_CONTAINER}
    Sleep    0.5s

    # ===== ส่วนหัว Order details =====
    Page Should Contain              Order details
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Order date:
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Order number:
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Order status: Shipped
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Payment status: Authorized

    # ===== ตรวจสินค้า =====
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    MU Testing store
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Variant: M / White
    # ตรวจจำนวน 2x
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    2x
    # ตรวจราคา product unit (€10.00)
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    €10.00
    # ตรวจ total line (€20.00)
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    €20.00

    # ===== Delivery section =====
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Delivery
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Hammy Burger
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Bangkok
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    10110, Bangkok
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    DK
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Standard (€10.00)

Verify Delivered Order Details
    [Documentation]    ตรวจข้อมูลในหน้า order details ว่าตรงกับออเดอร์ Hammy / MU Testing store
    # รอให้ container หลักขึ้น
    Wait Until Element Is Visible    ${ORDER_DETAILS_CONTAINER}    15s
    Scroll Element Into View         ${ORDER_DETAILS_CONTAINER}
    Sleep    0.5s

    # ===== ส่วนหัว Order details =====
    Page Should Contain              Order details
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Order date:
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Order number:
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Order status: Delivered
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Payment status: Authorized

    # ===== ตรวจสินค้า =====
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    MU Testing store
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Variant: M / White
    # ตรวจจำนวน 2x
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    2x
    # ตรวจราคา product unit (€10.00)
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    €10.00
    # ตรวจ total line (€20.00)
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    €20.00

    # ===== Delivery section =====
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Delivery
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Hammy Burger
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Bangkok
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    10110, Bangkok
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    DK
    Element Should Contain           ${ORDER_DETAILS_CONTAINER}    Standard (€10.00)


