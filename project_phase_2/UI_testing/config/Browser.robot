*** Settings ***
Library    SeleniumLibrary    timeout=${SEL_TIMEOUT}    implicit_wait=${IMPLICIT_WAIT}
Resource   Env.robot

*** Keywords ***
Open Admin Browser
    Open Browser    ${ADMIN_URL}    ${BROWSER}
    Maximize Browser Window

Open Customer Browser
    Open Browser    ${CUSTOMER_URL}    ${BROWSER}
    Maximize Browser Window

Switch To Admin
    Switch Browser    1

Switch To Customer
    Switch Browser    2

Close All
    Close All Browsers
