# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2021] Technogix.io
# All rights reserved
# -------------------------------------------------------
# Robotframework test suite for module
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 12 november 2021
# -------------------------------------------------------


*** Settings ***
Documentation   A test case to check service endpoints creation using module
Library         technogix_iac_keywords.terraform
Library         technogix_iac_keywords.keepass
Library         technogix_iac_keywords.ec2
Library         ../keywords/data.py

*** Variables ***
${KEEPASS_DATABASE}                 ${vault_database}
${KEEPASS_KEY}                      ${vault_key}
${KEEPASS_GOD_KEY_ENTRY}            /engineering-environment/aws/aws-god-access-key
${REGION}                           eu-west-1

*** Test Cases ***
Prepare environment
    [Documentation]         Retrieve god credential from database and initialize python tests keywords
    ${god_access}           Load Keepass Database Secret            ${KEEPASS_DATABASE}     ${KEEPASS_KEY}  ${KEEPASS_GOD_KEY_ENTRY}            username
    ${god_secret}           Load Keepass Database Secret            ${KEEPASS_DATABASE}     ${KEEPASS_KEY}  ${KEEPASS_GOD_KEY_ENTRY}            password
    Initialize Terraform    ${REGION}   ${god_access}   ${god_secret}
    Initialize EC2          None        ${god_access}   ${god_secret}    ${REGION}

Create Multiple Endpoints
    [Documentation]         Create Endpoints And Check That The AWS Infrastructure Match Specifications
    Launch Terraform Deployment                 ${CURDIR}/../data/multiple
    ${states}   Load Terraform States           ${CURDIR}/../data/multiple
    ${specs}    Load Multiple Test Data         ${states['test']['outputs']['vpc']['value']}     ${states['test']['outputs']['route']['value']}   ${states['test']['outputs']['subnet']['value']}  ${states['test']['outputs']['gateways']['value']}    ${states['test']['outputs']['interfaces']['value']}
    Endpoints Shall Exist And Match             ${specs['endpoints']}
    Security Group Shall Exist And Match        ${specs['security_groups']}
    [Teardown]  Destroy Terraform Deployment    ${CURDIR}/../data/multiple

Create Multiple Subnets Endpoint
    [Documentation]         Create Interface In Multiple Subnets And Check That The AWS Infrastructure Match Specifications
    Launch Terraform Deployment                 ${CURDIR}/../data/subnets
    ${states}   Load Terraform States           ${CURDIR}/../data/subnets
    ${specs}    Load Subnets Test Data          ${states['test']['outputs']['vpc']['value']}     ${states['test']['outputs']['route']['value']}   ${states['test']['outputs']['subnets']['value']}  ${states['test']['outputs']['interface']['value']}
    Endpoints Shall Exist And Match             ${specs['endpoints']}
    Security Group Shall Exist And Match        ${specs['security_groups']}
    [Teardown]  Destroy Terraform Deployment    ${CURDIR}/../data/subnets
