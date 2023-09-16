variable "location" {
  type        = string
  description = "Azure region for deployment"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to create"
}

variable "whitelist_ip" {
  type        = set(string)
  description = "List of IP address to whitelist on all enabled services."
  default     = []
}

variable "whitelist_subnets" {
  type        = set(string)
  description = "List of virtual network IDs to whitelist on all enabled services"
  default     = []
}

variable "container_registry_dns_zone_id" {
  type        = string
  description = "DNS zone resource ID. Must be set if create_dns_zones is set to false"
  default     = null
}

variable "key_vault_dns_zone_id" {
  type        = string
  description = "DNS zone resource ID. Must be set if create_dns_zones is set to false"
  default     = null
}

variable "container_registry" {
  type = object({
    create              = bool
    name                = optional(string)
    sku                 = optional(string)
    admin_enabled       = optional(bool, false)
    acr_pull_identities = optional(list(string), [])
    acr_push_identities = optional(list(string), [])
    georeplications = optional(list(object({
      location                = string
      zone_redundancy_enabled = bool
      tags                    = optional(map(string), {})
    })), [])
    zone_redundancy_enabled = optional(bool)
  })
  description = "Controls the creation of container registry and its settings. acr_[ push | pull ]_identities control RBAC role assignments."
  default = {
    create = false
  }
}

variable "enable_private_networking" {
  type        = bool
  default     = false
  description = "If enabled then all deployed services will have private endpoints enabled"
}

variable "virtual_network_name" {
  type        = string
  description = "Name of the virtual network used for private endpoint connections"
  default     = ""
}

variable "virtual_network_resource_group" {
  type        = string
  default     = ""
  description = "Resource group of the virtual network used for private endpoint connections"
}

variable "subnet_address_prefix" {
  type        = string
  default     = ""
  description = "Name of the subnet that is created when private endpoints are enabled"
}

variable "subnet_name" {
  type        = string
  default     = ""
  description = "Address prefix for the subnet that is created when private endpoints are enabled"
}

variable "keyvault" {
  type = object({
    create   = bool
    name     = optional(string)
    sku_name = optional(string, "standard")

    access_policy = optional(list(object({
      application             = optional(string)
      certificate_permissions = optional(set(string))
      key_permissions         = optional(set(string))
      secret_permissions      = optional(set(string))
      storage_permissions     = optional(set(string))
    })), [])
    public_network_access_enabled = optional(bool, false)
  })
  description = "Controls the creation of container registry and its settings"
  default = {
    create = false
  }
}

variable "create_dns_zones" {
  type        = bool
  default     = false
  description = "Wether or not to create privatelink DNS zones. Should be used for online landing zones"
}
