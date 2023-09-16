output "resource_group_name" {
  value = azurerm_resource_group.shared.name
}

output "resource_group_id" {
  value = azurerm_resource_group.shared.id
}

output "container_registry_id" {
  value = azurerm_container_registry.shared[*].id
}

output "keyvault_id" {
  value = azurerm_key_vault.shared[*].id
}
