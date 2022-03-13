# -------------------------------------------------------
# TECHNOGIX 
# -------------------------------------------------------
# Copyright (c) [2021] Technogix.io
# All rights reserved 
# -------------------------------------------------------
# Module to deploy an aws service endpoint in a VPC with 
# all the secure components required
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 12 november 2021
# -------------------------------------------------------

# -------------------------------------------------------
# Contact e-mail for this deployment
# -------------------------------------------------------
variable "email" {
	type 	= string
}

# -------------------------------------------------------
# Environment for this deployment (prod, preprod, ...)
# -------------------------------------------------------
variable "environment" {
	type 	= string
}
variable "region" {
	type 	= string
}

# -------------------------------------------------------
# Topic context for this deployment
# -------------------------------------------------------
variable "project" {
	type    = string
}
variable "module" {
	type 	= string
}

# -------------------------------------------------------
# Solution version
# -------------------------------------------------------
variable "git_version" {
	type    = string
	default = "unmanaged"
}

# -------------------------------------------------------
# Endpoint type (gateway or interface)
# -------------------------------------------------------
variable "type" {
	type = string
}
variable "service" {
	type = string
}

# --------------------------------------------------------
# Endpoint network (subnet only for gateways, so get crapy 
# default values that should never be used)
# --------------------------------------------------------
variable "vpc" {
	type = object({
		id = string
		route = string
	})
}

variable "subnets" {
	type = list(string)
	default = [] 
}

# --------------------------------------------------------
# Rules to let access to interface endpoint
# --------------------------------------------------------
variable "links" {
	type = list(object({
		service 	= string
		protocol	= string
		port 		= string
		prefixes	= list(string)
	}))
	default = []
}