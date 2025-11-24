*** Settings ***
Library           SeleniumLibrary    timeout=10s    implicit_wait=0.3
Resource          TC5_1_Happy_Edit_Customer_Profile.robot
Resource          TC5_2_Happy_Add_Customer_Address.robot
Suite Setup       Open Admin Browser
Suite Teardown    Close All Browsers

*** Test Cases ***
TC5_1_Happy_Edit_Customer_Profile
    [Documentation]    Admin: Edit Customer Profile --> Customer: Check Profile
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Admin Open Customers Page
    Admin Open Customer Name
    Open Menu Action Trigger
    Update Customer And Save
    ...    first_name=Hammy
    ...    last_name=Burger
    ...    company_name=MU Co., Ltd.
    ...    phone=+66999999999
    Open Customer Browser
    Customer Login    ${CUS_USER_HAM}    ${CUS_PASS_HAM}
    Select Account Menu    Profile
    Customer Should See Profile Info
    ...    Hammy Burger
    ...    eatburger@example.com
    ...    +66999999999

TC5_2_Happy_Add_Customer_Address.robot
    [Documentation]    Admin: Admin Add Address --> Customer: Check Profile
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Admin Open Customers Page
    Admin Open Customer Name
    Admin Add Address For Customer
    ...    addr_label=Home
    ...    addr_line1=32/1 CJ Apartment
    ...    city=Bangkok
    ...    postal=10310
    ...    country=Thailand

    Admin Should See Address
    ...    Home
    ...    32/1 CJ Apartment
    Open Customer Browser
    Customer Login    ${CUS_USER_HAM}    ${CUS_PASS_HAM}
    Select Account Menu    Addresses
    Customer Should See Addresses Info
    ...    Hammy Burger
    ...    eatburger@example.com
    ...    +66999999999