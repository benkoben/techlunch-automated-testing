resource "azurerm_resource_group" "module" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_storage_account" "module" {
  name                     = var.storage_account_name
  resource_group_name      = azurerm_resource_group.module.name
  location                 = azurerm_resource_group.module.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type

  tags = var.tags
}


