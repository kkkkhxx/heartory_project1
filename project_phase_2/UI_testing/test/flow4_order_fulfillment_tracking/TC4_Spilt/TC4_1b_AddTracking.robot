*** Settings ***
Resource          ../../../pages/admin/FulfillmentFlowsResource.robot
Suite Setup       Open Admin Browser
Suite Teardown    Close All Browsers

*** Test Cases ***
TC4_1B_Add_Tracking
    [Tags]    admin    fulfillment    partB
    Part2_Add_Tracking_To_Fulfilled_Order
