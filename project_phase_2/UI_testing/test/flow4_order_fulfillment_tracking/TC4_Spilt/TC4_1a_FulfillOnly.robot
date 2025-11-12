*** Settings ***
Resource          ../../../pages/admin/FulfillmentFlowsResource.robot
Suite Setup       Open Admin Browser
Suite Teardown    Close All Browsers

*** Test Cases ***
TC4_1A_Fulfill_Only
    [Tags]    admin    fulfillment    partA
    Part1_Fulfill_Order
