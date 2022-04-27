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
        # Load device data from hostvars file
        ${device_hostvars_yaml}=  Get File  ../host_vars/testlab-${device}.yml
        ${hostvars}=  yaml.Safe Load  ${device_hostvars_yaml}

        # parse show ip interface
        ${output}=  parse "show ip interface brief" on device "${device}"

        FOR  ${intf}  IN  @{hostvars}[l3_interfaces]
            ${name}=  Set Variable   ${intf}[name]
            ${ip_address}=  Evaluate  "${intf}[ipv4][0][address]".split("/")[0]
            Log To Console  ${device} - expected: ${name}:${ip_address} found: ${name}:${output}[interface][${name}][ip_address] 
            TRY   
                Should Be Equal  ${output}[interface][${name}][protocol]  up
                Should Be Equal  ${output}[interface][${name}][ip_address]  ${ip_address}
            EXCEPT    AS    ${error_message}
                FAIL    msg="FAILURE: interfaces not configured properly ${error_message}"
            END
        END
    END