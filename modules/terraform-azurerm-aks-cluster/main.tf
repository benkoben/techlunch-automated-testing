terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.62.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.4"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
  required_version = ">= 1.3.4"
}

resource "azurerm_resource_group" "aks" {
  name     = var.resource_group_name
  location = var.location

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "tls_private_key" "aks" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                                = var.name
  location                            = azurerm_resource_group.aks.location
  resource_group_name                 = azurerm_resource_group.aks.name
  dns_prefix                          = var.dns_prefix
  dns_prefix_private_cluster          = var.dns_prefix_private_cluster
  sku_tier                            = var.sku_tier
  node_resource_group                 = var.node_resource_group_name
  local_account_disabled              = var.local_account_disabled
  automatic_channel_upgrade           = var.automatic_channel_upgrade
  azure_policy_enabled                = var.azure_policy_enabled
  oidc_issuer_enabled                 = var.oidc_issuer_enabled
  workload_identity_enabled           = var.oidc_issuer_enabled && var.workload_identity_enabled ? true : false
  private_cluster_enabled             = var.private_cluster_enabled
  private_dns_zone_id                 = var.private_dns_zone_id
  private_cluster_public_fqdn_enabled = var.private_cluster_public_fqdn_enabled

  api_server_access_profile {
    authorized_ip_ranges     = var.allowed_ip_address_ranges
    subnet_id                = var.vnet_integration_enabled ? azurerm_subnet.api_server[0].id : null
    vnet_integration_enabled = var.vnet_integration_enabled
  }

  network_profile {
    network_plugin      = var.network_profile.network_plugin
    dns_service_ip      = var.network_profile.dns_service_ip
    network_mode        = var.network_profile.network_mode
    network_policy      = var.network_profile.network_policy
    docker_bridge_cidr  = var.network_profile.docker_bridge_cidr
    ebpf_data_plane     = var.network_profile.ebpf_data_plane
    network_plugin_mode = var.network_profile.network_plugin_mode
    outbound_type       = var.network_profile.outbound_type
    pod_cidr            = var.network_profile.pod_cidr
    pod_cidrs           = var.network_profile.pod_cidrs
    service_cidr        = var.network_profile.service_cidr
    service_cidrs       = var.network_profile.service_cidrs
    ip_versions         = var.network_profile.ip_versions
    load_balancer_sku   = var.network_profile.load_balancer_sku

    dynamic "load_balancer_profile" {
      for_each = var.network_profile.load_balancer_profile[*]

      content {
        idle_timeout_in_minutes     = load_balancer_profile.value.idle_timeout_in_minutes
        managed_outbound_ip_count   = load_balancer_profile.value.managed_outbound_ip_count
        managed_outbound_ipv6_count = load_balancer_profile.value.managed_outbound_ipv6_count
        outbound_ip_address_ids     = load_balancer_profile.value.outbound_ip_address_ids
        outbound_ip_prefix_ids      = load_balancer_profile.value.outbound_ip_prefix_ids
        outbound_ports_allocated    = load_balancer_profile.value.outbound_ports_allocated
      }
    }

    dynamic "nat_gateway_profile" {
      for_each = var.network_profile.nat_gateway_profile[*]

      content {
        idle_timeout_in_minutes   = nat_gateway_profile.value.idle_timeout_in_minutes
        managed_outbound_ip_count = nat_gateway_profile.value.managed_outbound_ip_count
      }
    }

  }

  linux_profile {
    admin_username = var.admin_username
    ssh_key {
      key_data = tls_private_key.aks.public_key_openssh
    }
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = var.aks_key_vault_secrets_provider.secret_rotation_enabled
    secret_rotation_interval = var.aks_key_vault_secrets_provider.secret_rotation_interval
  }

  dynamic "kubelet_identity" {
    for_each = var.aks_identity_type == "UserAssigned" ? [
      {
        client_id : azurerm_user_assigned_identity.kubelet[0].client_id
        object_id : azurerm_user_assigned_identity.kubelet[0].principal_id
        user_assigned_identity_id : azurerm_user_assigned_identity.kubelet[0].id
      }
    ] : []

    content {
      client_id                 = kubelet_identity.value.client_id
      object_id                 = kubelet_identity.value.object_id
      user_assigned_identity_id = kubelet_identity.value.user_assigned_identity_id
    }
  }

  default_node_pool {
    name                          = "default"
    vm_size                       = var.default_node_pool.vm_size
    capacity_reservation_group_id = var.default_node_pool.capacity_reservation_group_id
    custom_ca_trust_enabled       = var.default_node_pool.custom_ca_trust_enabled
    enable_auto_scaling           = var.default_node_pool.enable_auto_scaling
    max_count                     = var.default_node_pool.max_count
    min_count                     = var.default_node_pool.min_count
    node_count                    = var.default_node_pool.node_count
    enable_host_encryption        = var.default_node_pool.enable_host_encryption
    enable_node_public_ip         = var.default_node_pool.enable_node_public_ip
    host_group_id                 = var.default_node_pool.host_group_id
    fips_enabled                  = var.default_node_pool.fips_enabled
    max_pods                      = var.default_node_pool.max_pods

    message_of_the_day = base64encode("This vm belongs to node pool 'default'")

    node_labels                  = var.default_node_pool.node_labels
    only_critical_addons_enabled = var.default_node_pool.only_critical_addons_enabled
    os_disk_size_gb              = var.default_node_pool.os_disk_size_gb
    os_disk_type                 = var.default_node_pool.os_disk_type
    os_sku                       = var.default_node_pool.os_sku
    pod_subnet_id                = var.default_node_pool.pod_subnet_id
    proximity_placement_group_id = var.default_node_pool.proximity_placement_group_id
    scale_down_mode              = var.default_node_pool.scale_down_mode
    temporary_name_for_rotation  = var.default_node_pool.temporary_name_for_rotation
    type                         = var.default_node_pool.type
    tags                         = var.default_node_pool.tags
    ultra_ssd_enabled            = var.default_node_pool.ultra_ssd_enabled

    vnet_subnet_id   = azurerm_subnet.aks.id
    workload_runtime = var.default_node_pool.workload_runtime
    zones            = var.default_node_pool.zones
  }

  dynamic "identity" {
    for_each = var.aks_identity_type == "UserAssigned" ? [azurerm_user_assigned_identity.aks[0]] : []

    content {
      type         = "UserAssigned"
      identity_ids = [identity.value.id]
    }
  }

  dynamic "identity" {
    for_each = var.aks_identity_type == "SystemAssigned" ? [var.aks_identity_type] : []
    content {
      type = identity.value
    }
  }

  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.azure_active_directory_role_based_access_control[*]

    content {
      managed                = azure_active_directory_role_based_access_control.value.managed
      azure_rbac_enabled     = azure_active_directory_role_based_access_control.value.azure_rbac_enabled
      admin_group_object_ids = azure_active_directory_role_based_access_control.value.admin_group_object_ids
    }
  }

  tags = var.tags

  depends_on = [
    azurerm_subnet_nat_gateway_association.aks,
    azurerm_role_assignment.aks
  ]

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count,
      network_profile[0].load_balancer_profile[0].managed_outbound_ip_count,
      network_profile[0].load_balancer_profile[0].managed_outbound_ipv6_count,
      api_server_access_profile,
      tags
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "aks" {
  for_each = {
    for index, node_pool in var.node_pools :
    node_pool.name => node_pool
  }

  kubernetes_cluster_id         = azurerm_kubernetes_cluster.aks.id
  name                          = each.value.name
  vm_size                       = each.value.vm_size
  capacity_reservation_group_id = each.value.capacity_reservation_group_id
  custom_ca_trust_enabled       = each.value.custom_ca_trust_enabled
  enable_auto_scaling           = each.value.enable_auto_scaling
  max_count                     = each.value.max_count
  min_count                     = each.value.min_count
  node_count                    = each.value.node_count
  enable_host_encryption        = each.value.enable_host_encryption
  enable_node_public_ip         = each.value.enable_node_public_ip
  eviction_policy               = each.value.eviction_policy
  host_group_id                 = each.value.host_group_id
  fips_enabled                  = each.value.fips_enabled
  max_pods                      = each.value.max_pods
  message_of_the_day            = base64encode("This vm belongs to node pool '${each.value.name}'")
  mode                          = each.value.mode

  node_labels                  = each.value.node_labels
  node_public_ip_prefix_id     = each.value.node_public_ip_prefix_id
  node_taints                  = each.value.node_taints
  os_disk_size_gb              = each.value.os_disk_size_gb
  os_disk_type                 = each.value.os_disk_type
  pod_subnet_id                = each.value.pod_subnet_id
  os_sku                       = each.value.os_sku
  os_type                      = each.value.os_type
  priority                     = each.value.priority
  proximity_placement_group_id = each.value.proximity_placement_group_id
  spot_max_price               = each.value.spot_max_price
  tags                         = var.tags
  scale_down_mode              = each.value.scale_down_mode
  ultra_ssd_enabled            = each.value.ultra_ssd_enabled
  vnet_subnet_id               = azurerm_subnet.aks.id

  workload_runtime = each.value.workload_runtime
  zones            = each.value.zones


  lifecycle {
    ignore_changes = [
      node_count,
      tags
    ]
  }
}
