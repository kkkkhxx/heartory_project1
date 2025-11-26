*** Settings ***
Library    SeleniumLibrary    timeout=10s    implicit_wait=0.3
Resource   ../../pages/customer/CustomerLogin.robot
Variables  ../../config/Env.robot

*** Variables ***
${CUS_LOC_USERNAME}        css=input[name="email"]
${CUS_LOC_PASSWORD}        css=input[name="password"]
${CUS_LOC_SUBMIT}          css=button[type="submit"]
${CUS_LOC_NAV_ACCOUNT}     css=a[data-testid="nav-account-link"]
${CUS_LOC_LOGOUT_BUTTON}   xpath=//div[@data-testid='account-nav']//button[@data-testid='logout-button']
${CUS_LOC_SIGNIN_MESSAGE}  xpath=//p[normalize-space()='Sign in to access an enhanced shopping experience.']

${VIEWPORT_W}              1366
${VIEWPORT_H}              768

*** Test Cases ***
Test Customer Logout
    Open Customer Browser
    Customer Login    ${CUS_USER_HAM}    ${CUS_PASS_HAM}
    Logout
    Verify Logout Success

*** Keywords ***
Open Customer Browser
    Open Browser    about:blank    ${BROWSER}    alias=CUSTOMER
    Set Window Size    ${VIEWPORT_W}    ${VIEWPORT_H}
    Go To    ${CUSTOMER_URL}

Customer Login
    [Arguments]    ${email}    ${password}
    Switch Browser    CUSTOMER
    Go To    ${CUSTOMER_URL}
    Wait Until Element Is Visible    ${CUS_LOC_NAV_ACCOUNT}    10s
    Click Element    ${CUS_LOC_NAV_ACCOUNT}
    Wait Until Element Is Visible    ${CUS_LOC_USERNAME}    10s
    Input Text    ${CUS_LOC_USERNAME}    ${email}
    Input Text    ${CUS_LOC_PASSWORD}    ${password}
    Click Button    ${CUS_LOC_SUBMIT}
    Wait Until Element Is Visible    ${CUS_LOC_NAV_ACCOUNT}    15s

Logout
    Wait Until Element Is Visible    ${CUS_LOC_NAV_ACCOUNT}    10s
    Click Element    ${CUS_LOC_NAV_ACCOUNT}    # Click to open the account menu
    Wait Until Element Is Visible    ${CUS_LOC_LOGOUT_BUTTON}    10s
    Click Element    ${CUS_LOC_LOGOUT_BUTTON}    # Click the "Log out" button
    Wait Until Element Is Visible    ${CUS_LOC_SIGNIN_MESSAGE}    15s  # Verify the sign-in message appears

Verify Logout Success
    Wait Until Element Is Visible    ${CUS_LOC_SIGNIN_MESSAGE}    15s
    Element Text Should Be    ${CUS_LOC_SIGNIN_MESSAGE}    Sign in to access an enhanced shopping experience.
