data "azurerm_role_definition" "managed_identity_operator" {
  count = var.aks_identity_type == "UserAssigned" ? 1 : 0

  name = "Managed Identity Operator"
}

data "azurerm_role_definition" "network_contributor" {
  count = var.aks_identity_type == "UserAssigned" ? 1 : 0

  name = "Network Contributor"
}

data "azurerm_subscription" "current" {
}