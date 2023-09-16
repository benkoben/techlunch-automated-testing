variable "aks_key_vault_secrets_provider" {
  type = object({
    secret_rotation_enabled  = optional(bool)
    secret_rotation_interval = optional(string)
  })
  default = {
    secret_rotation_enabled  = false
    secret_rotation_interval = "2m"
  }
  description = "Object that enables keyvault csi provider. Disabled by default"
}

variable "tags" {
  type        = map(string)
  description = "A map of tags which will be added to the resource group and its resources."
  default     = {}
}

variable "user_managed_nat_gateway_resource_id" {
  type        = string
  description = "Must be set if network_profile.outbound_type is set to userAssignedNATGateway. Is used to associate new AKS subnets with a pre-exsiting NAT gateway."
  default     = null
}

variable "location" {
  type        = string
  description = "Name of the Azure region to use"
  default     = "westeurope"

  validation {
    # Also edit local.short_locations whenever
    # the following condition is modified.
    condition = contains(
      [
        "useast",
        "uswest",
        "useast2",
        "westeurope",
        "northeurope",
        "swedencentral",
        "southcentralus",
        "northcentralus",
    ], var.location)
    error_message = "aks identity type must be set to either SystemAssigned or UserAssigned"
  }
}

variable "sku_tier" {
  type        = string
  description = "Azure Kubernetes cluster tier"
  default     = "Free"
}

variable "name" {
  type        = string
  description = "Name of AKS cluster"
}

variable "node_resource_group_name" {
  type        = string
  description = "Name of the node resource group used by AKS cluster"
}

variable "resource_group_name" {
  type        = string
  description = "Resource group to use for module deployment."
}

variable "automatic_channel_upgrade" {
  type        = string
  default     = "stable"
  description = "The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable. Omitting this field sets this value to none."

  validation {
    condition     = contains(["patch", "rapid", "node-image", "stable"], var.automatic_channel_upgrade)
    error_message = "Invalid value used for variable automatic_channel_upgrade. Must be set to either patch, rapid, node-image and stable."
  }
}

variable "vnet_integration_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Should API Server VNet Integration be enabled?"
}

variable "api_server_subnet_name" {
  type        = string
  default     = ""
  description = "Should be set if vnet_integration_enabled is true"
}

variable "api_server_subnet_prefix" {
  type        = string
  default     = ""
  description = "Should be set if vnet_integration_enabled is true"
}

variable "allowed_ip_address_ranges" {
  type        = list(string)
  description = "Whitelisting for kube API access"
}

variable "network_profile" {
  type = object({
    network_plugin      = optional(string, "azure")
    network_mode        = optional(string, "transparent")
    outbound_type       = optional(string, "loadBalancer")
    network_policy      = optional(string, "calico")
    ebpf_data_plane     = optional(string)
    dns_service_ip      = string
    docker_bridge_cidr  = string
    network_plugin_mode = optional(string, "Overlay")
    pod_cidr            = optional(string)
    pod_cidrs           = optional(list(string))
    service_cidr        = optional(string)
    service_cidrs       = optional(list(string))
    ip_versions         = optional(list(string), ["IPv4"])
    load_balancer_sku   = optional(string)
    load_balancer_profile = optional(object({
      idle_timeout_in_minutes     = optional(number, 30)
      managed_outbound_ip_count   = optional(number, 1)
      managed_outbound_ipv6_count = optional(number)
      outbound_ip_address_ids     = optional(list(string))
      outbound_ip_prefix_ids      = optional(list(string))
      outbound_ports_allocated    = optional(string)
    }), {})
    nat_gateway_profile = optional(object({
      idle_timeout_in_minutes   = optional(number, 10)
      managed_outbound_ip_count = optional(number)
    }), {})
  })
}

variable "default_node_pool" {
  default = {
    vm_size = "Standard_DS2_v2"
  }
  description = "Settings used for default node pool"
  type = object({
    vm_size                       = string
    capacity_reservation_group_id = optional(string)
    custom_ca_trust_enabled       = optional(bool, false)
    enable_auto_scaling           = optional(bool, true)
    max_count                     = optional(number)
    min_count                     = optional(number)
    node_count                    = optional(string, 3)
    enable_host_encryption        = optional(bool, false)
    enable_node_public_ip         = optional(bool, false)
    host_group_id                 = optional(string)
    fips_enabled                  = optional(bool, false)
    max_pods                      = optional(number, 35)
    node_network_profile = optional(object({
      node_public_ip_tags = optional(map(string))
    }))
    node_labels                  = optional(map(string), {})
    only_critical_addons_enabled = optional(bool)
    os_disk_size_gb              = optional(string, 128)
    os_disk_type                 = optional(string)
    os_sku                       = optional(string, "Ubuntu")
    pod_subnet_id                = optional(string)
    proximity_placement_group_id = optional(string)
    scale_down_mode              = optional(string)
    temporary_name_for_rotation  = optional(string)
    type                         = optional(string)
    tags                         = optional(map(string))
    ultra_ssd_enabled            = optional(bool)
    upgrade_settings = optional(object({
      max_surge = optional(string, "")
    }), {})
    workload_runtime = optional(string)
    zones            = optional(list(string))
  })
}

variable "workload_identity_enabled" {
  type        = bool
  default     = false
  description = "Wether workload identity should be enabled or not"
}

variable "aks_identity_type" {
  type        = string
  description = "The identity type that should be used for AKS cluster. Can be set to \"SystemAssigned\", \"UserAssigned\" or \"ServicePrincipal\""

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "ServicePrincipal"], var.aks_identity_type)
    error_message = "aks identity type must be set to either SystemAssigned, UserAssigned or ServicePrincipal"
  }
}

variable "kubelet_identity_name" {
  type        = string
  default     = ""
  description = "The name of managed identity that will be created for kubelet identity usage. Must be set if aks_identity_type is set to UserAssigned"
}

variable "dns_prefix" {
  type        = string
  default     = null
  description = "DNS prefix to set to cluster. Cannot be set if private_cluster_dns_prefix is set."
}

variable "local_account_disabled" {
  type        = bool
  default     = false
  description = "Controls if local account should be enabled or not. If set to true AAD integration must be configured on cluster."
}

variable "azure_policy_enabled" {
  type        = bool
  default     = false
  description = "Controls if managed gatekeeper should plugin should be installed."
}

variable "private_cluster_enabled" {
  type        = bool
  default     = false
  description = "Controls if the cluster should use a private endpoint for its API server."
}

variable "create_dns_zones" {
  type        = bool
  description = "Wether to let terraform create a new dns zone or let bring your own dns zone. Dont use this if looping this module call."
  default     = false
}

variable "dns_prefix_private_cluster" {
  type        = string
  description = "(Optional) Specifies the DNS prefix to use with private clusters. Changing this forces a new resource to be created."
  default     = null
}

variable "private_dns_zone_id" {
  type        = string
  default     = null
  description = "Private dns zone ID to use for private cluster. Should only be set if `private_cluster_enabled` is true but `create_dns_zones` is false"
}

variable "azure_active_directory_role_based_access_control" {
  type = object({
    managed                = bool
    azure_rbac_enabled     = bool
    admin_group_object_ids = list(string)
  })
  default     = null
  description = "Controls settings for Azure RBAC. Can be used as an alternative to Kubernetes RBAC."
}

variable "virtual_network_id" {
  type        = string
  description = "ID of the virtual network used for the cluster"
  default     = null
}

variable "subnet_name" {
  type        = string
  description = "Name of the subnet created by this module."
  default     = null
}

variable "subnet_address_prefix" {
  type        = string
  description = "Address prefix for the subnet creared by this module"
  default     = null
}

variable "oidc_issuer_enabled" {
  type        = bool
  description = "Controls wether the oidc issuer should be enabled on the cluster."
  default     = false
}

variable "admin_username" {
  type        = string
  description = "Admin username for node pools"
}

variable "node_pools" {
  description = "Settings used for additional node pools."
  default     = []
  type = list(object({
    name                          = string
    vm_size                       = string
    capacity_reservation_group_id = optional(string)
    custom_ca_trust_enabled       = optional(bool, false)
    enable_auto_scaling           = optional(bool, true)
    max_count                     = optional(number, 0)
    min_count                     = optional(number, 0)
    node_count                    = optional(number, 1)
    enable_host_encryption        = optional(bool, false)
    enable_node_public_ip         = optional(bool, false)
    eviction_policy               = optional(string)
    host_group_id                 = optional(string)
    fips_enabled                  = optional(bool, false)
    max_pods                      = optional(number, 35)
    mode                          = optional(string, "User")
    node_network_profile = optional(object({
      node_public_ip_tags = optional(map(string))
    }), {})
    node_labels                  = optional(map(string), {})
    node_public_ip_prefix_id     = optional(string)
    node_taints                  = optional(list(string), [])
    os_disk_size_gb              = optional(string, 128)
    os_disk_type                 = optional(string)
    pod_subnet_id                = optional(string)
    os_sku                       = optional(string, "Ubuntu")
    os_type                      = optional(string)
    priority                     = optional(string)
    proximity_placement_group_id = optional(string)
    spot_max_price               = optional(string)
    tags                         = optional(map(string))
    scale_down_mode              = optional(string)
    ultra_ssd_enabled            = optional(bool)
    vnet_subnet_id               = optional(string)
    windows_profile = optional(object({
      outbound_nat_enabled = optional(bool, true)
    }), {})
    workload_runtime = optional(string)
    zones            = optional(list(string), [])
  }))
}

variable "private_cluster_public_fqdn_enabled" {
  type        = bool
  default     = false
  description = "(Optional) Specifies whether a Public FQDN for this Private Cluster should be added. Defaults to false"
}
