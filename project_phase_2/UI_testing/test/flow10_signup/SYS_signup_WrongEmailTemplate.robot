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
${LOC_EMAIL_ERROR}     css=div[data-testid="register-error"] 
${LOC_EMAIL_MESSAGE}   css=span[data-testid="customer-email"]  

${VIEWPORT_W}          1366
${VIEWPORT_H}          768

*** Test Cases ***
Test Customer Signup with Invalid Email
    Open Customer Browser
    Navigate To Account Page
    Click Join Us Button
    Customer Signup    Cole    Palmer    j    1234
    Verify No Redirection To Account Page

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



Verify No Redirection To Account Page
    ${current_url}=    Get Location
