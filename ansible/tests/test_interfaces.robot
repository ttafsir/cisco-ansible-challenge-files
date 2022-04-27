*** Settings ***
Library        Collections
Library        pyats.robot.pyATSRobot
Library        genie.libs.robot.GenieRobot
Library	       OperatingSystem
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

Verify IP address configurations
    ${err_msg}=  Set Variable  "FAILURE: interfaces not configured properly"
    FOR  ${device}  ${data}    IN    &{devices}
        # Load device data from hostvars file
        ${device_hostvars_yaml}=  Get File  /workspace/ansible/testlab-${device}.yaml
        ${hostvars}=  yaml.Safe Load  ${device_hostvars_yaml}

        # parse show ip interface
        ${output}=  parse "show ip interface brief" on device "${device}"

        # test
        FOR  ${intf}  IN  ${hostvars}[l3_interfaces]
            ${name}=  Set Variable  ${intf}[name]
            ${ip_address}=  Set Variable  ${intf}[ipv4][address]
            Should Be Equal  ${csr1_interfaces}[interface][${name}][protocol]  up
            Should Be Equal  ${csr1_interfaces}[interface][${name}][ip_address]  ${ip_address}
        END
    END
    [Teardown]  Run Keyword If Test Failed  FAIL  msg=${err_msg}

