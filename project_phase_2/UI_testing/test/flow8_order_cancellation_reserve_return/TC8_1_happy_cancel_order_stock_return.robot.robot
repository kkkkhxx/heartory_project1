*** Settings ***
Library           SeleniumLibrary
Library           String
Resource          ../../pages/admin/AdminLogin.robot
Resource          ../../config/env.robot
Suite Setup       Open Admin Browser And Login
Suite Teardown    Close All Browsers

*** Variables ***
${LOC_ORDERS_MENU}              xpath=//*[contains(text(),'Orders')]
${LOC_ORDER_84}                xpath=//tr[contains(.,'#84')]
${LOC_MENU_BUTTON}              xpath=//div[@class='flex items-center gap-x-4']/button
${LOC_CANCEL_OPTION}            xpath=//*[contains(text(),'Cancel')]
${LOC_CONTINUE_BTN}             xpath=//button[contains(.,'Continue')]
${LOC_INVENTORY_MENU}           xpath=//*[contains(text(),'Inventory')]
${LOC_INVENTORY_SEARCH}         xpath=//input[contains(@placeholder,'Search') or contains(@class,'search')]
${LOC_M_WHITE_ROW}              xpath=//tr[contains(.,'M / White')]
${LOC_M_WHITE_LINK}             xpath=//tr[contains(.,'M / White')]//a
${LOC_RESERVED_VALUE}           xpath=//tbody//tr[td[1]//text()[contains(.,'European Warehouse')]]/td[2]

${TEST_VARIANT}                 M / White

*** Test Cases ***
TC8.1 ลูกค้ายกเลิก Order ที่ยังไม่ส่ง Stock ต้องคืนให้ admin
    [Documentation]    ทดสอบการยกเลิก order #55C และตรวจสอบว่า Reserved คืนกลับจาก 16 เป็น 15
    [Tags]    TC8.1    Happy    Order-Cancellation    Stock-Return

    # Step 1: ตรวจสอบค่า Reserved ก่อนยกเลิก (ควรเป็น 2)
    ${initial_reserved}=    Get Reserved Quantity
    Should Be Equal As Numbers    ${initial_reserved}    2
    Log    Reserved ก่อนยกเลิก: ${initial_reserved}

    # Step 2: ยกเลิก order #55C
    Cancel Order #84

    # Step 3: ตรวจสอบค่า Reserved หลังยกเลิก (ควรเป็น 0)
    ${final_reserved}=    Get Reserved Quantity
    Should Be Equal As Numbers    ${final_reserved}    0
    Log    Reserved หลังยกเลิก: ${final_reserved}

    Log   TEST TC8.1 PASSED: ยกเลิก Order สำเร็จ และ Reserved คืนจาก 16 เป็น 15

*** Keywords ***
Open Admin Browser And Login
    Open Admin Browser
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Sleep    3s

Get Reserved Quantity
    # ไปที่หน้า Inventory
    Click Element    ${LOC_INVENTORY_MENU}
    Sleep    3s

    # ค้นหา variant M / White
    Input Text    ${LOC_INVENTORY_SEARCH}    ${TEST_VARIANT}
    Press Keys    ${LOC_INVENTORY_SEARCH}    ENTER
    Sleep    3s

    # หาแถวของ M / White
    Wait Until Page Contains Element    ${LOC_M_WHITE_ROW}    10s
    
    # คลิกเข้าไปดูรายละเอียด M / White
    Wait Until Page Contains Element    ${LOC_M_WHITE_LINK}    10s
    Click Element    ${LOC_M_WHITE_LINK}
    Sleep    3s

    # รอจนหน้าโหลดและมีตาราง Locations
    Wait Until Page Contains    European Warehouse    10s
    
    # ดึงค่า Reserved จากตาราง Locations
    Wait Until Page Contains Element    ${LOC_RESERVED_VALUE}    10s
    ${reserved_text}=    Get Text    ${LOC_RESERVED_VALUE}
    Log    Reserved text: ${reserved_text}
    
    # แปลงเป็นตัวเลข
    ${reserved_qty}=    Convert To Integer    ${reserved_text}
    
    # กลับไปหน้า Inventory
    Click Element    ${LOC_INVENTORY_MENU}
    Sleep    2s
    
    RETURN    ${reserved_qty}

Cancel Order #84
    # ไปที่หน้า Orders
    Click Element    ${LOC_ORDERS_MENU}
    Wait Until Page Contains Element    ${LOC_ORDER_84}      10s
    Sleep    2s
    
    # เลือก Order #84
    Click Element    ${LOC_ORDER_84}  
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

    # ยืนยันการยกเลิกโดยกด Continue
    Wait Until Page Contains Element    ${LOC_CONTINUE_BTN}    10s
    Click Element    ${LOC_CONTINUE_BTN}
    Sleep    2s

    # Refresh หน้าเพื่ออัพเดทค่า reserved
    Reload Page
    Sleep    3s
    
    # กลับไปที่หน้า Orders อีกครั้ง
    Click Element    ${LOC_ORDERS_MENU}
    Sleep    2s