*** Settings ***
Library    SeleniumLibrary
Resource   ../../pages/customer/CustomerLogin.robot
Variables  ../../config/Env.robot

*** Variables ***
${LOC_FIRST_NAME}      css=input[data-testid="first-name-input"]
${LOC_LAST_NAME}       css=input[data-testid="last-name-input"]
${LOC_EMAIL}           css=input[data-testid="email-input"]
${LOC_PASSWORD}        css=input[data-testid="password-input"]
${LOC_JOIN_BUTTON}     css=button[data-testid="register-button"]
${LOC_ACCOUNT_LINK}    css=a[data-testid="nav-account-link"]
${LOC_JOIN_US_BUTTON}  css=button[data-testid="register-button"]
${EXPECTED_URL}        http://10.34.112.158:8000/dk/account
${LOC_EMAIL_MESSAGE}   css=span[data-testid="customer-email"]  
${VIEWPORT_W}          1366
${VIEWPORT_H}          768

*** Test Cases ***
Test Customer Signup
    Open Customer Browser
    Navigate To Account Page
    Click Join Us Button
    Customer Signup    Cole    Palmer    cp23@example.com    1234
    Verify Account Page    
    Verify Email Message    cp23@example.com

*** Keywords ***
Customer Page Should Be Visible
    Wait Until Element Is Visible    ${LOC_FIRST_NAME}

Customer Signup
    [Arguments]    ${first_name}    ${last_name}    ${email}    ${password}
    Input Text    ${LOC_FIRST_NAME}    ${first_name}
    Input Text    ${LOC_LAST_NAME}     ${last_name}
    Input Text    ${LOC_EMAIL}         ${email}
    Input Text    ${LOC_PASSWORD}      ${password}
    Click Button   ${LOC_JOIN_BUTTON}
    Wait Until Page Contains Element   ${LOC_JOIN_BUTTON}    15s

Navigate To Account Page
    Go To    ${CUSTOMER_URL}
    Wait Until Element Is Visible    ${LOC_ACCOUNT_LINK}    10s
    Click Element    ${LOC_ACCOUNT_LINK}
    Wait Until Page Contains Element    ${LOC_JOIN_US_BUTTON}    15s

Click Join Us Button
    Wait Until Element Is Visible    ${LOC_JOIN_US_BUTTON}    10s
    Click Element    ${LOC_JOIN_US_BUTTON}
    Wait Until Element Is Visible    ${LOC_FIRST_NAME}    15s

Verify Account Page
    ${current_url}=    Get Location
    Should Be Equal As Strings    ${current_url}    ${EXPECTED_URL}

Verify Email Message
    [Arguments]    ${email}
    Wait Until Element Is Visible    ${LOC_EMAIL_MESSAGE}    15s
    ${data_value}=    Get Element Attribute    ${LOC_EMAIL_MESSAGE}    data-value
    Should Be Equal As Strings    ${data_value}    ${email}
