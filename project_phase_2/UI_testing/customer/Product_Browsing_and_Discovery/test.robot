*** Settings ***
Library    SeleniumLibrary
Suite Teardown    Close Browser

*** Variables ***
${browser}      Chrome
${url_google}   http://www.google.com
${text}         xpath=//*[@id="lst-ib"]
${search_button}  css=input.lsb

***Test Cases ***
Test opening google.com using Chrome
    Open Browser    ${url_google}    ${browser}

Get the page title and compare
    ${title}=  Get Title
    Should Be Equal As Strings  ${title}  Google

Search using the keyword "Cheese"
    Input Text      q    Cheese
    Submit Form
    ${title}=  Get Title
    Should Contain  ${title}  Cheese
