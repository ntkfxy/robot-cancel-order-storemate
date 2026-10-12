
*** Settings ***
Documentation    UC-22: 9 test cases mapped to SPRS-Test-Cases.docx (TC-22001 through TC-22009)
Resource         ../resources/kws.robot
Test Setup       Start StoreMate Session
Test Teardown    Stop StoreMate Session


*** Test Cases ***

TC-22001 Cancel Pending Payment Order
    [Documentation]                           Scenario 22.1: success message, cancelled status, reason, cancelled tab
    Open Cancellable Order                    ${ORDER_22001}                                                             PENDING
    Select Cancellation Reason
    Submit Cancellation
    Cancellation Success Should Be Visible
    Cancelled Order Should Be Listed          ${ORDER_22001}
    ${card}=                                  Order Card                                                                 ${ORDER_22001}
    Click Element                             ${card}
    Wait Until Page Contains                  ${REASON}                                                                  300s


TC-22002 Cancel COD Processing Order
    [Documentation]                           Scenario 22.2: expected success; source document recorded an error in actual result
    Open Cancellable Order                    ${ORDER_22002}                                                                         PROCESSING
    Select Cancellation Reason
    Submit Cancellation
    Cancellation Success Should Be Visible
    Cancelled Order Should Be Listed          ${ORDER_22002}
    ${card}=                                  Order Card                                                                             ${ORDER_22002}
    Click Element                             ${card}
    Wait Until Page Contains                  ${REASON}                                                                              ${WAIT}


TC-22003 Show Cancellation Success Message
    [Documentation]                           Scenario 22.1: assert the exact success notification
    Open Cancellable Order                    ${ORDER_22003}                                          PENDING
    Select Cancellation Reason
    Submit Cancellation
    Cancellation Success Should Be Visible


TC-22004 Show Stored Cancellation Reason
    [Documentation]             Scenario 22.1: already cancelled order displays selected reason
    Open Orders Tab             CANCELLED
    ${card}=                    Order Card                                                         ${ORDER_22004}
    Click Element               ${card}
    Wait Until Page Contains    ${REASON}                                                          ${WAIT}


TC-22005 Cancelled Order Moves To Cancelled Tab
    [Documentation]                     Scenario 22.1: order present in CANCELLED, absent from previous tab (PENDING)
    Cancelled Order Should Be Listed    ${ORDER_22005}
    Open Orders Tab                     PENDING
    Page Should Not Contain Element     css:[data-test="card-order-${ORDER_22005}"]


TC-22006 Cannot Cancel Order Without Selecting Reason
    [Documentation]    ตรวจสอบว่าไม่สามารถยกเลิกคำสั่งซื้อได้ หากไม่เลือกเหตุผลในการยกเลิก
    [Tags]             TC-22006                                                               UC-22    Negative

    ${ORDER_NO}=    Set Variable    ORD-20261012041940881-6454

    Go To    ${BASE_URL}/

    SeleniumLibrary.Wait Until Element Is Visible    css:[data-test="btn-user-profile"]    15s
    SeleniumLibrary.Click Element                    css:[data-test="btn-user-profile"]

    SeleniumLibrary.Wait Until Element Is Visible    css:[data-test="btn-orders"]    15s
    SeleniumLibrary.Click Element                    css:[data-test="btn-orders"]

    Wait Until Location Contains    /orders    15s

    ${pending_tab}=                                  Set Variable      xpath:(//div[normalize-space(.)="ที่ต้องชำระ"])[last()]
    SeleniumLibrary.Wait Until Element Is Visible    ${pending_tab}    15s
    SeleniumLibrary.Click Element                    ${pending_tab}

    Wait Until Location Contains    status=PENDING    15s

    ${order}=                                        Set Variable             css:[data-test="card-order-${ORDER_NO}"]
    SeleniumLibrary.Wait Until Element Is Visible    ${order}                 30s
    Log To Console                                   พบ Order: ${ORDER_NO}

    SeleniumLibrary.Click Element    ${order}

    ${order_card}=    Set Variable    xpath:(//*[starts-with(@data-test,"order-card-")][contains(.,"${ORDER_NO}")])[1]

    ${cancel_button}=                                Set Variable        ${order_card}//*[@data-test="btn-cancel-order"]
    SeleniumLibrary.Wait Until Element Is Visible    ${cancel_button}    15s

    Execute JavaScript               document.querySelector('[data-test="btn-cancel-order"]').scrollIntoView({block: 'center'});
    Sleep                            1s
    SeleniumLibrary.Click Element    ${cancel_button}

    Wait Until Location Contains    /cancel-orders/${ORDER_NO}    15s

    ${reason_dropdown}=                              Set Variable          css:[data-test="dropdown-reason"]
    SeleniumLibrary.Wait Until Element Is Visible    ${reason_dropdown}    15s

    ${submit_button}=                                Set Variable        css:[data-test="btn-submit-cancel"]
    SeleniumLibrary.Wait Until Element Is Visible    ${submit_button}    15s
    SeleniumLibrary.Click Element                    ${submit_button}

    Wait Until Page Contains        กรุณาเลือกเหตุผลในการยกเลิกคำสั่งซื้อ    15s
    Wait Until Location Contains    /cancel-orders/${ORDER_NO}               15s
    Page Should Not Contain         ส่งคำขอยกเลิกสำเร็จ

    Go To                           ${BASE_URL}/orders?status=PENDING
    Wait Until Location Contains    status=PENDING                       15s

    ${unchanged_order}=                              Set Variable          css:[data-test="card-order-${ORDER_NO}"]
    SeleniumLibrary.Wait Until Element Is Visible    ${unchanged_order}    30s

    Log To Console    TC-22006 PASS: Order ${ORDER_NO} ยังคงอยู่ในสถานะ PENDING


TC-22007 Cancel With Additional Details
    [Documentation]                           Scenario 22.4: confirm saved reason and description in cancelled order detail
    Open Cancellable Order                    ${ORDER_22007}                                                                      PENDING
    Select Cancellation Reason
    Wait Until Element Is Visible             css:[data-test="input-description"]                                                 ${WAIT}
    Input Text                                css:[data-test="input-description"]                                                 ${DESCRIPTION}
    Submit Cancellation
    Cancellation Success Should Be Visible
    Cancelled Order Should Be Listed          ${ORDER_22007}
    ${card}=                                  Order Card                                                                          ${ORDER_22007}
    Click Element                             ${card}
    Wait Until Page Contains                  ${REASON}                                                                           ${WAIT}
    Log                                       TODO: Assert saved description in order detail after verifying frontend locator.    WARN


TC-22008 Disallow Cancellation For Noncancellable Status
    [Documentation]                   Scenario 22.5: document specifies SHIPPING; verify test order status before running
    Open Orders Tab                   SHIPPING
    Cancel Button Should Be Absent    ${ORDER_22008}
    Order Should Retain Status        ${ORDER_22008}                                                                         SHIPPING


TC-22009 Leave Cancellation Without Confirmation
    [Documentation]    Scenario 22.6: Leave cancellation without submitting; order remains PENDING
    [Tags]             TC-22009                                                                       UC-22    Negative

    ${ORDER_NO}=    Set Variable    ORD-20261012041826716-6061

    Go To    ${BASE_URL}/

    SeleniumLibrary.Wait Until Element Is Visible    css:[data-test="btn-user-profile"]    15s
    SeleniumLibrary.Click Element                    css:[data-test="btn-user-profile"]

    SeleniumLibrary.Wait Until Element Is Visible    css:[data-test="btn-orders"]    15s
    SeleniumLibrary.Click Element                    css:[data-test="btn-orders"]

    Wait Until Location Contains    /orders    15s

    ${pending_tab}=                                  Set Variable      xpath:(//div[normalize-space(.)="ที่ต้องชำระ"])[last()]
    SeleniumLibrary.Wait Until Element Is Visible    ${pending_tab}    15s
    SeleniumLibrary.Click Element                    ${pending_tab}

    Wait Until Location Contains    status=PENDING    15s

    ${order}=                                        Set Variable             css:[data-test="card-order-${ORDER_NO}"]
    SeleniumLibrary.Wait Until Element Is Visible    ${order}                 30s
    Log To Console                                   พบ Order: ${ORDER_NO}
    SeleniumLibrary.Click Element                    ${order}

    ${order_card}=    Set Variable         xpath:(//*[starts-with(@data-test,"order-card-")][contains(.,"${ORDER_NO}")])[1]
    ${card_count}=    Get Element Count    ${order_card}

    IF                                               ${card_count} > 0
    ${cancel}=                                       Set Variable                                                                                   ${order_card}//*[@data-test="btn-cancel-order"]
    SeleniumLibrary.Wait Until Element Is Visible    ${cancel}                                                                                      15s
    Execute JavaScript                               document.querySelector('[data-test="btn-cancel-order"]').scrollIntoView({block: 'center'});
    Sleep                                            1s
    SeleniumLibrary.Click Element                    ${cancel}
    ELSE
    ${cancel}=                                       Set Variable                                                                                   css:[data-test="btn-cancel-order"]
    ${cancel_count}=                                 Get Element Count                                                                              ${cancel}
    IF                                               ${cancel_count} == 1
    SeleniumLibrary.Wait Until Element Is Visible    ${cancel}                                                                                      15s
    Execute JavaScript                               document.querySelector('[data-test="btn-cancel-order"]').scrollIntoView({block: 'center'});
    Sleep                                            1s
    SeleniumLibrary.Click Element                    ${cancel}
    ELSE
    Fail                                             ไม่สามารถระบุปุ่ม Cancel ของ Order ${ORDER_NO} ได้
    END
    END

    Wait Until Location Contains    /cancel-orders/${ORDER_NO}    15s

    SeleniumLibrary.Wait Until Element Is Visible    css:[data-test="btn-submit-cancel"]    15s

    Go Back
    Wait Until Location Does Not Contain    /cancel-orders/${ORDER_NO}           15s
    Log To Console                          ออกจากหน้าการยกเลิกโดยไม่กดยืนยัน

    Go To                           ${BASE_URL}/orders?status=PENDING
    Wait Until Location Contains    status=PENDING                       15s

    ${original_order}=                               Set Variable                                  css:[data-test="card-order-${ORDER_NO}"]
    SeleniumLibrary.Wait Until Element Is Visible    ${original_order}                             30s
    Log To Console                                   Order ${ORDER_NO} ยังคงอยู่ในสถานะ PENDING

    ${cancelled_tab}=                                Set Variable        xpath:(//div[normalize-space(.)="ยกเลิก"])[last()]
    SeleniumLibrary.Wait Until Element Is Visible    ${cancelled_tab}    15s
    SeleniumLibrary.Click Element                    ${cancelled_tab}

    Wait Until Location Contains    status=CANCELLED    15s

    ${cancelled_order}=                         Set Variable          css:[data-test="card-order-${ORDER_NO}"]
    Wait Until Page Does Not Contain Element    ${cancelled_order}    15s

    Log To Console    TC-22009 PASS: Order ${ORDER_NO} ไม่ถูกยกเลิก และยังคงสถานะเดิม
