*** Settings ***
Resource          ../../pages/customer/CustomerLogin.robot
Resource          ../../config/Env.robot
Resource          ../flow5_customer_management/Happy_Edit_Customer_Profile.robot
Resource          ../flow5_customer_management/Happy_Create_New_Customer.robot
Resource          ../flow5_customer_management/Happy_Delete_Customer.robot
Suite Teardown    Close All Browsers

*** Variables ***
${PROFILE_TITLE}          xpath=//div[@data-testid='account-page']//h1[normalize-space(.)='Profile']
${EDIT_BTN_CUS_ACC}       xpath=//div[@data-testid='account-name-editor']//button[@data-testid='edit-button']
${SAVE_BTN_CUS_ACC}       css=button[type="submit"]

${INPUT_FNAME}            css=input[name="first_name"]
${INPUT_LNAME}            css=input[name="last_name"]

# ตัวแสดงผลชื่อหลังเซฟ
${DISPLAY_NAME}    xpath=//div[@data-testid='account-name-editor']//span[@data-testid='current-info']


*** Keywords ***
Customer Edit Name
    [Arguments]    ${first_name}    ${last_name}
    # เปิดหน้า Profile
    Wait Until Element Is Visible    ${PROFILE_TITLE}       10s
    Wait Until Element Is Visible    ${EDIT_BTN_CUS_ACC}    10s
    Click Element                    ${EDIT_BTN_CUS_ACC}
    # กรอกข้อมูลใหม่
    Wait Until Element Is Visible    ${INPUT_FNAME}         10s
    Clear Element Text               ${INPUT_FNAME}
    Input Text                       ${INPUT_FNAME}    ${first_name}
    Wait Until Element Is Visible    ${INPUT_LNAME}         10s
    Clear Element Text               ${INPUT_LNAME}
    Input Text                       ${INPUT_LNAME}    ${last_name}
    # เซฟข้อมูล
    Click Button                     ${SAVE_BTN_CUS_ACC}
    # ===== Verify ชื่อแสดงผลถูกต้อง =====
    ${expected_name}=    Set Variable    ${first_name} ${last_name}
    Wait Until Element Is Visible    ${DISPLAY_NAME}    10s
    Element Text Should Be           ${DISPLAY_NAME}    ${expected_name}


*** Test Cases ***
SYS20_Happy_Customer_Edit_Profile
    Open Customer Browser
    Customer Login    eatmatcha@example.com    1234
    Select Account Menu    Profile
    Customer Edit Name    Matcha    Bubblethree
    Open Admin Browser
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Admin Open Customers Page
    Search Customer By Email    eatmatcha@example.com
    Open Customer From Search By Email    eatmatcha@example.com
    Verify Customer Detail    eatmatcha@example.com    Matcha Bubblethree    -    562545


