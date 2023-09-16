output "vnet_id" {
  value       = azurerm_virtual_network.main.id
  description = "Resource ID string of the virtual network"
}

output "vnet_name" {
  value       = azurerm_virtual_network.main.name
  description = "Virtual network name"
}

output "resource_group_id" {
  value       = azurerm_resource_group.main.id
  description = "Resource group ID"
}

output "resource_group_name" {
  value       = azurerm_resource_group.main.name
  description = "Resource group name"
}

output "resource_group_location" {
  value       = azurerm_resource_group.main.location
  description = "Resource group location"
}

output "public_ip_id" {
  value       = azurerm_public_ip.main.id
  description = "Resource ID string of the public IP resource"
}

output "public_ip_address" {
  value       = azurerm_public_ip.main.ip_address
  description = "IP address of the public IP resource"
}

output "public_ip_fqdn" {
  value       = azurerm_public_ip.main.fqdn
  description = "Fully qualified domain name (FQDN) of public IP"
}

output "nat_gateway_id" {
  value       = azurerm_nat_gateway.main.id
  description = "ID of NAT gateway"
}

output "nat_gateway_guid" {
  value       = azurerm_nat_gateway.main.resource_guid
  description = "GUID of NAT gateway"
}

output "public_ip_prefixes" {
  value = {
    for prefix in local.public_ip_prefixes :
    prefix.name => {
      id     = azurerm_public_ip_prefix.main[prefix.name].id
      prefix = azurerm_public_ip_prefix.main[prefix.name].ip_prefix
    }

  }
  description = "Object with collection of public ip prefix IDs. Each entry contains an `id` and a `ip_prefix attribute.`"
}
