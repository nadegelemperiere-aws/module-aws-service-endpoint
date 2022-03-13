# -------------------------------------------------------
# TECHNOGIX
# -------------------------------------------------------
# Copyright (c) [2021] Technogix.io
# All rights reserved
# -------------------------------------------------------
# Simple deployment for module testing
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 12 november 2021
# -------------------------------------------------------

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
# Create the interface subnets
# -------------------------------------------------------
resource "aws_subnet" "test1" {
	vpc_id 		        = aws_vpc.test.id
	cidr_block          = "10.2.0.0/26"
    availability_zone   = "eu-west-1a"
   	tags 		        = { Name = "test.vpc.interfaces" }
}
resource "aws_subnet" "test2" {
	vpc_id 		        = aws_vpc.test.id
	cidr_block          = "10.2.0.64/26"
    availability_zone   = "eu-west-1b"
   	tags 		        = { Name = "test.vpc.interfaces" }
}

# -------------------------------------------------------
# Create subnets using the current module
# -------------------------------------------------------
module "interface" {

	source 		= "../../../"
	region		= "eu-west-1"
	email 		= "moi.moi@moi.fr"
	project 	= "test"
	environment = "test"
	module 		= "test"
	git_version = "test"
	vpc 		= {
		id 		= aws_vpc.test.id
		route 	= aws_default_route_table.test.id
	}
	subnets     = [aws_subnet.test1.id, aws_subnet.test2.id]
	service		= "cloudtrail"
	type 		= "interface"
	links 		= []
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

output "interface" {
	value = module.interface
}

output "vpc" {
	value = aws_vpc.test.id
}
output "route" {
	value = aws_default_route_table.test.id
}
output "subnets" {
	value = [aws_subnet.test1.id,aws_subnet.test2.id]
}