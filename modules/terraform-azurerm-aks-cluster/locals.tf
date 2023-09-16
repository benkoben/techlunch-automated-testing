locals {
  # Parsing resource names and resource groups from ID strings
  virtual_network_name           = try(split("/", var.virtual_network_id)[8], null)
  virtual_network_resource_group = try(split("/", var.virtual_network_id)[4], null)
  # If bring your own dns zone is enabled, then use the data source that is based the parameter var.private_dns_zone_id , else use the id from the private dns zone that this module will create.
  # private_dns_zone_id = var.private_cluster_enabled ? var.create_dns_zones ? azurerm_private_dns_zone.privatelink_aks[0].id : var. : null
}
