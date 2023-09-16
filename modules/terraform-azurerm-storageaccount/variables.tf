variable "name" {
    type = string
}

variable "location" {
  type = string
  default = "westeurope"
}

resource "azurerm_resource_group" "module" {
  name     = "rg-storage-${var.name}"
  location = var.location
}

resource "azurerm_storage_account" "module" {
  name                     = "storageaccountname"
  resource_group_name      = azurerm_resource_group.module.name
  location                 = azurerm_resource_group.module.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }
}