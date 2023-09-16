resource "azurerm_private_dns_zone" "privatelink_aks" {
  count = var.create_dns_zones && var.private_cluster_enabled == true ? 1 : 0

  name                = "privatelink.${var.location}.azmk8s.io"
  resource_group_name = local.virtual_network_resource_group
}

resource "azurerm_role_assignment" "when_create_dns_zones_enabled" {
  count = var.create_dns_zones && var.private_cluster_enabled ? 1 : 0

  scope                = azurerm_private_dns_zone.privatelink_aks[0].id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks[0].principal_id
}

resource "azurerm_private_dns_zone_virtual_network_link" "when_create_dns_zones" {
  count = var.create_dns_zones && var.private_cluster_enabled ? 1 : 0

  name                  = "link-private-dns"
  resource_group_name   = local.virtual_network_resource_group
  private_dns_zone_name = azurerm_private_dns_zone.privatelink_aks[0].name
  virtual_network_id    = var.virtual_network_id
}

resource "azurerm_role_assignment" "when_create_dns_zones_disabled" {
  count = var.create_dns_zones == false && var.private_cluster_enabled ? 1 : 0

  scope                = var.private_dns_zone_id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.aks[0].principal_id
}
