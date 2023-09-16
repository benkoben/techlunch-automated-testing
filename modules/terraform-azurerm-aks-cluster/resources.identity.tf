resource "azurerm_user_assigned_identity" "aks" {
  count = var.aks_identity_type == "UserAssigned" ? 1 : 0

  resource_group_name = azurerm_resource_group.aks.name
  location            = azurerm_resource_group.aks.location
  name                = "mi-${var.name}"
}

resource "azurerm_user_assigned_identity" "kubelet" {
  count = var.aks_identity_type == "UserAssigned" ? 1 : 0

  location            = var.location
  name                = var.kubelet_identity_name
  resource_group_name = azurerm_resource_group.aks.name
}

resource "azurerm_role_assignment" "aks" {
  count = var.aks_identity_type == "UserAssigned" ? 1 : 0

  scope              = azurerm_resource_group.aks.id
  role_definition_id = "${data.azurerm_subscription.current.id}/${data.azurerm_role_definition.managed_identity_operator[0].role_definition_id}"
  principal_id       = azurerm_user_assigned_identity.aks[0].principal_id
}

resource "azurerm_role_assignment" "network_contributor" {
  count = var.aks_identity_type == "UserAssigned" ? 1 : 0

  scope              = azurerm_subnet.aks.id
  role_definition_id = "${data.azurerm_subscription.current.id}/${data.azurerm_role_definition.network_contributor[0].role_definition_id}"
  principal_id       = azurerm_user_assigned_identity.aks[0].principal_id
}

# resource "azurerm_role_assignment" "network_contributor_api_server" {
#   count = var.aks_identity_type == "UserAssigned" && var.vnet_integration_enabled ? 1 : 0

#   scope              = azurerm_subnet.api_server[0].id
#   role_definition_id = data.azurerm_role_definition.network_contributor[0].role_definition_id
#   principal_id       = azurerm_user_assigned_identity.aks[0].principal_id
# }

resource "azurerm_role_assignment" "network_contributor_api_server" {
  count = var.aks_identity_type == "UserAssigned" && var.vnet_integration_enabled ? 1 : 0

  scope              = azurerm_subnet.api_server[0].id
  role_definition_id = "${data.azurerm_subscription.current.id}${data.azurerm_role_definition.network_contributor[0].id}"
  principal_id       = azurerm_user_assigned_identity.aks[0].principal_id
}
