*** Settings ***
Library        Collections
Library        pyats.robot.pyATSRobot
Library        genie.libs.robot.GenieRobot
Library	       OperatingSystem
Library        yaml
Library        BuiltIn
Resource       challenge.resource
Resource       descriptions.resource
Variables      ${EXECDIR}/testbed.yaml 

*** Variables ***
${testbed}      testbed.yaml

*** Test Cases ***

Initialize
    Log To Console  using tested ${testbed}
    use testbed "${testbed}"     # select the testbed file to use

Connect To Devices
    connect to all devices

Interfaces ansible playbook should exist
    ${err_msg}=  Set Variable  "FAILURE: configure-interfaces.yml does not seem to be created"
    File Should Exist    /workspace/ansible/configure-interfaces.yml 
    [Teardown]  Run Keyword If Test Failed  FAIL  msg=${err_msg} 

Loop over devices and verify IP address configurations and descriptions match
    FOR  ${device}  ${data}    IN    &{devices}

        ${device_hostvars_yaml}=  Get File  ../host_vars/testlab-${device}.yml
        ${hostvars}=  yaml.Safe Load  ${device_hostvars_yaml}

        ${output}=  parse "show ip interface brief" on device "${device}"
        Verify interfaces are up with correct IP address    ${device}   ${output}   ${hostvars}[l3_interfaces]

        ${descriptionout}=  parse "show interfaces description" on device "${device}"
        Verify descriptions match    ${device}  ${descriptionout}   ${hostvars}[interfaces]
    END