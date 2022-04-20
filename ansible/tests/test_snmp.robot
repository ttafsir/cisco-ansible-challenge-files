*** Settings ***
Library        Collections
Library        pyats.robot.pyATSRobot
Library        genie.libs.robot.GenieRobot

*** Variables ***
${testbed}      testbed.yaml

*** Test Cases ***

Initialize
    Log To Console  using tested ${testbed}

    # select the testbed to use
    use testbed "${testbed}"

Connect To Devices
    connect to all devices

The `configure-snmp.yml` playbook should exist

A `rw` community string should be configured on each device
    ${csr1_ospf}=  parse "show ip ospf" on device "csr1"
    ${csr2_ospf}=  parse "show ip ospf" on device "csr2"
    ${csr3_ospf}=  parse "show ip ospf" on device "csr3"

    Should Contain  ${csr1_ospf}[vrf][default][address_family][ipv4][instance]  100
    Should Contain  ${csr1_ospf}[vrf][default][address_family][ipv4][instance]  100
    Should Contain  ${csr1_ospf}[vrf][default][address_family][ipv4][instance]  100

An SNMP contact should be set using the the values from the `host_vars`
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

The snmp hosts should be configured as documented

The snmp traps should be configured as documented
