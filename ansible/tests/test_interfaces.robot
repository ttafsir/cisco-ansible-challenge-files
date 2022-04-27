*** Settings ***
Library        Collections
Library        pyats.robot.pyATSRobot
Library        genie.libs.robot.GenieRobot
Library	       OperatingSystem
Library        yaml
Variables      ${EXECDIR}/testbed.yaml 

*** Variables ***
${testbed}      testbed.yaml

*** Test Cases ***

Initialize
    Log To Console  using tested ${testbed}

    # select the testbed to use
    use testbed "${testbed}"

Connect To Devices
    connect to all devices

Interfaces ansible playbook should exist
    ${err_msg}=  Set Variable  "FAILURE: configure-interfaces.yml does not seem to be created"
    File Should Exist    /workspace/ansible/configure-interfaces.yml 
    [Teardown]  Run Keyword If Test Failed  FAIL  msg=${err_msg} 

Loop over devices and verify IP address configurations
    FOR  ${device}  ${data}    IN    &{devices}

        ${device_hostvars_yaml}=  Get File  ../host_vars/testlab-${device}.yml
        ${hostvars}=  yaml.Safe Load  ${device_hostvars_yaml}

        ${output}=  parse "show ip interface brief" on device "${device}"
        Verify interfaces are up with correct IP address    ${output}   ${hostvars}[l3_interfaces]
    END

Verify interfaces are up with correct IP address
    [arguments]     ${cli_output}  ${interfaces}
    FOR  ${intf}  IN  ${interfaces}
        ${name}=  Set Variable   ${intf}[name]
        ${ip_address}=  Evaluate  "${intf}[ipv4][0][address]".split("/")[0]
        TRY   
            Should Be Equal  ${cli_output}[interface][${name}][protocol]  up
            Should Be Equal  ${output}[interface][${name}][ip_address]  ${ip_address}
        EXCEPT    AS    ${error_message}
            FAIL    msg="FAILURE: interfaces. ${error_message}"
        END
    END