# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2022] Technogix SARL
# All rights reserved
# -------------------------------------------------------
# Keywords to create data for module test
# -------------------------------------------------------
# Nadège LEMPERIERE, @13 november 2021
# Latest revision: 13 november 2021
# -------------------------------------------------------

# System includes
from json import load, dumps

# Robotframework includes
from robot.libraries.BuiltIn import BuiltIn, _Misc
from robot.api import logger as logger
from robot.api.deco import keyword
ROBOT = False

# ip address manipulation
from ipaddress import IPv4Network

@keyword('Load Multiple Test Data')
def load_multiple_test_data(vpc, route, subnet, gateways, interfaces) :

    result = {}
    result['endpoints'] = []
    result['security_groups'] = []

    s3_prefix = "s3"

    for index in range(len(gateways['id'])) :
        endpoint = {}
        endpoint['name'] = gateways['service'][index]
        endpoint['data'] = {}
        endpoint['data']['VpcEndpointId'] = gateways['id'][index]
        endpoint['data']['VpcEndpointType'] = 'Gateway'
        endpoint['data']['VpcId'] = vpc
        endpoint['data']['ServiceName'] = 'com.amazonaws.eu-west-1.' + gateways['service'][index]
        endpoint['data']['State'] = 'available'
        endpoint['data']['RouteTableIds'] = [route]
        endpoint['data']['SubnetIds'] = []
        endpoint['data']['PrivateDnsEnabled'] = False
        endpoint['data']['Tags'] = []
        endpoint['data']['Tags'].append({'Key'          : 'Version'     , 'Value' : 'test'})
        endpoint['data']['Tags'].append({'Key'          : 'Project'     , 'Value' : 'test'})
        endpoint['data']['Tags'].append({'Key'          : 'Module'      , 'Value' : 'test'})
        endpoint['data']['Tags'].append({'Key'          : 'Environment' , 'Value' : 'test'})
        endpoint['data']['Tags'].append({'Key'          : 'Owner'       , 'Value' : 'moi.moi@moi.fr'})
        endpoint['data']['Tags'].append({'Key'          : 'Name'        , 'Value' : 'test.test.test.vpc.gateway.' + gateways['service'][index]})

        if gateways['service'][index] == 's3' : s3_prefix = gateways['prefix'][index]

        result['endpoints'].append(endpoint)

    for index in range(len(interfaces['id'])) :
        endpoint = {}
        endpoint['name'] = interfaces['service'][index]
        endpoint['data'] = {}
        endpoint['data']['VpcEndpointId'] = interfaces['id'][index]
        endpoint['data']['VpcEndpointType'] = 'Interface'
        endpoint['data']['VpcId'] = vpc
        endpoint['data']['ServiceName'] = 'com.amazonaws.eu-west-1.' + interfaces['service'][index]
        endpoint['data']['State'] = 'available'
        endpoint['data']['Groups'] = []
        endpoint['data']['Groups'].append({"GroupId": interfaces['nsg'][index], "GroupName": 'test-vpc-interface-'+ interfaces['service'][index]})
        endpoint['data']['SubnetIds'] = [subnet]
        endpoint['data']['PrivateDnsEnabled'] = True
        endpoint['data']['Tags'] = []
        endpoint['data']['Tags'].append({'Key'          : 'Version'     , 'Value' : 'test'})
        endpoint['data']['Tags'].append({'Key'          : 'Project'     , 'Value' : 'test'})
        endpoint['data']['Tags'].append({'Key'          : 'Module'      , 'Value' : 'test'})
        endpoint['data']['Tags'].append({'Key'          : 'Environment' , 'Value' : 'test'})
        endpoint['data']['Tags'].append({'Key'          : 'Owner'       , 'Value' : 'moi.moi@moi.fr'})
        endpoint['data']['Tags'].append({'Key'          : 'Name'        , 'Value' : 'test.test.test.vpc.interface.' + interfaces['service'][index]})

        result['endpoints'].append(endpoint)

        group = {}
        group['name'] = interfaces['service'][index]
        group['data'] = {}
        group['data']['GroupName'] = 'test-vpc-interface-'+ interfaces['service'][index]
        group['data']['IpPermissions'] = []
        group['data']['GroupId'] = interfaces['nsg'][index]
        group['data']['IpPermissionsEgress'] = []
        group['data']['IpPermissionsEgress'].append({"FromPort": 443, "IpProtocol": "tcp", "IpRanges": [], "Ipv6Ranges": [], "PrefixListIds": [{"Description": "Allow443AccessTos3", "PrefixListId": s3_prefix}], "ToPort": 443, "UserIdGroupPairs": []})
        group['data']['VpcId'] = vpc
        group['data']['Tags'] = []
        group['data']['Tags'].append({'Key'          : 'Version'     , 'Value' : 'test'})
        group['data']['Tags'].append({'Key'          : 'Project'     , 'Value' : 'test'})
        group['data']['Tags'].append({'Key'          : 'Module'      , 'Value' : 'test'})
        group['data']['Tags'].append({'Key'          : 'Environment' , 'Value' : 'test'})
        group['data']['Tags'].append({'Key'          : 'Owner'       , 'Value' : 'moi.moi@moi.fr'})
        group['data']['Tags'].append({'Key'          : 'Name'        , 'Value' : 'test.test.test.vpc.interface.' + interfaces['service'][index] + '.nsg'})

        result['security_groups'].append(group)

        logger.debug(dumps(result))

    return result


@keyword('Load Subnets Test Data')
def load_subnets_test_data(vpc, route, subnets, interface) :

    result = {}
    result['endpoints'] = []
    result['security_groups'] = []

    s3_prefix = ""

    endpoint = {}
    endpoint['name'] = interface['service']
    endpoint['data'] = {}
    endpoint['data']['VpcEndpointId'] = interface['id']
    endpoint['data']['VpcEndpointType'] = 'Interface'
    endpoint['data']['VpcId'] = vpc
    endpoint['data']['ServiceName'] = 'com.amazonaws.eu-west-1.' + interface['service']
    endpoint['data']['State'] = 'available'
    endpoint['data']['Groups'] = []
    endpoint['data']['Groups'].append({"GroupId": interface['nsg'], "GroupName": 'test-vpc-interface-'+ interface['service']})
    endpoint['data']['SubnetIds'] = [subnets[0], subnets[1]]
    endpoint['data']['PrivateDnsEnabled'] = True
    endpoint['data']['Tags'] = []
    endpoint['data']['Tags'].append({'Key'          : 'Version'     , 'Value' : 'test'})
    endpoint['data']['Tags'].append({'Key'          : 'Project'     , 'Value' : 'test'})
    endpoint['data']['Tags'].append({'Key'          : 'Module'      , 'Value' : 'test'})
    endpoint['data']['Tags'].append({'Key'          : 'Environment' , 'Value' : 'test'})
    endpoint['data']['Tags'].append({'Key'          : 'Owner'       , 'Value' : 'moi.moi@moi.fr'})
    endpoint['data']['Tags'].append({'Key'          : 'Name'        , 'Value' : 'test.test.test.vpc.interface.' + interface['service']})

    result['endpoints'].append(endpoint)

    group = {}
    group['name'] = interface['service']
    group['data'] = {}
    group['data']['GroupName'] = 'test-vpc-interface-'+ interface['service']
    group['data']['IpPermissions'] = []
    group['data']['GroupId'] = interface['nsg']
    group['data']['IpPermissionsEgress'] = []
    group['data']['VpcId'] = vpc
    group['data']['Tags'] = []
    group['data']['Tags'].append({'Key'          : 'Version'     , 'Value' : 'test'})
    group['data']['Tags'].append({'Key'          : 'Project'     , 'Value' : 'test'})
    group['data']['Tags'].append({'Key'          : 'Module'      , 'Value' : 'test'})
    group['data']['Tags'].append({'Key'          : 'Environment' , 'Value' : 'test'})
    group['data']['Tags'].append({'Key'          : 'Owner'       , 'Value' : 'moi.moi@moi.fr'})
    group['data']['Tags'].append({'Key'          : 'Name'        , 'Value' : 'test.test.test.vpc.interface.' + interface['service'] + '.nsg'})

    result['security_groups'].append(group)

    logger.debug(dumps(result))

    return result