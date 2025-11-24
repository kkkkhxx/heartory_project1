*** Settings ***
Documentation     Automated UI Test for Flow 2: Admin creates product WITHOUT name and customer cannot see it (SYS_02)
Library           SeleniumLibrary    run_on_failure=Capture Page Screenshot

Suite Setup       Open Admin Browser
Suite Teardown    SeleniumLibrary.Close All Browsers


*** Variables ***
${ADMIN_LOGIN_URL}        http://10.34.112.158:9000/app/login
${ADMIN_URL}              http://10.34.112.158:9000/app/
${STORE_URL}              http://10.34.112.158:8000/dk/store

${ADMIN_USER}             group4@mu-store.local
${ADMIN_PASS}             Mp6!dzT3

${CUSTOMER_USER}          test@gmail.com
${CUSTOMER_PASS}          test123

# ใช้เป็นข้อความ marker ใน description ว่า "สินค้านี้คือของเทสต์" ห้ามไปโผล่หน้าลูกค้า
${INVALID_PRODUCT_DESCRIPTION}    Missing Name Product QA


*** Test Cases ***
SYS_02 Admin Cannot Save Product Without Name And Customer Cannot See It
    [Documentation]    Flow: Admin ไม่กรอกชื่อสินค้า → กด Continue แล้วเจอ validation → ไปฝั่งลูกค้าแล้วไม่เห็นสินค้าใหม่
    # 1–3: ไปหน้า Login + Login + เข้า Products → Create
    Admin Login SYS_02
    Open Product Create Form SYS_02

    # 4: ไม่กรอกชื่อสินค้า แล้วกด Continue → ต้องเจอ validation
    Leave Product Name Blank And Trigger Validation

    # ออกจากฝั่ง Admin
    Admin Logout SYS_02

    # 5–7: เปิดหน้าลูกค้า → Login → เข้า Store → ไม่พบสินค้าใหม่
    Open Customer Storefront SYS_02
    Customer Login SYS_02
    Verify Invalid Product Not Visible In Store


*** Keywords ***
Open Admin Browser
    Open Browser    ${ADMIN_LOGIN_URL}    chrome
    Maximize Browser Window
    Set Selenium Speed    0.3s


# ----------------------- ADMIN LOGIN / LOGOUT -----------------------
Admin Login SYS_02
    Log To Console    [SYS_02] Logging in as Admin...
    Go To    ${ADMIN_LOGIN_URL}
    Wait Until Element Is Visible    xpath=//input[@name='email']    20s
    Input Text    xpath=//input[@name='email']    ${ADMIN_USER}
    Input Text    xpath=//input[@name='password']    ${ADMIN_PASS}
    Click Button   xpath=//button[contains(.,'Continue with Email')]
    Wait Until Page Contains Element    xpath=//a[contains(.,'Products')]    30s
    Log To Console    [SYS_02] Admin logged in and dashboard visible.


Admin Logout SYS_02
    Log To Console    [SYS_02] Logging out as Admin...
    Run Keyword And Ignore Error    Click Element    xpath=//button[contains(.,'Logout') or contains(.,'Sign out')]
    Sleep    2s
    Log To Console    [SYS_02] Admin logged out.


# ----------------------- STEP 3: ไปหน้า Products → Create -----------------------
Open Product Create Form SYS_02
    Log To Console    [SYS_02] Navigate to product creation form...
    Click Element    xpath=//a[contains(.,'Products')]
    Wait Until Page Contains Element    xpath=//a[contains(.,'Create')]    20s
    Click Element    xpath=//a[contains(.,'Create')]
    Wait Until Page Contains    Details    20s
    Sleep    1s
    Capture Page Screenshot


# ----------------------- STEP 4: ไม่กรอกชื่อสินค้า แล้วกด Continue → ต้องเจอ validation -----------------------
Leave Product Name Blank And Trigger Validation
    Log To Console    [SYS_02] Leave product name EMPTY and click Continue to trigger validation...

    # ให้แน่ใจว่า Title ว่างจริง ๆ
    Wait Until Element Is Visible    xpath=(//input[@name='title'])[last()]    20s
    Clear Element Text               xpath=(//input[@name='title'])[last()]

    # กรอก Description เป็นข้อความพิเศษ ใช้เป็น marker ของสินค้าทดสอบ
    Run Keyword And Ignore Error
    ...    Wait Until Element Is Visible    xpath=(//textarea[@name='description'])[last()]    20s
    Run Keyword And Ignore Error
    ...    Input Text    xpath=(//textarea[@name='description'])[last()]    ${INVALID_PRODUCT_DESCRIPTION}

    Capture Page Screenshot

    # (ถ้า Save as draft ถูก disable ก็ถือว่าดี แต่ไม่บังคับให้ fail ถ้าไม่มีปุ่มนี้)
    Log To Console    [SYS_02] Optionally check 'Save as draft' disabled (if present)...
    Run Keyword And Ignore Error
    ...    Wait Until Element Is Visible    xpath=//button[contains(.,'Save as draft')]    5s
    Run Keyword And Ignore Error
    ...    Element Should Be Disabled    xpath=//button[contains(.,'Save as draft')]

    # ✅ กดปุ่ม Continue ด้วย JS เพื่อเลี่ยง click intercepted
    Log To Console    [SYS_02] Click Continue with EMPTY product name via JS...
    Wait Until Page Contains Element    xpath=//button[contains(.,'Continue')]    10s

    ${js}=    Catenate
    ...    var btns=[...document.querySelectorAll("button")].filter(b=>b.textContent.includes('Continue'));
    ...    if(btns.length){
    ...        var btn=btns[btns.length-1];
    ...        btn.scrollIntoView({behavior:'smooth',block:'center'});
    ...        btn.click();
    ...        return 'CLICKED';
    ...    }
    ...    return 'NOT_FOUND';

    ${result}=    Execute JavaScript    ${js}
    Log To Console    [SYS_02] Continue click result: ${result}

    
    Wait Until Page Contains Element    xpath=(//input[@name='title' and @aria-invalid='true'])[last()]    10s

    
    Wait Until Page Contains Element    xpath=//button[@role='tab' and contains(.,'Details') and @data-state='active']    10s

    Log To Console    [SYS_02] Validation triggered: cannot continue without product name.
    Capture Page Screenshot


# ----------------------- STEP 5: เปิดหน้า Customer Storefront -----------------------
Open Customer Storefront SYS_02
    Log To Console    [SYS_02] Opening customer storefront...
    Go To    ${STORE_URL}
    
    Wait Until Element Is Visible    xpath=//a[contains(.,'Account')]    30s
    Capture Page Screenshot


# ----------------------- STEP 6: ลูกค้า Login -----------------------
Customer Login SYS_02
    Log To Console    [SYS_02] Logging in as Customer...
    Click Element    xpath=//a[contains(.,'Account')]
    Wait Until Element Is Visible    xpath=//input[@name='email']    20s
    Input Text    xpath=//input[@name='email']    ${CUSTOMER_USER}
    Input Text    xpath=//input[@name='password']    ${CUSTOMER_PASS}
    Click Button   xpath=//button[contains(.,'Sign in')]
    Wait Until Page Contains    Overview    30s
    Log To Console    [SYS_02] Customer logged in.
    Capture Page Screenshot


# ----------------------- STEP 7: เข้า Store แล้วต้องไม่เห็นสินค้าใหม่ -----------------------
Verify Invalid Product Not Visible In Store
    Log To Console    [SYS_02] Verify INVALID product is NOT visible in Storefront...
    Go To    ${STORE_URL}
    Sleep    2s

    
    Page Should Not Contain    ${INVALID_PRODUCT_DESCRIPTION}

    Log To Console    [SYS_02] Product with description '${INVALID_PRODUCT_DESCRIPTION}' is NOT visible in Storefront (as expected).
    Capture Page Screenshot
