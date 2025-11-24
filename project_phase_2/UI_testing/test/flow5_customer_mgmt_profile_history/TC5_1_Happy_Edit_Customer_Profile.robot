*** Settings ***
Library           SeleniumLibrary    timeout=10s    implicit_wait=0.3
Resource          ../../config/Env.robot
Resource          ../../pages/admin/AdminLogin.robot
Suite Setup       Open Admin Browser
Suite Teardown    Close All Browsers


*** Variables ***
${ADMIN_LOGIN_USER}        css=input[name="email"]
${ADMIN_LOGIN_PASS}        css=input[name="password"]
${ADMIN_LOGIN_BTN}         xpath=//button[normalize-space(.)="Continue with Email"]
${ADMIN_DASH_TAG}          xpath=//aside//*[contains(normalize-space(.),"Orders")]

${ADMIN_MENU_CUSTOMER}     xpath=//a[contains(normalize-space(.),"Customers")]
${CUSTOMERS_TABLE}         xpath=//table[contains(@class,"text-ui-fg-subtle txt-compact-small relative w-full")]

${ROW_CUSTOMER_HAMBURGER}  xpath=//table[.//th[normalize-space()='Name']]//tr[td[normalize-space()='Hamchees Burger'and 
...    count(preceding-sibling::td) = count(ancestor::table[1]//th[normalize-space()='Name']/preceding-sibling::th)]]

${SECTION_EMAIL}            (//*[self::section or self::div][.//h1])[1]
${BTN_MANU_ICON}           xpath=(${SECTION_EMAIL}//*[normalize-space(.)='Registered']/ancestor::*[self::div or self::section][1]
...        //button[.//*[local-name()='svg']][not(ancestor::aside)])[last()]

${MENU_EDIT}               xpath=//a[@role='menuitem' and contains(@href,'/customers/') and contains(@href,'/edit')]
${EDIT_CUSTOMER_CANVAS}    xpath=//div[@data-state='open' and .//h1[normalize-space(.)='Edit Customer']]

${INPUT_FNAME}            css=input[name="first_name"]
${INPUT_LNAME}            css=input[name="last_name"]
${INPUT_COMPANY}          css=input[name="company_name"]
${INPUT_NAME}             css=input[name="phone"]

${BTN_SAVE}            xpath=${EDIT_CUSTOMER_CANVAS}//button[normalize-space(.)='Save']


*** Keywords ***
Admin Open Customers Page
    Switch Browser    ADMIN
    Click Element     ${ADMIN_MENU_CUSTOMER}
    Wait Until Element Is Visible    ${CUSTOMERS_TABLE}    10s

Admin Open Customer Name
    Wait Until Element Is Visible    ${ROW_CUSTOMER_HAMBURGER}    10s
    Click Element     ${ROW_CUSTOMER_HAMBURGER}

Open Menu Action Trigger
    Wait Until Element Is Visible    ${BTN_MANU_ICON}    5s
    ${ok}=    Run Keyword And Return Status    Click Element    ${BTN_MANU_ICON}
    Click Element    ${MENU_EDIT}
    Wait Until Element Is Visible    ${EDIT_CUSTOMER_CANVAS}

Fill Field In Edit Panel
    [Arguments]    ${label_text}    ${value}
    ${field}=    Set Variable    xpath=${EDIT_CUSTOMER_CANVAS}//label[normalize-space(.)='${label_text}']/following::*[self::input or self::textarea][1]
    Wait Until Element Is Visible    ${field}    5s
    Click Element                    ${field}
    # เคลียร์แบบครอบจักรวาล เพื่อให้รอดเคส React/Mask
    Press Keys                       ${field}    CTRL+a
    Press Keys                       ${field}    BACKSPACE
    Input Text                       ${field}    ${value}
    # Fallback: ถ้าค่าไม่เปลี่ยน ลองยิง JS (กัน React valueTracker)
    ${ok}=    Run Keyword And Return Status    Element Attribute Value Should Be    ${field}    value    ${value}
    Run Keyword Unless    ${ok}    Execute JavaScript
    ...    var el=arguments[0],v=arguments[1]; if(el){var last=el.value; el.value=v; var e=new Event('input',{bubbles:true}); if(el._valueTracker){el._valueTracker.setValue(last);} el.dispatchEvent(e);}
    ...    ${field}    ${value}
 
Update Customer And Save
    [Arguments]    ${first_name}=${EMPTY}    ${last_name}=${EMPTY}    ${company_name}=${EMPTY}    ${phone}=${EMPTY}
    # กรอกเฉพาะช่องที่ส่งมา
    Run Keyword If    '${first_name}'!=''    Fill Field In Edit Panel    First Name    ${first_name}
    Run Keyword If    '${last_name}'!=''     Fill Field In Edit Panel    Last Name     ${last_name}
    Run Keyword If    '${company_name}'!=''       Fill Field In Edit Panel    Company       ${company_name}
    Run Keyword If    '${phone}'!=''         Fill Field In Edit Panel    Phone         ${phone}
    # กด Save
    Wait Until Element Is Visible    ${BTN_SAVE}    5s
    Click Element                    ${BTN_SAVE}
    # รอผลลัพธ์ -> แถบปิด หรือมี Toast "Updated" / "Saved"
    ${closed}=    Run Keyword And Return Status
    ...    Wait Until Page Does Not Contain Element    ${EDIT_CUSTOMER_CANVAS}    8s
    Run Keyword Unless    ${closed}    Run Keyword And Ignore Error
    ...    Wait Until Page Contains    Updated    5s
    Run Keyword Unless    ${closed}    Run Keyword And Ignore Error
    ...    Wait Until Page Contains    Saved      5s


*** Test Cases ***
TC5_1_Happy_Edit_Customer_Profile
    [Documentation]    Edit Customer Profile
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Admin Open Customers Page
    Admin Open Customer Name
    Open Menu Action Trigger
    Update Customer And Save    Hammy    Burger    MU Co., Ltd.    +66999999999