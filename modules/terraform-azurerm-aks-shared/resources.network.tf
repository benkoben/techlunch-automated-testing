resource "azurerm_subnet" "shared" {
  count = var.enable_private_networking ? 1 : 0

  name                 = var.subnet_name
  resource_group_name  = data.azurerm_virtual_network.lz_vnet[0].resource_group_name
  virtual_network_name = data.azurerm_virtual_network.lz_vnet[0].name
  address_prefixes     = [var.subnet_address_prefix]
}

resource "azurerm_private_endpoint" "registry" {
  count = var.container_registry.create && var.enable_private_networking ? 1 : 0

  name                = "pend-${var.container_registry.name}"
  location            = azurerm_resource_group.shared.location
  resource_group_name = azurerm_resource_group.shared.name
  subnet_id           = azurerm_subnet.shared[0].id

  private_service_connection {
    name                           = "pend-${var.container_registry.name}"
    private_connection_resource_id = azurerm_container_registry.shared[0].id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.enable_private_networking ? var.create_dns_zones ? [azurerm_private_dns_zone.registry[0].id] : [var.container_registry_dns_zone_id] : []

    content {
      name                 = sha256(private_dns_zone_group.value)
      private_dns_zone_ids = [private_dns_zone_group.value]
    }
  }
}

resource "azurerm_private_dns_zone" "registry" {
  count               = var.container_registry.create && var.create_dns_zones ? 1 : 0
  name                = "${var.location}.privatelink.azurecr.io"
  resource_group_name = data.azurerm_resource_group.vnet[0].name
}

resource "azurerm_private_dns_zone_virtual_network_link" "registry" {
  count = var.container_registry.create && var.create_dns_zones ? 1 : 0

  name                  = "azureacr"
  resource_group_name   = data.azurerm_resource_group.vnet[0].name
  private_dns_zone_name = azurerm_private_dns_zone.registry[0].name
  virtual_network_id    = data.azurerm_virtual_network.lz_vnet[0].id
}

resource "azurerm_private_endpoint" "vault" {
  count = var.keyvault.create && var.enable_private_networking ? 1 : 0

  name                = "pend-${var.keyvault.name}"
  location            = azurerm_resource_group.shared.location
  resource_group_name = azurerm_resource_group.shared.name
  subnet_id           = azurerm_subnet.shared[0].id

  private_service_connection {
    name                           = "pend-${var.keyvault.name}"
    private_connection_resource_id = azurerm_key_vault.shared[0].id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.enable_private_networking ? var.create_dns_zones ? [azurerm_private_dns_zone.keyvault[0].id] : [var.key_vault_dns_zone_id] : []

    content {
      name                 = sha256(private_dns_zone_group.value)
      private_dns_zone_ids = [private_dns_zone_group.value]
    }
  }
}

resource "azurerm_private_dns_zone" "keyvault" {
  count               = var.keyvault.create && var.create_dns_zones ? 1 : 0
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = data.azurerm_resource_group.vnet[0].name
}

resource "azurerm_private_dns_zone_virtual_network_link" "keyvault" {
  count = var.keyvault.create && var.create_dns_zones ? 1 : 0

  name                  = "keyvault"
  resource_group_name   = data.azurerm_resource_group.vnet[0].name
  private_dns_zone_name = azurerm_private_dns_zone.keyvault[0].name
  virtual_network_id    = data.azurerm_virtual_network.lz_vnet[0].id
}
