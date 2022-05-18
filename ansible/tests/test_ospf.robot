*** Settings ***
Library        Collections
Library        pyats.robot.pyATSRobot
Library        genie.libs.robot.GenieRobot
Library	       OperatingSystem
Library        yaml
Variables      ${EXECDIR}/testbed.yaml 

*** Variables ***
${testbed_file}      testbed.yaml

*** Test Cases ***

Initialize
    Log To Console  using tested ${testbed_file}

    # select the testbed to use
    use testbed "${testbed_file}"

Connect To Devices
    connect to all devices

OSPF ansible playbook should exist
    ${err_msg}=  Set Variable  "FAILURE: configure-ospf.yml does not seem to be created"
    File Should Exist    /workspace/ansible/configure-ospf.yml 
    [Teardown]  Run Keyword If Test Failed  FAIL  msg=${err_msg} 

OSPF 100 should be configured on all devices with proper router-id
    FOR  ${device}  ${data}    IN    &{devices}
        ${err_msg}=  Set Variable  "FAILURE: OSPF 100 is not configured properly on ${device}"
        Log To Console  ${device}

        ${device_hostvars_yaml}=  Get File  ../host_vars/testlab-${device}.yml
        ${hostvars}=  yaml.Safe Load  ${device_hostvars_yaml}

        ${output}=  parse "show ip ospf" on device "${device}"
        Should Contain  ${output}[vrf][default][address_family][ipv4][instance]     100    msg=${err_msg}
        Should Contain  ${output}[vrf][default][address_family][ipv4][instance][100][router_id]         ${hostvars}[routing][ospf][processes][0][router_id]     msg=${err_msg}
    END
    [Teardown]  Run Keyword If Test Failed  FAIL  msg=${err_msg}

OSPF 100 neighbors should match expected neighbors
    ${err_msg}=  Set Variable  "FAILURE: OSPF 100 process or neighbors are not configured properly"
    ${csr1_ospf_output}=  parse "show ip ospf neighbor" on device "csr1"
    ${csr2_ospf_output}=  parse "show ip ospf neighbor" on device "csr2"
    ${csr3_ospf_output}=  parse "show ip ospf neighbor" on device "csr3"

    ${csr1_g2_neigh}=  Get Dictionary Values  ${csr1_ospf_output}[interfaces][GigabitEthernet2][neighbors]
    ${csr2_g2_neigh}=  Get Dictionary Values  ${csr2_ospf_output}[interfaces][GigabitEthernet2][neighbors]
    ${csr2_g3_neigh}=  Get Dictionary Values  ${csr2_ospf_output}[interfaces][GigabitEthernet3][neighbors]
    ${csr3_g2_neigh}=  Get Dictionary Values  ${csr3_ospf_output}[interfaces][GigabitEthernet2][neighbors]

    Should Be Equal  ${csr1_g2_neigh}[0][address]  192.168.12.2
    Should Be Equal  ${csr2_g2_neigh}[0][address]  192.168.12.1
    Should Be Equal  ${csr2_g3_neigh}[0][address]  192.168.23.3
    Should Be Equal  ${csr3_g2_neigh}[0][address]  192.168.23.2
    [Teardown]  Run Keyword If Test Failed  FAIL  msg=${err_msg}