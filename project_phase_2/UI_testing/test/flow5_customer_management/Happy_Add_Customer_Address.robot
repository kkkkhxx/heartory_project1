#=====================================================================#
#                      Happy_Add_Customer_Address                     #
#=====================================================================#

*** Settings ***
Library           SeleniumLibrary    timeout=10s    implicit_wait=0.3
Resource          ../../config/Env.robot
Resource          ../../pages/admin/AdminLogin.robot
Resource          ../../pages/customer/CustomerLogin.robot
Resource          Happy_Edit_Customer_Profile.robot
Suite Setup       Open Admin Browser


*** Variables ***
${ADMIN_ADDR_CARD}       //div[contains(@class,'shadow-elevation-card-rest')][.//h2[normalize-space(.)='Addresses']]
${ADMIN_ADDR_ADD_BTN}    xpath=${ADMIN_ADDR_CARD}//a[normalize-space(.)='Add']
${ADDR_DIALOG}    //div[@role='dialog' and (.//h1[normalize-space(.)='Create Address'])]
${ADDR_SAVE_BTN}  xpath=${ADDR_DIALOG}//button[normalize-space(.)='Save']


*** Keywords ***
Fill Address Field By Name
    [Arguments]    ${field_name}    ${value}
    ${locator}=    Set Variable    xpath=${ADDR_DIALOG}//input[@name='${field_name}']
    Wait Until Element Is Visible    ${locator}    10s
    Click Element                    ${locator}
    Clear Element Text               ${locator}
    Input Text                       ${locator}    ${value}

Select Country
    [Arguments]    ${country_code}
    ${select}=    Set Variable    xpath=${ADDR_DIALOG}//select[@name='country_code']
    Wait Until Element Is Visible    ${select}    10s
    Select From List By Value        ${select}    ${country_code}

Admin Fill Create Address Form
    [Arguments]
    ...    ${address_name}
    ...    ${address_1}
    ...    ${address_2}
    ...    ${postal_code}
    ...    ${city}
    ...    ${country_code}
    ...    ${company}=${EMPTY}
    ...    ${phone}=${EMPTY}

    Switch Browser    ADMIN
    Wait Until Element Is Visible    ${ADDR_DIALOG}    10s

    Fill Address Field By Name    address_name    ${address_name}
    Fill Address Field By Name    address_1       ${address_1}
    Fill Address Field By Name    address_2       ${address_2}
    Fill Address Field By Name    postal_code     ${postal_code}
    Fill Address Field By Name    city            ${city}

    Select Country               ${country_code}

    Run Keyword If    '${company}'!=''    Fill Address Field By Name    company    ${company}
    Run Keyword If    '${phone}'!=''      Fill Address Field By Name    phone      ${phone}

Admin Add Address For Customer
    [Arguments]    ${address_name}    ${address_1}    ${address_2}    ${postal}    ${city}    ${country_code}    ${company}=${EMPTY}    ${phone}=${EMPTY}

    Switch Browser    ADMIN
    Wait Until Element Is Visible    ${ADMIN_ADDR_ADD_BTN}    10s
    Click Element                    ${ADMIN_ADDR_ADD_BTN}
    Wait Until Element Is Visible    ${ADDR_DIALOG}    10s

    Admin Fill Create Address Form
    ...    ${address_name}
    ...    ${address_1}
    ...    ${address_2}
    ...    ${postal}
    ...    ${city}
    ...    ${country_code}
    ...    ${company}
    ...    ${phone}
    Click Element    ${ADDR_SAVE_BTN}
    Wait Until Element Is Not Visible    ${ADDR_DIALOG}    10s

Admin Should See Address
    [Arguments]    ${addr_label}    ${addr_line1}    ${addr_line2}
    Switch Browser    ADMIN
    Wait Until Element Is Visible    ${ADMIN_ADDR_CARD}    10s
    ${full_addr}=    Catenate    SEPARATOR=    ${addr_line1} ${addr_line2}
    ${addr_block}=    Catenate    SEPARATOR=    xpath=${ADMIN_ADDR_CARD}//div[.//p[normalize-space(.)='${addr_label}'] 
    ...    and .//p[contains(normalize-space(.),'${full_addr}')]]
    Wait Until Element Is Visible    ${addr_block}    10s

Customer Should See Addresses Info
    [Arguments]    ${addr_line1}    ${postal_city}    ${country_code}
    Switch Browser    CUSTOMER

    # รอให้หน้า Shipping Addresses โหลด
    Wait Until Element Is Visible    xpath=//*[@data-testid='addresses-page-wrapper']    15s

    ${addr_block}=    Catenate    SEPARATOR=
    ...    xpath=//*[@data-testid='addresses-page-wrapper']
    ...    //div[@data-testid='address-container'
    ...        and .//span[@data-testid='address-address'][contains(normalize-space(.),"${addr_line1}")]
    ...        and .//span[@data-testid='address-postal-city'][contains(normalize-space(.),"${postal_city}")]
    ...        and .//span[@data-testid='address-province-country'][contains(normalize-space(.),"${country_code}")]
    ...    ]
    Wait Until Element Is Visible    ${addr_block}    10s




