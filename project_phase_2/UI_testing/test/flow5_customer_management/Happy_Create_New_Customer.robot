#=====================================================================#
#                      Happy_Create_New_Customer                      #
#=====================================================================#

*** Settings ***
Library           SeleniumLibrary    timeout=10s    implicit_wait=0.3
Resource          ../../config/env.robot
Resource          ../../pages/admin/AdminLogin.robot
Resource          ../../pages/customer/CustomerLogin.robot
Resource          Happy_Edit_Customer_Profile.robot
Suite Setup       Open Admin Browser


*** Variables ***
${ADMIN_MENU_CUSTOMER}     xpath=//a[contains(normalize-space(.),"Customers")]
${CUSTOMERS_TABLE}         xpath=//table[contains(@class,"w-full")]

# ===== ปุ่ม Create ในหน้า Customers (รูปที่ 1) =====
${BTN_CUSTOMERS_CREATE}    xpath=//a[contains(@href,"/customers/create")]

# ===== Modal Create Customer (รูปที่ 2) =====
# ใช้ predicate ซ้อน แทน "and" เพื่อลดปัญหา InvalidSelector
${CREATE_CUSTOMER_CANVAS}  //div[@role='dialog'][.//h1[normalize-space(.)='Create Customer']]

# ปุ่ม Create ใน modal (รูปที่ 4)
${BTN_CREATE_MODAL}        xpath=${CREATE_CUSTOMER_CANVAS}//button[@type='submit' and normalize-space(.)='Create']

# ===== Input fields ใช้ name attribute (รูปที่ 3) =====
${INPUT_FIRSTNAME}         name=first_name
${INPUT_LASTNAME}          name=last_name
${INPUT_EMAIL}             name=email
${INPUT_COMPANY}           name=company_name
${INPUT_PHONE}             name=phone


*** Keywords ***
Open Create Customer Form
    Wait Until Element Is Visible    ${BTN_CUSTOMERS_CREATE}    10s
    Click Element    ${BTN_CUSTOMERS_CREATE}
    # รอ modal Create Customer โผล่
    Wait Until Element Is Visible    xpath=${CREATE_CUSTOMER_CANVAS}    10s

Fill Create Customer Form
    [Arguments]    ${first_name}    ${last_name}    ${email}    ${company}    ${phone}
    Wait Until Element Is Visible    ${INPUT_FIRSTNAME}    10s
    Clear Element Text               ${INPUT_FIRSTNAME}
    Input Text                       ${INPUT_FIRSTNAME}    ${first_name}
    Clear Element Text               ${INPUT_LASTNAME}
    Input Text                       ${INPUT_LASTNAME}     ${last_name}
    Clear Element Text               ${INPUT_EMAIL}
    Input Text                       ${INPUT_EMAIL}         ${email}
    Clear Element Text               ${INPUT_COMPANY}
    Input Text                       ${INPUT_COMPANY}       ${company}
    Clear Element Text               ${INPUT_PHONE}
    Input Text                       ${INPUT_PHONE}         ${phone}

Click Create Customer In Modal
    Wait Until Element Is Visible    ${BTN_CREATE_MODAL}    10s
    Click Element                    ${BTN_CREATE_MODAL}

Verify Customer Detail
    [Arguments]    ${exp_email}    ${exp_name}    ${exp_company}    ${exp_phone}

    # ===== CARD หลักของ Customer (ล็อกด้วย label Name) =====
    ${card_customer}=    Set Variable
    ...    //div[contains(@class,'shadow-elevation-card-rest')][.//p[normalize-space()='Name']][1]

    # ===== EMAIL บนหัวการ์ด (h1) =====
    ${loc_header_email}=    Set Variable    xpath=${card_customer}//h1
    Wait Until Element Is Visible    ${loc_header_email}    10s
    ${act_email}=    Get Text    ${loc_header_email}
    Log To Console    Email header = ${act_email}
    Should Be Equal As Strings    ${act_email}    ${exp_email}

    # ===== NAME =====
    ${loc_name}=    Set Variable    xpath=${card_customer}//p[normalize-space()='Name']/following::p[1]
    Wait Until Element Is Visible    ${loc_name}    10s
    ${act_name}=    Get Text    ${loc_name}
    Log To Console    Name = ${act_name}
    Should Be Equal As Strings    ${act_name}    ${exp_name}

    # ===== COMPANY =====
    ${loc_company}=    Set Variable    xpath=${card_customer}//p[normalize-space()='Company']/following::p[1]
    Wait Until Element Is Visible    ${loc_company}    10s
    ${act_company}=    Get Text    ${loc_company}
    Log To Console    Company = ${act_company}
    Should Be Equal As Strings    ${act_company}    ${exp_company}

    # ===== PHONE =====
    ${loc_phone}=    Set Variable    xpath=${card_customer}//p[normalize-space()='Phone']/following::p[1]
    Wait Until Element Is Visible    ${loc_phone}    10s
    ${act_phone}=    Get Text    ${loc_phone}
    Log To Console    Phone = ${act_phone}
    Should Be Equal As Strings    ${act_phone}    ${exp_phone}

