terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.51.0"
    }
  }
  required_version = ">= 1.3.4"
}

resource "azurerm_resource_group" "shared" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_container_registry" "shared" {
  count = local.container_registry.create ? 1 : 0

  name                = local.container_registry.name
  resource_group_name = azurerm_resource_group.shared.name
  location            = azurerm_resource_group.shared.location
  admin_enabled       = local.container_registry.admin_enabled
  sku                 = local.container_registry.sku

  dynamic "georeplications" {
    for_each = local.container_registry.georeplications

    content {
      location                = georeplications.value.location
      zone_redundancy_enabled = georeplications.value.zone_redundancy_enabled
      tags                    = georeplications.value.tags
    }
  }

  dynamic "network_rule_set" {
    for_each = [local.container_registry.network_rules]

    content {
      default_action = "Deny"
      dynamic "ip_rule" {
        for_each = network_rule_set.value.ip_rules

        content {
          action   = "Allow"
          ip_range = ip_rule.value
        }
      }

      dynamic "virtual_network" {
        for_each = network_rule_set.value.whitelist_subnets

        content {
          action    = "Allow"
          subnet_id = virtual_network.value
        }
      }
    }
  }

  zone_redundancy_enabled = var.container_registry.zone_redundancy_enabled
}

resource "azurerm_key_vault" "shared" {
  count = var.keyvault.create ? 1 : 0

  name                       = var.keyvault.name
  location                   = azurerm_resource_group.shared.location
  resource_group_name        = azurerm_resource_group.shared.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = true

  sku_name = var.keyvault.sku_name

  dynamic "access_policy" {
    for_each = var.keyvault.access_policy

    content {
      tenant_id = data.azurerm_client_config.current.tenant_id
      object_id = access_policy.value.application

      certificate_permissions = access_policy.value.key_permissions

      key_permissions = access_policy.value.key_permissions

      secret_permissions = access_policy.value.secret_permissions

      storage_permissions = access_policy.value.storage_permissions
    }
  }

  network_acls {
    bypass                     = "None"
    default_action             = "Deny"
    ip_rules                   = var.whitelist_ip
    virtual_network_subnet_ids = var.whitelist_subnets
  }
}
