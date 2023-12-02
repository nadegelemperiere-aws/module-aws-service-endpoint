# -------------------------------------------------------
# Copyright (c) [2022] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Robotframework test suite for module
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 01 december 2023
# -------------------------------------------------------


*** Settings ***
Documentation   A test case to check service endpoints creation using module
Library         aws_iac_keywords.terraform
Library         aws_iac_keywords.keepass
Library         aws_iac_keywords.ec2
Library         ../keywords/data.py
Library         OperatingSystem

*** Variables ***
${KEEPASS_DATABASE}                 ${vault_database}
${KEEPASS_KEY_ENV}                  ${vault_key_env}
${KEEPASS_PRINCIPAL_KEY_ENTRY}      /aws/aws-principal-access-key
${KEEPASS_ACCOUNT_ENTRY}            /aws/aws-account
${KEEPASS_PRINCIPAL_USERNAME}       /aws/aws-principal-credentials
${REGION}                           eu-west-1

*** Test Cases ***
Prepare environment
    [Documentation]         Retrieve principal credential from database and initialize python tests keywords
    ${keepass_key}          Get Environment Variable          ${KEEPASS_KEY_ENV}
    ${principal_access}     Load Keepass Database Secret      ${KEEPASS_DATABASE}     ${keepass_key}  ${KEEPASS_PRINCIPAL_KEY_ENTRY}   username
    ${principal_secret}     Load Keepass Database Secret      ${KEEPASS_DATABASE}     ${keepass_key}  ${KEEPASS_PRINCIPAL_KEY_ENTRY}   password
    ${principal_name}       Load Keepass Database Secret      ${KEEPASS_DATABASE}     ${keepass_key}  ${KEEPASS_PRINCIPAL_USERNAME}    username
    ${account}              Load Keepass Database Secret      ${KEEPASS_DATABASE}     ${keepass_key}  ${KEEPASS_ACCOUNT_ENTRY}         password
    Initialize Terraform    ${REGION}   ${principal_access}   ${principal_secret}
    Initialize EC2          None        ${principal_access}   ${principal_secret}    ${REGION}
    ${TF_PARAMETERS}=       Create Dictionary   account=${account}    service_principal=${principal_name}
    Set Global Variable     ${TF_PARAMETERS}

Create Multiple Endpoints
    [Documentation]         Create Endpoints And Check That The AWS Infrastructure Match Specifications
    Launch Terraform Deployment                 ${CURDIR}/../data/multiple  ${TF_PARAMETERS}
    ${states}   Load Terraform States           ${CURDIR}/../data/multiple
    ${specs}    Load Multiple Test Data         ${states['test']['outputs']['vpc']['value']}     ${states['test']['outputs']['route']['value']}   ${states['test']['outputs']['subnet']['value']}  ${states['test']['outputs']['gateways']['value']}    ${states['test']['outputs']['interfaces']['value']}
    Endpoints Shall Exist And Match             ${specs['endpoints']}
    Security Group Shall Exist And Match        ${specs['security_groups']}
    [Teardown]  Destroy Terraform Deployment    ${CURDIR}/../data/multiple  ${TF_PARAMETERS}

Create Multiple Subnets Endpoint
    [Documentation]         Create Interface In Multiple Subnets And Check That The AWS Infrastructure Match Specifications
    Launch Terraform Deployment                 ${CURDIR}/../data/subnets  ${TF_PARAMETERS}
    ${states}   Load Terraform States           ${CURDIR}/../data/subnets
    ${specs}    Load Subnets Test Data          ${states['test']['outputs']['vpc']['value']}     ${states['test']['outputs']['route']['value']}   ${states['test']['outputs']['subnets']['value']}  ${states['test']['outputs']['interface']['value']}
    Endpoints Shall Exist And Match             ${specs['endpoints']}
    Security Group Shall Exist And Match        ${specs['security_groups']}
    [Teardown]  Destroy Terraform Deployment    ${CURDIR}/../data/subnets  ${TF_PARAMETERS}
