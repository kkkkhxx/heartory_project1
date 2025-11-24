*** Settings ***
Library           SeleniumLibrary
Library           String
Resource          ../../pages/admin/AdminLogin.robot
Resource          ../../config/env.robot
Suite Setup       Open Admin Browser And Login
Suite Teardown    Close All Browsers

*** Variables ***
${LOC_ORDERS_MENU}              xpath=//*[contains(text(),'Orders')]
${LOC_ORDER_47}                 xpath=//tr[contains(.,'#47')]
${LOC_MENU_BUTTON}              xpath=//div[@class='flex items-center gap-x-4']/button
${LOC_CANCEL_OPTION}            xpath=//*[contains(text(),'Cancel')]
${LOC_CONTINUE_BTN}             xpath=//button[contains(.,'Continue')]
${LOC_ERROR_POPUP}              xpath=//*[contains(text(),'All fulfillments must be canceled before canceling an order')]
${LOC_NEXT_BUTTON}              xpath=//button[contains(.,'Next')]
${LOC_CLOSE_ERROR}              xpath=//button[contains(@class, 'close') or contains(.,'OK') or contains(.,'Close')]

${MAX_PAGES}                    5

*** Test Cases ***

TC8.2 ลูกค้ายกเลิก Order ที่ส่งแล้ว ไม่สามารถยกเลิกได้
    [Documentation]    ทดสอบการยกเลิก order #47 ที่ส่งแล้ว แล้วต้องแสดง error หลังกด Continue
    [Tags]    TC8.2    Unhappy    Order-Cancellation    Shipped-Order

    # Step 1: พยายามยกเลิก order #47 และตรวจสอบ error message หลังกด Continue
    Cancel Order #47 And Expect Error

    Log  TEST TC8.2 PASSED: ไม่สามารถยกเลิก Order ที่ส่งแล้วได้ และแสดง error ถูกต้อง

*** Keywords ***
Open Admin Browser And Login
    Open Admin Browser
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Sleep    3s

Cancel Order #47 And Expect Error
    # ไปที่หน้า Orders
    Click Element    ${LOC_ORDERS_MENU}
    Sleep    3s
    
    # ค้นหา Order #47 พร้อมรองรับการกด Next
    ${order_found}=    Find Order With Pagination    ${LOC_ORDER_47}
    
    IF    not ${order_found}
        Fail    ไม่พบ Order #47 ใน ${MAX_PAGES} หน้าแรก
    END
    
    # เลือก Order #47
    Click Element    ${LOC_ORDER_47}
    Sleep    3s

    # คลิกเมนูจุด 3 จุด
    Wait Until Element Is Visible    ${LOC_MENU_BUTTON}    10s
    Scroll Element Into View         ${LOC_MENU_BUTTON}
    Sleep    0.3s

    ${clicked}=    Run Keyword And Return Status    Click Element    ${LOC_MENU_BUTTON}

    IF    not ${clicked}
        Execute Javascript    arguments[0].click();    ARGUMENTS    ${LOC_MENU_BUTTON}
    END

    Sleep    1s

    # เลือก Cancel จากเมนู
    Wait Until Page Contains Element    ${LOC_CANCEL_OPTION}    10s
    Click Element    ${LOC_CANCEL_OPTION}
    Sleep    1s

    # กด Continue เพื่อดำเนินการยกเลิก
    Wait Until Page Contains Element    ${LOC_CONTINUE_BTN}    10s
    Click Element    ${LOC_CONTINUE_BTN}
    Sleep    2s

    # ตรวจสอบ error message ที่แสดงเป็น popup หลังกด Continue
    Wait Until Page Contains Element    ${LOC_ERROR_POPUP}    10s
    
    # ยืนยันว่ามีข้อความ error ปรากฏ
    Page Should Contain Element    ${LOC_ERROR_POPUP}
    
    Log    ตรวจสอบ error message สำเร็จ: All fulfillments must be canceled before canceling an order

    # ปิด popup error (ถ้ามีปุ่มปิด)
    ${has_close}=    Run Keyword And Return Status    Page Should Contain Element    ${LOC_CLOSE_ERROR}
    IF    ${has_close}
        Click Element    ${LOC_CLOSE_ERROR}
        Sleep    1s
    END

Find Order With Pagination
    [Arguments]    ${order_locator}
    [Documentation]    ค้นหา order ในหลายหน้าโดยกดปุ่ม Next ถ้าจำเป็น
    
    ${current_page}=    Set Variable    1
    
    WHILE    ${current_page} <= ${MAX_PAGES}
        # ตรวจสอบว่ามี order ในหน้าปัจจุบันหรือไม่
        ${order_visible}=    Run Keyword And Return Status    
        ...    Wait Until Element Is Visible    ${order_locator}    3s
        
        IF    ${order_visible}
            Log    พบ Order ในหน้า ${current_page}
            RETURN    ${TRUE}
        END
        
        # ตรวจสอบว่ามีปุ่ม Next และสามารถกดได้หรือไม่
        ${next_button_visible}=    Run Keyword And Return Status    
        ...    Wait Until Element Is Visible    ${LOC_NEXT_BUTTON}    2s
        
        ${next_button_enabled}=    Run Keyword And Return Status    
        ...    Element Should Be Enabled    ${LOC_NEXT_BUTTON}
        
        IF    not ${next_button_visible} or not ${next_button_enabled}
            Log    ไม่มีปุ่ม Next หรือปุ่ม Next ไม่สามารถกดได้ที่หน้า ${current_page}
            RETURN    ${FALSE}
        END
        
        # กดปุ่ม Next เพื่อไปหน้าถัดไป
        Log    กดปุ่ม Next ไปหน้า ${{${current_page} + 1}}
        Click Element    ${LOC_NEXT_BUTTON}
        Sleep    2s    # รอให้หน้าโหลด
        
        ${current_page}=    Evaluate    ${current_page} + 1
    END
    
    Log    ค้นหา Order ไม่พบใน ${MAX_PAGES} หน้าแรก
    RETURN    ${FALSE}