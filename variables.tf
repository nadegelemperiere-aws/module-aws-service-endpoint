# -------------------------------------------------------
# Copyright (c) [2022] Nadege Lemperiere
# All rights reserved
# -------------------------------------------------------
# Module to deploy an aws service endpoint in a VPC with
# all the secure components required
# -------------------------------------------------------
# Nadège LEMPERIERE, @12 november 2021
# Latest revision: 01 december 2023
# -------------------------------------------------------

# -------------------------------------------------------
# Contact e-mail for this deployment
# -------------------------------------------------------
variable "email" {
	type 	 = string
	nullable = false
}

# -------------------------------------------------------
# Environment for this deployment (prod, preprod, ...)
# -------------------------------------------------------
variable "environment" {
	type 	 = string
	nullable = false
}
variable "region" {
	type 	 = string
	nullable = false
}

# -------------------------------------------------------
# Topic context for this deployment
# -------------------------------------------------------
variable "project" {
	type     = string
	nullable = false
}
variable "module" {
	type 	 = string
	nullable = false
}

# -------------------------------------------------------
# Solution version
# -------------------------------------------------------
variable "git_version" {
	type     = string
	default  = "unmanaged"
	nullable = false
}

# -------------------------------------------------------
# Endpoint type (gateway or interface)
# -------------------------------------------------------
variable "type" {
	type     = string
	nullable = false
}
variable "service" {
	type     = string
	nullable = false
}

# --------------------------------------------------------
# Endpoint network (subnet only for gateways, so get crapy
# default values that should never be used)
# --------------------------------------------------------
variable "vpc" {
	type = object({
		id    = string
		route = string
	})
	nullable = false
}

variable "subnets" {
	type     = list(string)
	default  = []
	nullable = false
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
	default  = []
	nullable = false
}

# --------------------------------------------------------
# Endpoint access rights + Service principal and account
# to ensure root and service principal can access
# --------------------------------------------------------
variable "rights" {
	type = list(object({
		description = string,
		actions 	= list(string)
		principal 	= object({
			aws 		= optional(list(string))
		})
		resources   = list(string)
		condition   = optional(string)
	}))
	default  = []
	nullable = false
}
variable "service_principal" {
	type     = string
	nullable = false
}
variable "account" {
	type     = string
	nullable = false
}