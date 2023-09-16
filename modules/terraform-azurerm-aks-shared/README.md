# Azure Kubernetes Services Shared services

A module that contains common services found in Kubernetes landing zones.

Can deploy the following:

1. Container registry
2. Keyvault
3. Private endpoints for all services if wanted

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.51.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.51.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |
| [azurerm_role_definition.acr_pull](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/role_definition) | data source |
| [azurerm_role_definition.acr_push](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/role_definition) | data source |
| [azurerm_virtual_network.lz_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_registry"></a> [container\_registry](#input\_container\_registry) | Controls the creation of container registry and its settings. acr\_[ push \| pull ]\_identities control RBAC role assignments. | <pre>object({<br>    create              = bool<br>    name                = optional(string)<br>    sku                 = optional(string)<br>    admin_enabled       = optional(bool, false)<br>    acr_pull_identities = optional(set(string), [])<br>    acr_push_identities = optional(set(string), [])<br>    georeplications = optional(list(object({<br>      location                = string<br>      zone_redundancy_enabled = bool<br>      tags                    = optional(map(string), {})<br>    })), [])<br>    zone_redundancy_enabled = optional(bool)<br>  })</pre> | <pre>{<br>  "create": false<br>}</pre> | no |
| <a name="input_container_registry_dns_zone_id"></a> [container\_registry\_dns\_zone\_id](#input\_container\_registry\_dns\_zone\_id) | DNS zone resource ID. Must be set if create\_dns\_zones is set to false | `string` | `null` | no |
| <a name="input_create_dns_zones"></a> [create\_dns\_zones](#input\_create\_dns\_zones) | Wether or not to create privatelink DNS zones. Should be used for online landing zones | `bool` | `false` | no |
| <a name="input_enable_private_networking"></a> [enable\_private\_networking](#input\_enable\_private\_networking) | If enabled then all deployed services will have private endpoints enabled | `bool` | `false` | no |
| <a name="input_key_vault_dns_zone_id"></a> [key\_vault\_dns\_zone\_id](#input\_key\_vault\_dns\_zone\_id) | DNS zone resource ID. Must be set if create\_dns\_zones is set to false | `string` | `null` | no |
| <a name="input_keyvault"></a> [keyvault](#input\_keyvault) | Controls the creation of container registry and its settings | <pre>object({<br>    create   = bool<br>    name     = optional(string)<br>    sku_name = optional(string, "standard")<br><br>    access_policy = optional(list(object({<br>      application             = optional(string)<br>      certificate_permissions = optional(set(string))<br>      key_permissions         = optional(set(string))<br>      secret_permissions      = optional(set(string))<br>      storage_permissions     = optional(set(string))<br>    })), [])<br>    public_network_access_enabled = optional(bool, false)<br>  })</pre> | <pre>{<br>  "create": false<br>}</pre> | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for deployment | `string` | n/a | yes |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group to create | `string` | n/a | yes |
| <a name="input_subnet_address_prefix"></a> [subnet\_address\_prefix](#input\_subnet\_address\_prefix) | Name of the subnet that is created when private endpoints are enabled | `string` | `""` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Address prefix for the subnet that is created when private endpoints are enabled | `string` | `""` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the virtual network used for private endpoint connections | `string` | `""` | no |
| <a name="input_virtual_network_resource_group"></a> [virtual\_network\_resource\_group](#input\_virtual\_network\_resource\_group) | Resource group of the virtual network used for private endpoint connections | `string` | `""` | no |
| <a name="input_whitelist_ip"></a> [whitelist\_ip](#input\_whitelist\_ip) | List of IP address to whitelist on all enabled services. | `set(string)` | `[]` | no |
| <a name="input_whitelist_subnets"></a> [whitelist\_subnets](#input\_whitelist\_subnets) | List of virtual network IDs to whitelist on all enabled services | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_container_registry_id"></a> [container\_registry\_id](#output\_container\_registry\_id) | n/a |
| <a name="output_keyvault_id"></a> [keyvault\_id](#output\_keyvault\_id) | n/a |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
<!-- END_TF_DOCS -->
