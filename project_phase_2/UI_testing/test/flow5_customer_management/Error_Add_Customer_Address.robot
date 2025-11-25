#=====================================================================#
#                      Error_Add_Customer_Address                     #
#=====================================================================#

*** Settings ***
Library           SeleniumLibrary    timeout=10s    implicit_wait=0.3
Resource          Happy_Edit_Customer_Profile.robot
Resource          Happy_Add_Customer_Address.robot
Suite Setup       Open Admin Browser


*** Variables ***
# error message ใต้ Address name
${ADDR_NAME_ERROR}       xpath=${ADDR_DIALOG}//label[normalize-space(.)='Address name']
...    /ancestor::div[contains(@class,'grid-cols-2')][1]
...    /descendant::span[contains(@class,'text-ui-fg-error')]


*** Keywords ***
Admin Should See Address Name Required Error
    [Documentation]    ไม่กรอก Address name แล้วกด Save → ต้องเห็น error
    ${name_error}=    Set Variable    xpath=${ADDR_DIALOG}//span[contains(@class,'text-ui-fg-error')]
    Wait Until Element Is Visible    ${name_error}    10s
    Element Should contain    ${name_error}    String must contain at least 1 character
