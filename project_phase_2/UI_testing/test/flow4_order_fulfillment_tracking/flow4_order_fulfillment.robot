*** Settings ***
Library           SeleniumLibrary    timeout=10s    implicit_wait=0.3    run_on_failure=Capture Page Screenshot
Resource          ../../config/env.robot
Resource          ../../pages/admin/AdminLogin.robot
Resource          ../../pages/customer/CustomerLogin.robot
Resource          ../../pages/customer/CustomerBuyProduct.robot
Resource          ../../pages/customer/CustomerCheckStatus.robot
Resource          Happy_Update_To_Shipped.robot
Resource          Happy_Update_To_Delivered.robot
Suite Setup       Open Customer Browser
Suite Teardown    Close All Browsers

*** Test Cases ***
SYS10_Happy_Update_To_Shipped
    [Documentation]    Update shipping status
    Customer Login    ${CUS_USER_HAM}    ${CUS_PASS_HAM}
    Customer Full Purchase Flow
    Open Admin Browser
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Admin Open Orders Page
    Admin Open First Not Fulfilled Order
    Full Update shipped
    Close All
    Open Customer Browser
    Customer Login    ${CUS_USER_HAM}    ${CUS_PASS_HAM}
    Select Account Menu    Overview
    Click First Customer Order
    Verify Shipped Order Details

*** Test Cases ***
SYS11_Happy_Update_To_Delivered
    Open Admin Browser
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Admin Open Orders Page
    Admin Open First Shipped Order
    Admin Mark Current Order As Delivered
    Back To Orders List
    Close All
    Open Customer Browser
    Customer Login    ${CUS_USER_HAM}    ${CUS_PASS_HAM}
    Select Account Menu    Overview
    Click First Customer Order
    Verify Delivered Order Details