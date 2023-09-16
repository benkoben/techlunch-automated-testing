resource "azurerm_subnet" "aks" {
  name                 = var.subnet_name
  resource_group_name  = local.virtual_network_resource_group
  virtual_network_name = local.virtual_network_name
  address_prefixes     = [var.subnet_address_prefix]
}

resource "azurerm_subnet" "api_server" {
  count                = var.vnet_integration_enabled ? 1 : 0
  name                 = var.api_server_subnet_name
  resource_group_name  = local.virtual_network_resource_group
  virtual_network_name = local.virtual_network_name
  address_prefixes     = [var.api_server_subnet_prefix]

  delegation {
    name = "apiServerAccessProfile"

    service_delegation {
      name = "Microsoft.ContainerService/managedClusters"
    }
  }
}

resource "azurerm_subnet_nat_gateway_association" "aks" {
  subnet_id      = azurerm_subnet.aks.id
  nat_gateway_id = var.user_managed_nat_gateway_resource_id
}
