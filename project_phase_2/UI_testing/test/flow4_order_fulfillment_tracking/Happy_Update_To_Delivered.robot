*** Settings ***
Library           SeleniumLibrary    timeout=10s    implicit_wait=0.3    run_on_failure=Capture Page Screenshot
Resource          ../../config/env.robot
Resource          ../../pages/admin/AdminLogin.robot
Resource          ../../pages/customer/CustomerLogin.robot
Resource          ../../pages/customer/CustomerBuyProduct.robot
Resource          Happy_Update_To_Shipped.robot
Suite Setup       Open Admin Browser
Suite Teardown    Close All Browsers

*** Variables ***
# แถวแรกที่ Fulfillment = Shipped
${ROW_FIRST_SHIPPED}    xpath=(//table[.//th[normalize-space()='Fulfillment'] and .//th[normalize-space()='Order Total']]//tbody/tr
...    [normalize-space(.//td[count(preceding-sibling::td)=count(ancestor::table[1]
...    //th[normalize-space()='Fulfillment']/preceding-sibling::th)])='Shipped'])[1]

# ปุ่ม Mark as delivered ใน Fulfillment #1
${BTN_MARK_DELIVERED}      xpath=//button[normalize-space(.)='Mark as delivered']

# Modal ยืนยัน Mark as delivered
${MODAL_MARK_DELIVERED}    xpath=//*[@role='dialog' or @role='alertdialog'][.//h2[normalize-space(.)='Are you sure?']]
${BTN_CONFIRM_DELIVERED}   xpath=(//*[@role='dialog' or @role='alertdialog'][.//h2[normalize-space(.)='Are you sure?']]
...    //button[normalize-space(.)='Continue'])[1]


*** Keywords ***
Admin Open First Shipped Order
    [Documentation]    เปิด order แถวแรกที่ Fulfillment = Shipped จากหน้า Orders list
    Wait Until Element Is Visible    ${ROW_FIRST_SHIPPED}    10s
    Click Element                    ${ROW_FIRST_SHIPPED}

Admin Mark Current Order As Delivered
    Scroll To Fulfillment Section (Robust)
    Wait Until Element Is Visible    ${BTN_MARK_DELIVERED}    10s
    Click Element Safely             ${BTN_MARK_DELIVERED}
    Wait Until Element Is Visible    ${MODAL_MARK_DELIVERED}    10s
    Wait Until Element Is Visible    ${BTN_CONFIRM_DELIVERED}   10s
    Click Element Safely             ${BTN_CONFIRM_DELIVERED}
    Run Keyword And Ignore Error     Wait Until Page Does Not Contain Element    ${MODAL_MARK_DELIVERED}    10s
    Wait Until Page Contains         Delivered    10s

