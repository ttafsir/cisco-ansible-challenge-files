*** Keywords ***

Verify descriptions match
    [Arguments]     ${device}   ${cli_output}  ${interfaces}
    FOR  ${intf}  IN  @{interfaces}
        ${name}=  Set Variable   ${intf}[name]
        ${description}=  Evaluate  "${intf}[description]"
        TRY
            Should Be Equal  ${cli_output}[interfaces][${name}][description]  ${description}
        EXCEPT    AS    ${error_message}
            FAIL    msg="FAILURE: ${error_message}. Please check the configuration of ${name} on ${device}."
        END
    END