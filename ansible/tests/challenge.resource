*** Keywords ***

Verify interfaces are up with correct IP address
    [Arguments]     ${device}   ${cli_output}  ${interfaces}
    FOR  ${intf}  IN  @{interfaces}
        ${name}=  Set Variable   ${intf}[name]
        ${ip_address}=  Evaluate  "${intf}[ipv4][0][address]".split("/")[0]
        TRY
            Should Be Equal  ${cli_output}[interface][${name}][protocol]  up
            Should Be Equal  ${cli_output}[interface][${name}][ip_address]  ${ip_address}
        EXCEPT    AS    ${error_message}
            FAIL    msg="FAILURE: ${error_message}. Please configure or create your interface on ${device}."
        END
    END