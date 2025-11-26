*** Settings ***
Resource          ../../pages/customer/CustomerLogin.robot
Resource          ../../config/Env.robot
Resource          ../flow5_customer_management/Happy_Edit_Customer_Profile.robot
Resource          ../flow5_customer_management/Happy_Create_New_Customer.robot
Resource          ../flow5_customer_management/Happy_Delete_Customer.robot
Suite Teardown    Close All Browsers
Suite Setup       Open Customer Browser


*** Variables ***
${PROFILE_TITLE}            xpath=//div[@data-testid='account-page']//h1[normalize-space(.)='Profile']

${EDIT_BTN_CUS_NAME}        xpath=//div[@data-testid='account-name-editor']//button[@data-testid='edit-button']
${EDIT_BTN_CUS_PHONE}       xpath=//div[@data-testid='account-phone-editor']//button[@data-testid='edit-button']

# แยกปุ่ม Save ตาม section (ไม่ใช้ type="submit" กว้าง ๆ แล้ว)
${SAVE_BTN_CUS_NAME}        xpath=//div[@data-testid='account-name-editor']//button[@data-testid='save-button']
${SAVE_BTN_CUS_PHONE}       xpath=//div[@data-testid='account-phone-editor']//button[@data-testid='save-button']

${INPUT_FNAME}              css=input[name="first_name"]
${INPUT_LNAME}              css=input[name="last_name"]
${INPUT_PHONE}              css=input[name="phone"]

${DISPLAY_NAME}             xpath=//div[@data-testid='account-name-editor']//span[@data-testid='current-info']
${DISPLAY_PHONE}            xpath=//div[@data-testid='account-phone-editor']//span[@data-testid='current-info']


*** Keywords ***
Customer Edit Name
    [Arguments]    ${first_name}    ${last_name}
    Wait Until Element Is Visible    ${PROFILE_TITLE}        10s
    Wait Until Element Is Visible    ${EDIT_BTN_CUS_NAME}    10s
    Click Element                    ${EDIT_BTN_CUS_NAME}

    Wait Until Element Is Visible    ${INPUT_FNAME}          10s
    Clear Element Text               ${INPUT_FNAME}
    Input Text                       ${INPUT_FNAME}    ${first_name}

    Wait Until Element Is Visible    ${INPUT_LNAME}          10s
    Clear Element Text               ${INPUT_LNAME}
    Input Text                       ${INPUT_LNAME}    ${last_name}

    # กันกรณีปุ่ม Save ถูกบัง → scroll ให้ปุ่มอยู่กลางจอ แล้วค่อยคลิก
    Wait Until Element Is Visible    ${SAVE_BTN_CUS_NAME}    10s
    Scroll Element Into View         ${SAVE_BTN_CUS_NAME}
    Sleep    0.3s
    Click Element                    ${SAVE_BTN_CUS_NAME}

    ${expected_name}=    Set Variable    ${first_name} ${last_name}
    Wait Until Element Contains       ${DISPLAY_NAME}    ${expected_name}    10s
    # รอให้ editor ปิด (input หายไป) กัน conflict กับ editor ถัดไป
    Wait Until Element Is Not Visible    ${INPUT_FNAME}    10s


Customer Edit Phone
    [Arguments]    ${phone_number}
    Wait Until Element Is Visible    ${PROFILE_TITLE}         10s
    Wait Until Element Is Visible    ${EDIT_BTN_CUS_PHONE}    10s
    Click Element                    ${EDIT_BTN_CUS_PHONE}

    Wait Until Element Is Visible    ${INPUT_PHONE}           10s
    Clear Element Text               ${INPUT_PHONE}
    Input Text                       ${INPUT_PHONE}    ${phone_number}

    Wait Until Element Is Visible    ${SAVE_BTN_CUS_PHONE}    10s
    Scroll Element Into View         ${SAVE_BTN_CUS_PHONE}
    Sleep    0.3s
    Click Element                    ${SAVE_BTN_CUS_PHONE}

    Wait Until Element Contains      ${DISPLAY_PHONE}    ${phone_number}    10s
    Wait Until Element Is Not Visible    ${INPUT_PHONE}    10s


*** Test Cases ***
SYS20_Happy_Customer_Edit_Profiles
    Customer Login    eatmatcha@example.com    1234
    Select Account Menu    Profile

    Customer Edit Name     Matcha    Bubble
    Customer Edit Phone    087563249

    Click Element    css=button[data-testid="logout-button"]
    Close All Browsers

    Open Customer Browser
    Customer Login    eatmatcha@example.com    1234
    Select Account Menu    Profile

    Customer Should See Profile Info
    ...    Matcha Bubble
    ...    eatmatcha@example.com
    ...    087563249

    Open Admin Browser
    Admin Login    ${ADMIN_USER}    ${ADMIN_PASS}
    Admin Open Customers Page
    Search Customer By Email    eatmatcha@example.com
    Open Customer From Search By Email    eatmatcha@example.com
    Verify Customer Detail    eatmatcha@example.com    Matcha Bubble    -    087563249
