*** Settings ***
Resource          Happy_Create_New_Customer.robot
Resource          Happy_Edit_Customer_Profile.robot
Resource          Happy_Add_Customer_Address.robot
Resource          Error_Flow5.robot
Resource          Happy_Delete_Customer.robot
Suite Setup       Open Admin Browser

*** Test Cases ***
SYS12_Happy_Create_New_Customer_ByAdmin
    [Documentation]    Admin: เปิดหน้า customer --> Create --> กรอกข้อมูล --> สร้าง
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Admin Open Customers Page
    Open Create Customer Form
    Fill Create Customer Form    Slott    Hawa    slot@example.com    1112 Corp    0888888888
    Click Create Customer In Modal
    Verify Customer Detail    slot@example.com    Slott Hawa    1112 Corp    0888888888

SYS13_Happy_Delete_Customer
    [Documentation]    Admin: ค้นหา --> ลบ
    ${email}=    Set Variable    slot@example.com
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Admin Open Customers Page
    Search Customer By Email           ${email}
    Open Customer From Search By Email    ${email}
    Delete Customer From Detail Page    ${email}
    Customer Should Not Exist In Table    ${email}

SYS14_Error_Create_Email_Empty_Customer_ByAdmin
    [Documentation]    Admin: ค้นหา --> ลบ
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Admin Open Customers Page
    Open Create Customer Form
    Fill Create Customer Form    Pizza    Hawa    ${EMPTY}    1112 Corp    0888888888
    Click Create Customer In Modal
    Admin Should See Email Required Error
    Wait Until Element Is Visible    ${CREATE_CUSTOMER_CANVAS}    5s

SYS15_Error_Create_Email_Duplicate_Customer_ByAdmin
    [Documentation]    Admin: ค้นหา --> ลบ
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Admin Open Customers Page
    Open Create Customer Form
    Fill Create Customer Form    Pizza    Seafood    eatburger@example.com    1112 Corp    0888888888
    Click Create Customer In Modal
    Wait Until Element Is Visible    ${CREATE_CUSTOMER_CANVAS}    5s

SYS16_Error_Create_Email_Format_Customer_ByAdmin
    [Documentation]    Admin: ค้นหา --> ลบ
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Admin Open Customers Page
    Open Create Customer Form
    Fill Create Customer Form    Pizza    Seafood    กกกกกก    1112 Corp    0888888888
    Click Create Customer In Modal
    Admin Should See Email Required Error
    Wait Until Element Is Visible    ${CREATE_CUSTOMER_CANVAS}    5s

SYS17_Happy_Edit_Customer_Profile_ByAdmin
    [Documentation]    Admin: Edit Customer Profile --> Customer: Check Profile
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Admin Open Customers Page
    Admin Open Customer Name
    Open Menu Action Trigger
    Update Customer And Save
    ...    first_name=Hamcheese
    ...    last_name=Burger
    ...    company_name=MU Co., Ltd.
    ...    phone=+66999999999
    Open Customer Browser
    Customer Login    ${CUS_USER_HAM}    ${CUS_PASS_HAM}
    Select Account Menu    Profile
    Customer Should See Profile Info
    ...    Hamcheese Burger
    ...    eatburger@example.com
    ...    +66999999999

SYS18_Happy_Add_Customer_Address
    [Documentation]    Admin: Admin Add Address --> Customer: Check Profile
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Admin Open Customers Page
    Admin Open Customer Name
    Admin Add Address For Customer
    ...    Home
    ...    32/1 CJ Apartment
    ...    Room 202
    ...    10310
    ...    Bangkok
    ...    th
    ...    MU Co., Ltd.
    ...    +66999999999
    Admin Should See Address
    ...    Home
    ...    32/1 CJ Apartment
    ...    Room 202
    Open Customer Browser
    Customer Login    ${CUS_USER_HAM}    ${CUS_PASS_HAM}
    Select Account Menu    Addresses
    Customer Should See Addresses Info
    ...    32/1 CJ Apartment, Room 202
    ...    10310, Bangkok
    ...    TH
 
SYS19_Error_Add_Customer_Address
    [Documentation]    Admin: Add Address without Address Name --> Admin should see validation error
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Admin Open Customers Page
    Admin Open Customer Name
    # เปิดหน้า Create Address แต่ส่ง address_name ว่าง
    Switch Browser    ADMIN
    Wait Until Element Is Visible    ${ADMIN_ADDR_ADD_BTN}    10s
    Click Element                    ${ADMIN_ADDR_ADD_BTN}
    Wait Until Element Is Visible    ${ADDR_DIALOG}    10s
    # กรอก field อื่น ยกเว้น address_name
    Fill Address Field By Name    address_name    ${EMPTY}
    Fill Address Field By Name    address_1       32/1 CJ Apartment
    Fill Address Field By Name    address_2       Room 202
    Fill Address Field By Name    postal_code     10310
    Fill Address Field By Name    city            Bangkok
    Select Country                th
    Fill Address Field By Name    company         MU Co., Ltd.
    Fill Address Field By Name    phone           +66999999999
    # กด Save
    Click Element    ${ADDR_SAVE_BTN}
    # ต้องเห็น error
    Admin Should See Address Name Required Error
    # และ dialog ต้องยังคงเปิดอยู่ — เพื่อยืนยันว่าไม่ถูกสร้าง
    Wait Until Element Is Visible    ${ADDR_DIALOG}    5s