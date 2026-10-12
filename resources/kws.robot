*** Settings ***
Library     SeleniumLibrary    timeout=20s
Resource    variables.robot

*** Keywords ***
Start StoreMate Session
    Should Not Be Empty              ${EMAIL}                              msg=Set STOREMATE_EMAIL
    Should Not Be Empty              ${PASSWORD}                           msg=Set STOREMATE_PASSWORD
    Open Browser                     ${BASE_URL}/login                     ${BROWSER}
    Maximize Browser Window
    Wait Until Element Is Visible    css:[data-test="email"]               ${WAIT}
    Input Text                       css:[data-test="email"]               ${EMAIL}
    Input Password                   css:[data-test="password"]            ${PASSWORD}
    Click Element                    css:[data-test="btn-submit"]
    Wait Until Element Is Visible    css:[data-test="btn-user-profile"]    ${WAIT}

Stop StoreMate Session
    Close All Browsers

Open Orders Tab
    [Arguments]                     ${status}
    Go To                           ${BASE_URL}/orders?status=${status}
    Wait Until Location Contains    /orders                                ${WAIT}

Order Card
    [Arguments]                      ${order_no}
    ${locator}=                      Set Variable    css:[data-test="card-order-${order_no}"]
    Wait Until Element Is Visible    ${locator}      600s
    RETURN                           ${locator}

Open Cancellable Order
    [Arguments]    ${order_no}    ${status}=PENDING

    Open Orders Tab    ${status}

    ${card}=         Order Card    ${order_no}
    Click Element    ${card}

    ${cancel}=    Set Variable    css:[data-test="btn-cancel-order"]

    Wait Until Element Is Visible    ${cancel}    ${WAIT}

    # เลื่อนปุ่ม Cancel มาอยู่กลางหน้าจอ
    Execute JavaScript
    ...                   document.querySelector('[data-test="btn-cancel-order"]').scrollIntoView({block: 'center', behavior: 'instant'});

    Sleep    1s

    # คลิกปุ่ม Cancel
    Click Element    ${cancel}

    # รอให้ระบบเปลี่ยนหน้าหลังคลิก
    Sleep    2s

    # ตรวจสอบ URL จริง
    ${current_url}=    Get Location
    Log To Console     \nCurrent URL: ${current_url}

    # บันทึกภาพหน้าจอ
    Capture Page Screenshot

    # ตรวจสอบว่าเข้าสู่หน้าการยกเลิก
    Wait Until Location Contains    /cancel-orders/${order_no}    50s

Select Cancellation Reason
    Wait Until Element Is Visible    css:[data-test="dropdown-reason"]                        ${WAIT}
    Click Element                    css:[data-test="dropdown-reason"]
    Wait Until Element Is Visible    css:[data-test="reason-option-change_payment_method"]    ${WAIT}
    Click Element                    css:[data-test="reason-option-change_payment_method"]
    Element Should Contain           css:[data-test="dropdown-reason"]                        ${REASON}

Submit Cancellation
    Wait Until Element Is Visible    css:[data-test="btn-submit-cancel"]    ${WAIT}
    Click Element                    css:[data-test="btn-submit-cancel"]

Cancellation Success Should Be Visible
    Wait Until Page Contains    ${SUCCESS_MESSAGE}    ${WAIT}

Cancelled Order Should Be Listed
    [Arguments]               ${order_no}
    Open Orders Tab           CANCELLED
    ${card}=                  Order Card     ${order_no}
    Element Should Contain    ${card}        ${order_no}

Order Should Retain Status
    [Arguments]        ${order_no}    ${status}
    Open Orders Tab    ${status}
    Order Card         ${order_no}

Cancel Button Should Be Absent
    [Arguments]                      ${order_no}
    ${card}=                         Order Card                                                                 ${order_no}
    Element Should Not Be Visible    css:[data-test="card-order-${order_no}"] [data-test="btn-cancel-order"]
