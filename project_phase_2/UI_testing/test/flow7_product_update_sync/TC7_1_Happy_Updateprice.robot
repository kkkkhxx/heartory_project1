7.1

*** Settings ***
Documentation     FLOW 7: Product Update Synchronization
Library           SeleniumLibrary    timeout=10s    implicit_wait=0.3
Resource          ../../config/Env.robot
Resource          ../../pages/admin/AdminLogin.robot
Resource          ../../pages/admin/AdminProduct.robot
Suite Setup       Open Admin Browser
Suite Teardown    Close All Browsers


*** Test Cases ***
TC7.1 Admin Can Update Product Price
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Go To Products Page
    Open First Product
    Scroll To Variant Section
    Open Variants Menu
    Click Edit Prices
    Update Variant Price    99.00
    Log To Console    🍊 ราคาใหม่อัปเดตแล้ว

