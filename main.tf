# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2022] Technogix SARL
# All rights reserved
# -------------------------------------------------------
# Module to deploy an aws service endpoint in a VPC with
# all the secure components required
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 12 november 2021
# -------------------------------------------------------

# -------------------------------------------------------
# Create the endpoint
# -------------------------------------------------------
resource "aws_vpc_endpoint" "endpoint" {

	vpc_id      	 	= var.vpc.id
  	service_name 		= "com.amazonaws.${var.region}.${var.service}"
	vpc_endpoint_type 	= ("${var.type}" == "gateway") ? "Gateway" : "Interface"
	security_group_ids	= ("${var.type}" == "gateway") ? [] : [aws_security_group.interface[0].id]
	private_dns_enabled = ("${var.type}" == "gateway") ? false : true

	tags = {
		Name           	= "${var.project}.${var.environment}.${var.module}.vpc.${var.type}.${var.service}"
		Environment     = var.environment
		Owner   		= var.email
		Project   		= var.project
		Version 		= var.git_version
		Module  		= var.module
	}
}

# -------------------------------------------------------
# Set permission policy for endpoint access
# -------------------------------------------------------
locals {
	endpoint_statements = concat([
		for i,right in ((var.rights != null) ? var.rights : []) :
		{
			Sid 		= right.description
			Effect 		= "Allow"
			Principal 	= {
				"AWS" 		: ((right.principal.aws != null) ? right.principal.aws : [])
			}
			Action 		= right.actions
			Resource 	= right.resources
			Condition	= ((right.condition != null) ? jsondecode(right.condition) : null)
		}
	],
	[
		{
			Sid 		= "AllowRootAndServicePrincipal"
			Effect 		= "Allow"
			Principal 	= {
				"AWS" 		: ["arn:aws:iam::${var.account}:root", "arn:aws:iam::${var.account}:user/${var.service_principal}"]
			}
			Action 		= "*"
			Resource 	= "*"
		}
	])
}

# -------------------------------------------------------
# Associate endpoint to policy
# -------------------------------------------------------
resource "aws_vpc_endpoint_policy" "endpoint" {

	count 	= (("${var.type}" == "gateway") || ("${var.service}" == "s3") || ("${var.service}" == "dynamodb")) ? 1 : 0

  	vpc_endpoint_id = aws_vpc_endpoint.endpoint.id
  	policy = jsonencode({
    	Version = "2012-10-17"
		Statement = "${local.endpoint_statements}"
	})
}


# -------------------------------------------------------
# Associate gateway endpoint to route table
# -------------------------------------------------------
resource "aws_vpc_endpoint_route_table_association" "gateway" {

	count 			= ("${var.type}" == "gateway") ? 1 : 0
	route_table_id 	= var.vpc.route
	vpc_endpoint_id = aws_vpc_endpoint.endpoint.id
}

# -------------------------------------------------------
# Create a security group for each interface
# -------------------------------------------------------
resource "aws_security_group" "interface" {

  	count 		= ("${var.type}" == "interface") ? 1 : 0

	name        = "${var.project}-vpc-interface-${var.service}"
	description = "Security group for endpoint ${var.service}"
  	vpc_id      = var.vpc.id

  	dynamic "egress" {
		for_each = var.links
		content {
			description   	= "Allow${egress.value.port}AccessTo${egress.value.service}"
			from_port 		= egress.value.port
			to_port 		= egress.value.port
			protocol		= egress.value.protocol
			prefix_list_ids	= egress.value.prefixes
		}
	}

  	tags = {
		Name           	= "${var.project}.${var.environment}.${var.module}.vpc.${var.type}.${var.service}.nsg"
		Environment     = var.environment
		Owner   		= var.email
		Project   		= var.project
		Version 		= var.git_version
		Module  		= var.module
	}
}

# -------------------------------------------------------
# Associate interface to subnet
# -------------------------------------------------------
resource "aws_vpc_endpoint_subnet_association" "interface" {

	count 		= ("${var.type}" == "interface") ? length(var.subnets) : 0

	vpc_endpoint_id	= aws_vpc_endpoint.endpoint.id
  	subnet_id       = var.subnets[count.index]
}
