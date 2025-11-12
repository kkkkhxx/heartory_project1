*** Settings ***
Library           SeleniumLibrary    timeout=10s    implicit_wait=0.3
Resource          ../../config/Env.robot
Resource          ../../pages/admin/AdminLogin.robot
Suite Setup       Open Admin Browser
Suite Teardown    Close All Browsers

*** Variables ***
# ===== TODO: ปรับให้ตรง DOM ของคุณ =====
${ADMIN_LOGIN_USER}        css=input[name="email"]
${ADMIN_LOGIN_PASS}        css=input[name="password"]
${ADMIN_LOGIN_BTN}         xpath=//button[normalize-space(.)="Continue with Email"]
${ADMIN_DASH_TAG}          xpath=//aside//*[contains(normalize-space(.),"Orders")]

# เมนู Orders
${ADMIN_MENU_ORDERS}       xpath=//a[contains(normalize-space(.),"Orders")]

# ตาราง Orders
${ORDERS_TABLE}            xpath=//table[contains(@class,"text-ui-fg-subtle txt-compact-small relative w-full")]

# แถวแรกที่ Not fulfilled และ Order Total > 0 (เลิกผูกชื่อ Ham Burger)
${ROW_FIRST_NOT_FULFILLED}    xpath=(//table[.//th[normalize-space()='Fulfillment'] and .//th[normalize-space()='Order Total']]//tbody/tr
...    [normalize-space(.//td[count(preceding-sibling::td)=count(ancestor::table[1]//th[normalize-space()='Fulfillment']/preceding-sibling::th)])='Not fulfilled'
...    and normalize-space(.//td[count(preceding-sibling::td)=count(ancestor::table[1]//th[normalize-space()='Order Total']/preceding-sibling::th)])!='-'
...    and normalize-space(.//td[count(preceding-sibling::td)=count(ancestor::table[1]//th[normalize-space()='Order Total']/preceding-sibling::th)])!='0'
...    and normalize-space(.//td[count(preceding-sibling::td)=count(ancestor::table[1]//th[normalize-space()='Order Total']/preceding-sibling::th)])!='0.00'])[1]

# แถวแรกที่ Fulfilled
${ROW_FIRST_FULFILLED}    xpath=(//table[.//th[normalize-space()='Fulfillment'] and .//th[normalize-space()='Order Total']]//tbody/tr
...    [normalize-space(.//td[count(preceding-sibling::td)=count(ancestor::table[1]//th[normalize-space()='Fulfillment']/preceding-sibling::th)])='Fulfilled'])[1]

# หน้า Order detail – โซน
${SECTION_UNFULFILLED}      xpath=//*[self::section or self::div][.//h2[normalize-space(.)="Unfulfilled Items"]]
${SECTION_FULFILLED}        xpath=(//*[self::section or self::div][ .//*[self::h2 or self::h3][contains(normalize-space(.),'Fulfillment #1')] ][ not(ancestor::aside) ])[1]

# ปุ่ม/พาเนล
${BTN_UNFULFILLED_ICON}    xpath=(//*[self::section or self::div][ .//h2[normalize-space(.)='Unfulfilled Items'] ][ not(ancestor::aside) ])//*[normalize-space(.)='Awaiting fulfillment']/ancestor::*[self::div or self::section][1]//button[.//*[name()='svg']][not(ancestor::aside)][last()]
${PANEL_ANY}                xpath=//*[@role='menu' or @role='listbox' or @data-radix-popper-content or contains(@data-state,'open')]

# Fulfillment Modal
${MODAL_FULFILLMENT}       xpath=//*[@role="dialog"]
${DROP_LOCATION_INPUT}     xpath=(//*[@role="dialog"]//div[.//*[normalize-space(.)="Location"]])//*[@role="combobox"][1]
${OPT_FIRST_IN_LIST}       xpath=(//*[@role="option" or @data-radix-collection-item])[1]
${DROP_SHIPPING_METHOD}    xpath=(//*[@role="combobox" or @data-testid="shipping-method-select"])[1]
${OPT_EXPRESS_SHIPPING}    xpath=//*[contains(@role,"option") and normalize-space(.)="Express Shipping"]
${BTN_CREATE_FULFILLMENT}  xpath=//button[normalize-space(.)="Create Fulfillment"]

# Indicators / Toast
${ADMIN_TOAST_SUCCESS}     xpath=(//*[@role='status' or @role='alert' or @aria-live='polite' or @aria-live='assertive' or contains(@class,'toast')][contains(normalize-space(.),'Success') or contains(normalize-space(.),'Succeeded') or contains(normalize-space(.),'Fulfilled') or contains(normalize-space(.),'Shipped')])[1]
${ADMIN_TOAST_ERROR}       css=.toast.toast-error, [data-testid="toast-error"]
${BADGE_AWAITING}          xpath=//*[self::section or self::div][.//h2[normalize-space(.)="Fulfilled"]]
${BADGE_FULFILLED}         xpath=//button[normalize-space(.)="Mark as shipped"]
${MODAL_ANY}               xpath=//*[@role='dialog']

# เมนู
${MENU_FULFILL_ITEMS}      xpath=(//*[@role='menu' or @role='listbox']//*[normalize-space(translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'))='fulfill items'])[1]

# Modal: Mark fulfillment shipped
${MARK_SHIPPED_MODAL}    xpath=(//*[@role='dialog'][.//*[self::h1 or self::h2][normalize-space(.)='Mark fulfillment shipped']])[1]
${ADD_TRACKING_BTN}      xpath=//button[normalize-space(.)='Add tracking number']
${TRACKING_INPUT}        xpath=//input[@placeholder='123-456-789']
${NOTIFY_TOGGLE_OPTIONAL}  xpath=//*[@role='switch' or @aria-checked or contains(@class,'switch')]
${SAVE_SHIPPED_BTN}      xpath=//button[normalize-space(.)='Save']

# anchor เผื่อหา section ไม่เจอ แต่มีปุ่ม Mark as shipped
${SECTION_FROM_MARK_BTN}    xpath=(//button[normalize-space(.)='Mark as shipped']
...    /ancestor::*[self::section or self::div][1])[1]

*** Keywords ***
# ---------- helpers ----------
Admin Open Orders Page
    Switch Browser    ADMIN
    Click Element     ${ADMIN_MENU_ORDERS}
    Wait Until Element Is Visible    ${ORDERS_TABLE}    10s

Admin Open First Not Fulfilled Order
    Wait Until Element Is Visible    ${ROW_FIRST_NOT_FULFILLED}    10s
    Click Element     ${ROW_FIRST_NOT_FULFILLED}

Admin Open First Fulfilled Order
    Wait Until Element Is Visible    ${ROW_FIRST_FULFILLED}    10s
    Click Element     ${ROW_FIRST_FULFILLED}

Back To Orders List
    # เลือกวิธีใดวิธีหนึ่งที่หน้า UI คุณรองรับ
    # 1) กดเมนู Orders
    Click Element     ${ADMIN_MENU_ORDERS}
    Wait Until Element Is Visible    ${ORDERS_TABLE}    10s
    # หรือ 2) Go Back:
    # Go Back
    # Wait Until Element Is Visible    ${ORDERS_TABLE}    10s

Scroll Section Unfulfilled Into View
    Wait Until Page Contains Element    ${SECTION_UNFULFILLED}    15s
    Scroll Element Into View            ${SECTION_UNFULFILLED}
    Sleep    200ms
    Execute Javascript    window.scrollBy(0, -80);

Scroll Section Fulfilled Into View
    Wait Until Page Contains Element    ${SECTION_FULFILLED}    15s
    Scroll Element Into View            ${SECTION_FULFILLED}
    Sleep    200ms
    Execute Javascript    window.scrollBy(0, -80);

Click Element Safely
    [Arguments]    ${locator}
    Wait Until Keyword Succeeds    5x    1s    Element Should Be Visible    ${locator}
    ${ok}=    Run Keyword And Return Status    Click Element    ${locator}
    Run Keyword If    not ${ok}    Click Via JS    ${locator}

Click Via JS
    [Arguments]    ${locator}
    Execute Javascript    return window.robotReady = true;
    ${el}=    Get WebElement    ${locator}
    ${ok}=    Run Keyword And Return Status    Execute Javascript    arguments[0].click();    ${el}
    Run Keyword If    not ${ok}    Click Element    ${locator}

Open Unfulfilled Action Trigger
    Scroll Section Unfulfilled Into View
    Wait Until Element Is Visible    ${BTN_UNFULFILLED_ICON}    5s
    ${ok}=    Run Keyword And Return Status    Click Element    ${BTN_UNFULFILLED_ICON}
    Run Keyword If    not ${ok}    Click Via JS    ${BTN_UNFULFILLED_ICON}
    Wait Until Page Contains Element    ${PANEL_ANY}    5s

Open Fulfill Modal If Needed
    ${modal_ready}=    Run Keyword And Return Status    Page Should Contain Element    ${MODAL_FULFILLMENT}
    Run Keyword If    ${modal_ready}    Return From Keyword
    ${has_menu}=    Run Keyword And Return Status    Page Should Contain Element    ${MENU_FULFILL_ITEMS}
    Run Keyword If    ${has_menu}    Click Element    ${MENU_FULFILL_ITEMS}
    Run Keyword If    not ${has_menu}    Click Element    ${OPT_FIRST_IN_LIST}
    Wait Until Page Contains Element    ${MODAL_FULFILLMENT}    7s

Open Location Dropdown (In Fulfillment Modal)
    Wait Until Page Contains Element    ${MODAL_FULFILLMENT}    10s
    ${has_btn}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${DROP_LOCATION_INPUT}    2s
    Run Keyword If    ${has_btn}    Run Keywords
    ...    Click Element    ${DROP_LOCATION_INPUT}
    ...    AND    Wait Until Page Contains Element    ${PANEL_ANY}    5s
    Run Keyword If    ${has_btn}    Return From Keyword
    Wait Until Element Is Visible    ${DROP_LOCATION_INPUT}    5s
    Click Element    ${DROP_LOCATION_INPUT}
    Wait Until Page Contains Element    ${PANEL_ANY}    5s

Select Location In Dropdown
    [Arguments]    ${name}=European Warehouse
    ${target}=    Set Variable If    '${name}'!=''    xpath=//*[contains(@role,'option') and normalize-space(.)='${name}']    ${OPT_FIRST_IN_LIST}
    ${has_named}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${target}    2s
    Run Keyword If    ${has_named}        Click Element    ${target}
    Run Keyword If    not ${has_named}    Click Element    ${OPT_FIRST_IN_LIST}

Verify Fulfillment Succeeded
    Run Keyword And Ignore Error    Wait Until Page Does Not Contain Element    ${MODAL_ANY}    10s
    Wait Until Keyword Succeeds    10x    1s    Check Any Success Indicator

Check Any Success Indicator
    ${ok1}=    Run Keyword And Return Status    Page Should Contain Element         ${ADMIN_TOAST_SUCCESS}
    ${ok2}=    Run Keyword And Return Status    Page Should Contain Element         ${BADGE_AWAITING}
    ${ok3}=    Run Keyword And Return Status    Page Should Contain Element         ${BADGE_FULFILLED}
    ${ok4}=    Run Keyword And Return Status    Page Should Not Contain Element     ${MODAL_ANY}
    Run Keyword If    ${ok1} or ${ok2} or ${ok3} or ${ok4}    Return From Keyword
    Fail    No success indicators found yet.

Admin Fill Fulfillment Form And Submit
    Wait Until Page Contains Element    ${MODAL_FULFILLMENT}    10s
    Open Location Dropdown (In Fulfillment Modal)
    Select Location In Dropdown    European Warehouse
    Wait Until Element Is Visible    ${DROP_SHIPPING_METHOD}   10s
    Click Element     ${DROP_SHIPPING_METHOD}
    ${has_named}=    Run Keyword And Return Status    Wait Until Element Is Visible    ${OPT_EXPRESS_SHIPPING}    3s
    Run Keyword If    ${has_named}         Click Element    ${OPT_EXPRESS_SHIPPING}
    Run Keyword If    not ${has_named}     Click Element    ${OPT_FIRST_IN_LIST}
    Click Button      ${BTN_CREATE_FULFILLMENT}
    Wait Until Keyword Succeeds    12x    500ms    Check Any Success Indicator
    Verify Fulfillment Succeeded

Check Shipped Indicator
    ${ok1}=    Run Keyword And Return Status    Page Should Contain Element    ${ADMIN_TOAST_SUCCESS}
    ${ok2}=    Run Keyword And Return Status    Page Should Contain             Shipped
    Run Keyword If    ${ok1} or ${ok2}    Return From Keyword
    Fail    Not shipped yet.

Generate Tracking Number
    ${ts}=    Get Time    epoch
    ${tracking}=    Set Variable    TRK-${ts}
    [Return]    ${tracking}

Fill Mark Shipped Modal And Save
    [Arguments]    ${tracking_number}=EF582568151    ${send_notification}=true
    Wait Until Page Contains Element    ${MARK_SHIPPED_MODAL}    10s
    Wait Until Element Is Visible       ${ADD_TRACKING_BTN}      10s
    Click Element                       ${ADD_TRACKING_BTN}
    Wait Until Page Contains Element    ${TRACKING_INPUT}        10s
    Wait Until Element Is Visible       ${TRACKING_INPUT}        5s
    Wait Until Keyword Succeeds         5x    500ms    Element Should Be Enabled    ${TRACKING_INPUT}
    Run Keyword If    '${tracking_number}'=='EF582568151'    ${tracking_number}=    Generate Tracking Number
    Clear Element Text    ${TRACKING_INPUT}
    Input Text            ${TRACKING_INPUT}    ${tracking_number}
    ${has_toggle}=    Run Keyword And Return Status    Page Should Contain Element    ${NOTIFY_TOGGLE_OPTIONAL}
    Run Keyword If    ${has_toggle} and not ${send_notification}    Click Element    ${NOTIFY_TOGGLE_OPTIONAL}
    Click Button       ${SAVE_SHIPPED_BTN}
    Run Keyword And Ignore Error    Wait Until Page Does Not Contain Element    ${MARK_SHIPPED_MODAL}    10s

Scroll To Fulfillment Section (Robust)
    [Documentation]    เลื่อนไปยังโซน Fulfillment อย่างถึกทน (รองรับ contains, sticky header, virtualized list)

    # 0) ตั้งค่า default เพื่อกัน Variable not found
    ${has_anchor}=    Set Variable    ${False}
    ${has_btn}=       Set Variable    ${False}

    # 1) รอ heading หรือปุ่มอยู่ใน DOM
    Wait Until Keyword Succeeds    10x    500ms
    ...    Run Keywords
    ...    Run Keyword And Ignore Error    Page Should Contain Element    ${SECTION_FULFILLED}
    ...    AND    Run Keyword And Ignore Error    Page Should Contain Element    ${BADGE_FULFILLED}

    # 2) ถ้ามี section ให้ไปหา section ก่อน
    ${has_section}=    Run Keyword And Return Status    Page Should Contain Element    ${SECTION_FULFILLED}
    Run Keyword If    ${has_section}    Run Keywords
    ...    Scroll Element Into View    ${SECTION_FULFILLED}
    ...    AND    Sleep    200ms
    ...    AND    Execute Javascript    window.scrollBy(0, -80);
    Run Keyword If    ${has_section}    Return From Keyword

    # 3) ไม่มี section? ลองหา ancestor ของปุ่ม Mark as shipped มาเป็น anchor
    ${has_btn}=    Run Keyword And Return Status    Page Should Contain Element    ${BADGE_FULFILLED}
    Run Keyword If    ${has_btn}    Set Test Variable    ${_try_anchor}    ${SECTION_FROM_MARK_BTN}
    Run Keyword If    ${has_btn}    ${has_anchor}=    Run Keyword And Return Status    Page Should Contain Element    ${_try_anchor}
    Run Keyword If    ${has_anchor}    Run Keywords
    ...    Scroll Element Into View    ${_try_anchor}
    ...    AND    Sleep    200ms
    ...    AND    Execute Javascript    window.scrollBy(0, -80);
    Run Keyword If    ${has_anchor}    Return From Keyword

    # 4) ถ้าไม่มี anchor ก็เลื่อนไปที่ปุ่มโดยตรง
    Run Keyword If    ${has_btn}    Run Keywords
    ...    Scroll Element Into View    ${BADGE_FULFILLED}
    ...    AND    Sleep    200ms
    ...    AND    Execute Javascript    window.scrollBy(0, -80);
    Run Keyword If    ${has_btn}    Return From Keyword

    # 5) กัน virtualized UI: สไลด์ทั้งหน้าเพื่อให้ component render
    FOR    ${i}    IN RANGE    12
        Execute Javascript    window.scrollBy(0, Math.round(window.innerHeight*0.7));
        Sleep    200ms
        ${ok}=     Run Keyword And Return Status    Page Should Contain Element    ${SECTION_FULFILLED}
        Run Keyword If    ${ok}    Run Keywords
        ...    Scroll Element Into View    ${SECTION_FULFILLED}
        ...    AND    Sleep    150ms
        ...    AND    Execute Javascript    window.scrollBy(0, -80);
        ...    AND    Exit For Loop
        ${ok2}=    Run Keyword And Return Status    Page Should Contain Element    ${BADGE_FULFILLED}
        Run Keyword If    ${ok2}    Run Keywords
        ...    Scroll Element Into View    ${BADGE_FULFILLED}
        ...    AND    Sleep    150ms
        ...    AND    Execute Javascript    window.scrollBy(0, -80);
        ...    AND    Exit For Loop
    END

    ${seen}=      Run Keyword And Return Status    Page Should Contain Element    ${SECTION_FULFILLED}
    ${seen_btn}=  Run Keyword And Return Status    Page Should Contain Element    ${BADGE_FULFILLED}
    Run Keyword If    not ${seen} and not ${seen_btn}    Fail    Could not locate Fulfillment section or Mark as shipped button. Check DOM/iframe/text.


*** Test Cases ***
TC4_1_Happy_Update_To_Shipped
    [Documentation]    Update shipping status
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Admin Open Orders Page
    Admin Open First Not Fulfilled Order
    Open Unfulfilled Action Trigger
    Open Fulfill Modal If Needed
    Admin Fill Fulfillment Form And Submit
    Scroll To Fulfillment Section (Robust)
    Wait Until Page Contains Element    ${BADGE_FULFILLED}    10s
    Click Element    ${BADGE_FULFILLED}
    Fill Mark Shipped Modal And Save    TH1234567890    ${False}
    Wait Until Keyword Succeeds    12x    500ms    Check Shipped Indicator
    Back To Orders List


