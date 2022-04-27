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
        ${device_hostvars_yaml}=  Get File  /workspace/ansible/host_vars/testlab-${device}.yml
        ${hostvars}=  yaml.Safe Load  ${device_hostvars_yaml}

        # parse show ip interface
        ${output}=  parse "show ip interface brief" on device "${device}"

        # test
        FOR  ${intf}  IN  ${hostvars}[l3_interfaces]
            Log To Console  ${intf}
            ${name}=  Set Variable  ${intf}[name]
            ${ip_address}=  Set Variable  ${intf}[ipv4][0][address]
            Should Be Equal  ${csr1_interfaces}[interface][${name}][protocol]  up
            Should Be Equal  ${csr1_interfaces}[interface][${name}][ip_address]  ${ip_address}
        END
    END
    [Teardown]  Run Keyword If Test Failed  FAIL  msg=${err_msg}

#Verify IP address configurations
#    ${csr1_interfaces}=  parse "show ip interface brief" on device "csr1"
#    ${csr2_interfaces}=  parse "show ip interface brief" on device "csr2"
#    ${csr3_interfaces}=  parse "show ip interface brief" on device "csr3"
#
#    # csr1
#    ${output}=  Should Be Equal  ${csr1_interfaces}[interface][GigabitEthernet2][protocol]  up
#    ${output}=  Should Be Equal  ${csr1_interfaces}[interface][GigabitEthernet2][ip_address]  192.168.12.1
#    ${output}=  Should Be Equal  ${csr1_interfaces}[interface][Loopback0][ip_address]  1.1.1.1
#
#    # csr2
#    ${output}=  Should Be Equal  ${csr2_interfaces}[interface][GigabitEthernet2][protocol]  up
#    ${output}=  Should Be Equal  ${csr2_interfaces}[interface][GigabitEthernet3][protocol]  up
#    ${output}=  Should Be Equal  ${csr2_interfaces}[interface][GigabitEthernet2][ip_address]  192.168.12.2
#    ${output}=  Should Be Equal  ${csr2_interfaces}[interface][GigabitEthernet3][ip_address]  192.168.23.2
#    ${output}=  Should Be Equal  ${csr2_interfaces}[interface][Loopback0][ip_address]  2.2.2.2
#
#    # csr3
#    ${output}=  Should Be Equal  ${csr3_interfaces}[interface][GigabitEthernet2][protocol]  up
#    ${output}=  Should Be Equal  ${csr3_interfaces}[interface][GigabitEthernet2][ip_address]  192.168.23.3
#    ${output}=  Should Be Equal  ${csr3_interfaces}[interface][Loopback0][ip_address]  3.3.3.3
#
#    ${err_msg}=  Set Variable  "FAILURE: device interfaces do not seem to be configured properly. ${output}"    
#    [Teardown]  Run Keyword If Test Failed  FAIL  msg=${err_msg} 
