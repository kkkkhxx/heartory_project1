*** Settings ***
Library           SeleniumLibrary    timeout=10s    implicit_wait=0.3
Resource          ../../config/Env.robot
Resource          ../../pages/admin/AdminLogin.robot
Resource          ../../pages/customer/CustomerLogin.robot
Suite Setup       Open Admin Browser
Suite Teardown    Close All Browsers


*** Variables ***
${ADMIN_MENU_CUSTOMER}     xpath=//a[contains(normalize-space(.),"Customers")]
${CUSTOMERS_TABLE}         xpath=//table[contains(@class,"text-ui-fg-subtle txt-compact-small relative w-full")]

${ROW_CUSTOMER_HAMBURGER}  xpath=//table[.//th[normalize-space()='Email']]//tr[td[normalize-space()='eatburger@example.com'and 
...    count(preceding-sibling::td) = count(ancestor::table[1]//th[normalize-space()='Email']/preceding-sibling::th)]]

${SECTION_EMAIL}    xpath=//div[contains(@class,'shadow-elevation-card-rest')][.//h1[contains(@class,'font-medium')]][1]
${BTN_MENU_ICON}    xpath=//h1[normalize-space()='eatburger@example.com']
...    /ancestor::div[contains(@class,'shadow-elevation-card-rest')][1]//button[@aria-haspopup='menu']

${MENU_EDIT}               xpath=//a[@role='menuitem' and contains(@href,'/customers/') and contains(@href,'/edit')]
${EDIT_CUSTOMER_CANVAS}    //div[@role='dialog' and .//h1[normalize-space(.)='Edit Customer']]
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
    Wait Until Element Is Visible    ${BTN_MENU_ICON}    5s
    ${ok}=    Run Keyword And Return Status    Click Element    ${BTN_MENU_ICON}
    Click Element    ${MENU_EDIT}
    Wait Until Element Is Visible    ${EDIT_CUSTOMER_CANVAS}

Fill Field In Edit Panel
    [Arguments]    ${label_text}    ${value}

    # สร้าง XPath ของช่อง input จาก label
    ${field}=    Set Variable
    ...    ${EDIT_CUSTOMER_CANVAS}//label[normalize-space(.)='${label_text}']/following::input[1]

    # ใช้ ${field} เป็น XPath ตรง ๆ
    Wait Until Element Is Visible    ${field}    5s
    Click Element                    ${field}
    Clear Element Text               ${field}
    Input Text                       ${field}    ${value}

    # Fallback กัน React
    ${ok}=    Run Keyword And Return Status
    ...    Element Attribute Value Should Be    ${field}    value    ${value}
    Run Keyword Unless    ${ok}    Execute JavaScript
    ...    var el=arguments[0],v=arguments[1]; if(el){var last=el.value; el.value=v; var e=new Event('input',{bubbles:true}); if(el._valueTracker){el._valueTracker.setValue(last);} el.dispatchEvent(e);}
    ...    ${field}    ${value}

Update Customer And Save
    [Arguments]    ${first_name}=${EMPTY}    ${last_name}=${EMPTY}    ${company_name}=${EMPTY}    ${phone}=${EMPTY}

    Run Keyword If    '${first_name}'!=''     Fill Field In Edit Panel    First Name    ${first_name}
    Run Keyword If    '${last_name}'!=''      Fill Field In Edit Panel    Last Name     ${last_name}
    Run Keyword If    '${company_name}'!=''   Fill Field In Edit Panel    Company       ${company_name}
    Run Keyword If    '${phone}'!=''          Fill Field In Edit Panel    Phone         ${phone}

    Wait Until Element Is Visible    ${BTN_SAVE}    5s
    Click Element                    ${BTN_SAVE}

Customer Should See Profile Info
    [Arguments]    ${exp_name}    ${exp_email}    ${exp_phone}
    Switch Browser    CUSTOMER

    # ===== NAME =====
    ${loc_name}=    Set Variable    xpath=(//*[@data-testid='profile-page-wrapper']//span[@data-testid='current-info'])[1]
    Wait Until Element Is Visible    ${loc_name}    15s
    ${act_name}=    Get Text    ${loc_name}
    Should Be Equal As Strings    ${act_name}    ${exp_name}

    # ===== EMAIL =====
    ${loc_email}=    Set Variable    xpath=(//*[@data-testid='profile-page-wrapper']//span[@data-testid='current-info'])[2]
    Wait Until Element Is Visible    ${loc_email}    15s
    ${act_email}=    Get Text    ${loc_email}
    Should Be Equal As Strings    ${act_email}    ${exp_email}

    # ===== PHONE =====
    ${loc_phone}=    Set Variable    xpath=(//*[@data-testid='profile-page-wrapper']//span[@data-testid='current-info'])[3]
    Wait Until Element Is Visible    ${loc_phone}    15s
    ${act_phone}=    Get Text    ${loc_phone}
    Should Be Equal As Strings    ${act_phone}    ${exp_phone}