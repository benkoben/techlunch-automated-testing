locals {
  acr_pull_identities = toset(concat([data.azurerm_client_config.current.object_id], var.container_registry.acr_pull_identities))
  acr_push_identities = toset(concat([data.azurerm_client_config.current.object_id], var.container_registry.acr_push_identities))
}


resource "azurerm_role_assignment" "acrpull" {
  for_each = local.acr_pull_identities

  scope                            = azurerm_container_registry.shared[0].id
  role_definition_name             = data.azurerm_role_definition.acr_pull.name
  principal_id                     = each.value
  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "acrpush" {
  for_each = local.acr_push_identities

  scope                            = azurerm_container_registry.shared[0].id
  role_definition_name             = data.azurerm_role_definition.acr_push.name
  principal_id                     = each.value
  skip_service_principal_aad_check = true
}
