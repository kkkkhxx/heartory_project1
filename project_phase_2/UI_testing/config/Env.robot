*** Settings ***
Library    SeleniumLibrary
*** Variables ***
${ADMIN_URL}        http://10.34.112.158:9000/app/
${CUSTOMER_URL}     http://10.34.112.158:8000/dk/
        
${ADMIN_USER}       group4@mu-store.local
${ADMIN_PASS}       Mp6!dzT3

${CUS_USER_HAM}       eatburger@example.com
${CUS_PASS_HAM}       1234

# ค่าส่ง (ปรับให้ตรงระบบจริง)
${FEE_IN_AREA}      20
${FEE_OUT_AREA}     80

# ค่าอื่น ๆ
${BROWSER}          chrome
${SEL_TIMEOUT}      10s
${IMPLICIT_WAIT}    0.3

# ชื่อสถานะ (แก้ให้ตรงกับระบบ)
${STATUS_PROCESSING}      Processing
${STATUS_SHIPPED}         Shipped
${STATUS_DELIVERED}       Delivered

*** Keywords ***
Open Admin And Customer Sessions
    [Documentation]    เปิด 2 session: ADMIN และ CUSTOMER
    Open Browser    ${ADMIN_URL}       chrome    alias=ADMIN
    Set Window Size    1440    900
    Open Browser    ${CUSTOMER_URL}    chrome    alias=CUSTOMER
    Set Window Size    1440    900

Close All
    Close All Browsers
