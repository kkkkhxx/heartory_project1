*** Settings ***
Library           SeleniumLibrary    timeout=10s    implicit_wait=0.3
Resource          ../../config/Env.robot
Resource          ../../pages/admin/AdminLogin.robot
Resource          ../../pages/customer/CustomerLogin.robot
Resource          TC5_1_Happy_Edit_Customer_Profile.robot
Suite Setup       Open Admin Browser
Suite Teardown    Close All Browsers


*** Variables ***
${ADMIN_ADDR_CARD}         xpath=//div[contains(@class,'shadow-elevation-card-rest')][.//h2[normalize-space(.)='Addresses']]
${ADMIN_ADDR_ADD_BTN}      xpath=${ADMIN_ADDR_CARD}//button[normalize-space(.)='Add']

# Dialog เพิ่ม Address บน Admin
${ADDR_DIALOG}             xpath=//div[@role='dialog' and .//h1[normalize-space(.)='Add address'] or .//h1[normalize-space(.)='Add Address']]
${ADDR_SAVE_BTN}           xpath=${ADDR_DIALOG}//button[normalize-space(.)='Save']

*** Keywords ***
Fill Address Field In Dialog
    [Arguments]    ${label_text}    ${value}
    ${field}=    Set Variable
    ...    ${ADDR_DIALOG}//label[normalize-space(.)='${label_text}']/following::input[1]
    Wait Until Element Is Visible    ${field}    10s
    Click Element                    ${field}
    Clear Element Text               ${field}
    Input Text                       ${field}    ${value}

Admin Add Address For Customer
    [Arguments]    ${addr_label}    ${addr_line1}    ${city}=${EMPTY}    ${postal}=${EMPTY}    ${country}=${EMPTY}

    Switch Browser    ADMIN
    Wait Until Element Is Visible    ${ADMIN_ADDR_CARD}    10s
    Scroll Element Into View         ${ADMIN_ADDR_CARD}
    Click Element                    ${ADMIN_ADDR_ADD_BTN}
    Wait Until Element Is Visible    ${ADDR_DIALOG}    10s

    # ฟิลด์ที่ใช้จริงแล้วในโปรเจ็กต์มี label ว่าอะไร ให้ปรับตาม DOM เช่น:
    # Address nickname / Address label / First name / Address 1 / City / Postal code / Country
    Fill Address Field In Dialog    Address nickname    ${addr_label}
    Fill Address Field In Dialog    Address 1           ${addr_line1}

    Run Keyword If    '${city}'!=''      Fill Address Field In Dialog    City          ${city}
    Run Keyword If    '${postal}'!=''    Fill Address Field In Dialog    Postal code   ${postal}
    Run Keyword If    '${country}'!=''   Fill Address Field In Dialog    Country       ${country}

    Click Element                    ${ADDR_SAVE_BTN}
    Wait Until Element Is Not Visible    ${ADDR_DIALOG}    10s

Admin Should See Address
    [Arguments]    ${addr_label}    ${addr_line1}
    Switch Browser    ADMIN
    Wait Until Element Is Visible    ${ADMIN_ADDR_CARD}    10s

    ${addr_block}=    Set Variable
    ...    xpath=${ADMIN_ADDR_CARD}//div[
    ...        .//span[normalize-space(.)='${addr_label}']
    ...        and .//span[contains(normalize-space(.),'${addr_line1}')]
    ...    ]
    Wait Until Element Is Visible    ${addr_block}    10s

Customer Should See Addresses Info
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

