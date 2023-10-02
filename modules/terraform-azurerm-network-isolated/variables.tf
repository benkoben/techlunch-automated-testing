variable "location" {
  type        = string
  description = "Name of the Azure region to use."
  default     = "westeurope"
}

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group to create."
}

variable "tags" {
  type        = map(string)
  description = "A map of tags which will be added to the resource group and its resources."
  default     = {}
}

variable "virtual_network_name" {
  type        = string
  description = "Name of the created virtual network."
}

variable "virtual_network_address_space" {
  type        = set(string)
  description = "Address space used for the virtual network."
}

variable "nat_gateway_name" {
  type        = string
  description = "Name of the created NAT-gateway."
}

variable "public_ip_name" {
  type        = string
  description = "Name of the created Public IP resource."
}

variable "public_ip_prefixes" {
  type = list(object({
    name          = string
    prefix_length = number
  }))
  default     = []
  description = "(Optional) List of objects of desired public IP prefixes that should be created."
}



