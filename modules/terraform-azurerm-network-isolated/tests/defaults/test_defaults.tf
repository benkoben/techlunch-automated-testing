provider "azurerm" {
  disable_terraform_partner_id = true
  storage_use_azuread          = true

  features {}
}


module "test_network" {
  source = "../.."

  location                      = "westeurope"
  resource_group_name           = "rg-test-network-isolated-euw"
  virtual_network_name          = "vnet-test-network-isolated-euw"
  virtual_network_address_space = ["10.0.0.0/24"]
  nat_gateway_name              = "ngw-test-network-isolated-euw"
  public_ip_name                = "pip-test-network-isolated-euw"

  public_ip_prefixes = [
    {
      name          = "pip-1"
      prefix_length = 30
    },
    {
      name          = "pip-2"
      prefix_length = 30
    }
  ]
}
