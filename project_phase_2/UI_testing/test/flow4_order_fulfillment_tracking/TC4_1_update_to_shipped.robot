*** Settings ***
Resource          ../../pages/admin/FulfillmentFlowsResource.robot
Suite Setup       Open Admin Browser
Suite Teardown    Close All Browsers

*** Test Cases ***
TC4_1_Update_To_Shipped
    [Tags]    admin    fulfillment    combined
    # รวมสองส่วน: เปลี่ยนสถานะ -> ใส่เลข tracking
    Part1_Fulfill_Order
    Part2_Add_Tracking_To_Fulfilled_Order
