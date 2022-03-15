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

output "service" {
    value = var.service
}

output "id" {
    value = aws_vpc_endpoint.endpoint.id
}

output "arn" {
    value = aws_vpc_endpoint.endpoint.arn
}

output "prefix" {
    value = aws_vpc_endpoint.endpoint.prefix_list_id
}

output "cidr" {
    value = aws_vpc_endpoint.endpoint.cidr_blocks
}

output "nsg" {
    value = ("${var.type}" == "interface") ? aws_security_group.interface[0].id : ""
}