*** Settings ***
Library        Collections
Library        pyats.robot.pyATSRobot
Library        genie.libs.robot.GenieRobot
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

OSPF 100 should be configured on all devices
    FOR    ${device}    IN    @{testbed["devices"]}
        ${output}=  parse "show ip ospf" on device "${device}"
        Should Contain  ${output}[vrf][default][address_family][ipv4][instance]  100    msg="FAILURE: OSPF 100 is not configured"
    END

OSPF 100 neighbors should match expected neighbors
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
