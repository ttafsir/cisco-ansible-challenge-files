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

Verify IP address configurations
    ${csr1_interfaces}=  parse "show ip interface brief" on device "csr1"
    ${csr2_interfaces}=  parse "show ip interface brief" on device "csr2"
    ${csr3_interfaces}=  parse "show ip interface brief" on device "csr3"

    # csr1
    Should Be Equal  ${csr1_interfaces}[interface][GigabitEthernet2][protocol]  up
    Should Be Equal  ${csr1_interfaces}[interface][GigabitEthernet2][ip_address]  192.168.12.1
    Should Be Equal  ${csr1_interfaces}[interface][Loopback0][ip_address]  1.1.1.1

    # csr2
    Should Be Equal  ${csr2_interfaces}[interface][GigabitEthernet2][protocol]  up
    Should Be Equal  ${csr2_interfaces}[interface][GigabitEthernet3][protocol]  up
    Should Be Equal  ${csr2_interfaces}[interface][GigabitEthernet2][ip_address]  192.168.12.2
    Should Be Equal  ${csr2_interfaces}[interface][GigabitEthernet3][ip_address]  192.168.23.2
    Should Be Equal  ${csr2_interfaces}[interface][Loopback0][ip_address]  2.2.2.2

    # csr3
    Should Be Equal  ${csr3_interfaces}[interface][GigabitEthernet2][protocol]  up
    Should Be Equal  ${csr3_interfaces}[interface][GigabitEthernet2][ip_address]  192.168.23.3
    Should Be Equal  ${csr3_interfaces}[interface][Loopback0][ip_address]  3.3.3.3
