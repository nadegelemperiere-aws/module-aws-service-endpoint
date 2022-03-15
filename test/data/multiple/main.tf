# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2022] Technogix SARL
# All rights reserved
# -------------------------------------------------------
# Simple deployment for module testing
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 12 november 2021
# -------------------------------------------------------


# -------------------------------------------------------
# Local test variables
# -------------------------------------------------------
locals {
	test_interfaces = [
		{ 	service 	= "cloudtrail", type = "interface", links = [
			{ service = "s3", port = "443", protocol = "TCP" , prefixes = [module.gateways[0].prefix]}
		]},
		{ 	service 	= "logs", type = "interface", links = [
			{ service = "s3", port = "443", protocol = "TCP", prefixes = [module.gateways[0].prefix] }
		]}
	]
	test_gateways = [
		{ 	service = "s3", type = "gateway", rights = [
			{ description = "AllowPutObject" , actions = [ "s3:PutObject"] , resources = [ "${aws_s3_bucket.access.arn}", "${aws_s3_bucket.access.arn}/*"], principal = { aws = ["arn:aws:iam::${var.account}:user/${var.service_principal}"] } }
		]}
	]
}

# -------------------------------------------------------
# Create a network
# -------------------------------------------------------
resource "aws_vpc" "test" {

	cidr_block  			= "10.2.0.0/24"
	enable_dns_support  	= true
	enable_dns_hostnames	= true
   	tags 					= { Name = "test.vpc" }

}

# -------------------------------------------------------
# Create the default network route table
# -------------------------------------------------------
resource "aws_default_route_table" "test" {
	default_route_table_id	= aws_vpc.test.default_route_table_id
	tags 		= { Name = "test.vpc.route" }
}

# -------------------------------------------------------
# Create the interface subnet
# -------------------------------------------------------
resource "aws_subnet" "test" {
	vpc_id 		= aws_vpc.test.id
	cidr_block  = "10.2.0.0/26"
   	tags 		= { Name = "test.vpc.interfaces" }
}

# -------------------------------------------------------
# Create an s3 bucket
# -------------------------------------------------------
resource "random_string" "random" {
	length		= 32
	special		= false
	upper 		= false
}
resource "aws_s3_bucket" "access" {
	bucket = random_string.random.result
}

# -------------------------------------------------------
# Create gateways using the current module
# -------------------------------------------------------
module "gateways" {

	count 		= length(local.test_gateways)

	source 		      = "../../../"
	region		      = "eu-west-1"
	email 		      = "moi.moi@moi.fr"
	project 	      = "test"
	environment       = "test"
	module 		      = "test"
	git_version       = "test"
	account		      = var.account
	service_principal = var.service_principal
	vpc 		      = {
		id 		= aws_vpc.test.id
		route 	= aws_default_route_table.test.id
	}
	service		      = local.test_gateways[count.index].service
	type 		      = local.test_gateways[count.index].type
	links 		      = []
	rights	          = local.test_gateways[count.index].rights
}

# -------------------------------------------------------
# Create subnets using the current module
# -------------------------------------------------------
module "interfaces" {

	count 		      = length(local.test_interfaces)

	source 		      = "../../../"
	region		      = "eu-west-1"
	email 		      = "moi.moi@moi.fr"
	project 	      = "test"
	environment       = "test"
	module 		      = "test"
	git_version       = "test"
	account		      = var.account
	service_principal = var.service_principal
	vpc 		      = {
		id 		= aws_vpc.test.id
		route 	= aws_default_route_table.test.id
	}
	subnets 	      = [aws_subnet.test.id]
	service		      = local.test_interfaces[count.index].service
	type 		      = local.test_interfaces[count.index].type
	links 		      = local.test_interfaces[count.index].links
}

# -------------------------------------------------------
# Terraform configuration
# -------------------------------------------------------
provider "aws" {
	region		= var.region
	access_key 	= var.access_key
	secret_key	= var.secret_key
}

terraform {
	required_version = ">=1.0.8"
	backend "local"	{
		path="terraform.tfstate"
	}
}

# -------------------------------------------------------
# Region for this deployment
# -------------------------------------------------------
variable "region" {
	type    = string
}
variable "account" {
	type    = string
}
variable "service_principal" {
	type    = string
}

# -------------------------------------------------------
# AWS credentials
# -------------------------------------------------------
variable "access_key" {
	type    	= string
	sensitive 	= true
}
variable "secret_key" {
	type    	= string
	sensitive 	= true
}

# -------------------------------------------------------
# Test outputs
# -------------------------------------------------------
output "gateways" {
	value = {
		id 		= module.gateways.*.id
		service = module.gateways.*.service
		arn 	= module.gateways.*.arn
		prefix 	= module.gateways.*.prefix
		cidr 	= module.gateways.*.cidr
		nsg 	= module.gateways.*.nsg
	}
}
output "interfaces" {
	value = {
		id 		= module.interfaces.*.id
		service = module.interfaces.*.service
		arn 	= module.interfaces.*.arn
		prefix 	= module.interfaces.*.prefix
		cidr 	= module.interfaces.*.cidr
		nsg 	= module.interfaces.*.nsg
	}
}

output "vpc" {
	value = aws_vpc.test.id
}
output "route" {
	value = aws_default_route_table.test.id
}
output "subnet" {
	value = aws_subnet.test.id
}