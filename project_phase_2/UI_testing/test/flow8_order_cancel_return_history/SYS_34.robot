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
    [Documentation]    ค้นหา Order โดยวนลูปไปเรื่อยๆ จนกว่าจะเจอ หรือจนกว่าปุ่ม Next จะกดไม่ได้ (เสมือนไม่จำกัดหน้า)
    
    # ใช้ Range เยอะๆ เพื่อรองรับกรณีหน้าเพิ่มขึ้นเรื่อยๆ (เช่น 999 หน้า)
    FOR    ${page_index}    IN RANGE    1    999
        Log    กำลังตรวจสอบหน้าที่: ${page_index}
        
        # 1. ตรวจสอบว่าเจอ Order ในหน้านี้ไหม
        ${order_visible}=    Run Keyword And Return Status    
        ...    Wait Until Element Is Visible    ${order_locator}    2s
        
        IF    ${order_visible}
            Log    เจอ Order แล้วที่หน้า ${page_index}
            RETURN    ${TRUE}
        END
        
        # 2. ถ้าไม่เจอ ให้เช็คว่าปุ่ม Next มีไหมและกดได้ไหม (เพื่อเช็คว่าเป็นหน้าสุดท้ายหรือยัง)
        ${next_exists}=     Run Keyword And Return Status    Element Should Be Visible    ${LOC_NEXT_BUTTON}
        ${next_enabled}=    Run Keyword And Return Status    Element Should Be Enabled    ${LOC_NEXT_BUTTON}
        
        # 3. ถ้าไม่มีปุ่ม Next หรือปุ่มกดไม่ได้ (Disabled) แปลว่าหมดหน้าแล้ว ให้จบการทำงาน
        IF    not ${next_exists} or not ${next_enabled}
            Log    ถึงหน้าสุดท้ายแล้วที่หน้า ${page_index} และยังไม่พบ Order
            RETURN    ${FALSE}
        END
        
        # 4. ถ้ายังไม่เจอและมีปุ่ม Next ให้กดไปหน้าถัดไป
        Click Element    ${LOC_NEXT_BUTTON}
        Sleep    2s    # รอโหลดหน้าใหม่
    END
    
    RETURN    ${FALSE}