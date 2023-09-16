data "azurerm_client_config" "current" {}

data "azurerm_role_definition" "acr_pull" {
  name = "AcrPull"
}

data "azurerm_role_definition" "acr_push" {
  name = "AcrPush"
}

data "azurerm_resource_group" "vnet" {
  count = var.enable_private_networking ? 1 : 0

  name = var.virtual_network_resource_group
}

data "azurerm_virtual_network" "lz_vnet" {
  count = var.enable_private_networking ? 1 : 0

  name                = var.virtual_network_name
  resource_group_name = var.virtual_network_resource_group
}
