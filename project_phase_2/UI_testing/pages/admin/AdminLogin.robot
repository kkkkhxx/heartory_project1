*** Settings ***
Library    SeleniumLibrary    timeout=10s    implicit_wait=0.3
Resource   ../../config/env.robot

*** Variables ***
${LOC_USERNAME}       css=input[name="email"]
${LOC_PASSWORD}       css=input[name="password"]
${LOC_SUBMIT}         css=button[type="submit"]
${LOC_DASHBOARD_TAG}  xpath=//*[contains(.,'Orders')]

# ออปชันเสริม
${VIEWPORT_W}              1366
${VIEWPORT_H}              768

*** Keywords ***
Admin Page Should Be Visible
    Wait Until Element Is Visible    ${LOC_USERNAME}

Admin Login
    [Arguments]    ${user}    ${pass}
    Go To    ${ADMIN_URL}
    Admin Page Should Be Visible
    Input Text       ${LOC_USERNAME}    ${user}
    Input Text       ${LOC_PASSWORD}    ${pass}
    Click Button     ${LOC_SUBMIT}
    Wait Until Page Contains Element   ${LOC_DASHBOARD_TAG}    15s
    
Open Admin Browser
    [Documentation]    เปิดเบราว์เซอร์ด้วย alias=ADMIN และเข้า ${ADMIN_URL}
    Open Browser    about:blank    ${BROWSER}    alias=ADMIN
    Set Window Size    ${VIEWPORT_W}    ${VIEWPORT_H}
    Go To    ${ADMIN_URL}
