# Azure Kubernetes Services

AKS module that can be used to deploy AKS with different configurations.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.62.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.1 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 4.0.4 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.64.0 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.4 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_private_dns_zone.privatelink_aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone) | resource |
| [azurerm_private_dns_zone_virtual_network_link.when_create_dns_zones](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_dns_zone_virtual_network_link) | resource |
| [azurerm_resource_group.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.network_contributor_api_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.when_create_dns_zones_disabled](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.when_create_dns_zones_enabled](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_subnet.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.api_server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_nat_gateway_association.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_nat_gateway_association) | resource |
| [azurerm_user_assigned_identity.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_user_assigned_identity.kubelet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [tls_private_key.aks](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [azurerm_role_definition.managed_identity_operator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/role_definition) | data source |
| [azurerm_role_definition.network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/role_definition) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_username"></a> [admin\_username](#input\_admin\_username) | Admin username for node pools | `string` | n/a | yes |
| <a name="input_aks_identity_type"></a> [aks\_identity\_type](#input\_aks\_identity\_type) | The identity type that should be used for AKS cluster. Can be set to "SystemAssigned", "UserAssigned" or "ServicePrincipal" | `string` | n/a | yes |
| <a name="input_aks_key_vault_secrets_provider"></a> [aks\_key\_vault\_secrets\_provider](#input\_aks\_key\_vault\_secrets\_provider) | Object that enables keyvault csi provider. Disabled by default | <pre>object({<br>    secret_rotation_enabled  = optional(bool)<br>    secret_rotation_interval = optional(string)<br>  })</pre> | <pre>{<br>  "secret_rotation_enabled": false,<br>  "secret_rotation_interval": "2m"<br>}</pre> | no |
| <a name="input_allowed_ip_address_ranges"></a> [allowed\_ip\_address\_ranges](#input\_allowed\_ip\_address\_ranges) | Whitelisting for kube API access | `list(string)` | n/a | yes |
| <a name="input_api_server_subnet_name"></a> [api\_server\_subnet\_name](#input\_api\_server\_subnet\_name) | Should be set if vnet\_integration\_enabled is true | `string` | `""` | no |
| <a name="input_api_server_subnet_prefix"></a> [api\_server\_subnet\_prefix](#input\_api\_server\_subnet\_prefix) | Should be set if vnet\_integration\_enabled is true | `string` | `""` | no |
| <a name="input_automatic_channel_upgrade"></a> [automatic\_channel\_upgrade](#input\_automatic\_channel\_upgrade) | The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, node-image and stable. Omitting this field sets this value to none. | `string` | `"stable"` | no |
| <a name="input_azure_active_directory_role_based_access_control"></a> [azure\_active\_directory\_role\_based\_access\_control](#input\_azure\_active\_directory\_role\_based\_access\_control) | Controls settings for Azure RBAC. Can be used as an alternative to Kubernetes RBAC. | <pre>object({<br>    managed                = bool<br>    azure_rbac_enabled     = bool<br>    admin_group_object_ids = list(string)<br>  })</pre> | `null` | no |
| <a name="input_azure_policy_enabled"></a> [azure\_policy\_enabled](#input\_azure\_policy\_enabled) | Controls if managed gatekeeper should plugin should be installed. | `bool` | `false` | no |
| <a name="input_create_dns_zones"></a> [create\_dns\_zones](#input\_create\_dns\_zones) | Wether to let terraform create a new dns zone or let bring your own dns zone. Dont use this if looping this module call. | `bool` | `false` | no |
| <a name="input_default_node_pool"></a> [default\_node\_pool](#input\_default\_node\_pool) | Settings used for default node pool | <pre>object({<br>    vm_size                       = string<br>    capacity_reservation_group_id = optional(string)<br>    custom_ca_trust_enabled       = optional(bool, false)<br>    enable_auto_scaling           = optional(bool, true)<br>    max_count                     = optional(number)<br>    min_count                     = optional(number)<br>    node_count                    = optional(string, 3)<br>    enable_host_encryption        = optional(bool, false)<br>    enable_node_public_ip         = optional(bool, false)<br>    host_group_id                 = optional(string)<br>    fips_enabled                  = optional(bool, false)<br>    max_pods                      = optional(number, 35)<br>    node_network_profile = optional(object({<br>      node_public_ip_tags = optional(map(string))<br>    }))<br>    node_labels                  = optional(map(string), {})<br>    only_critical_addons_enabled = optional(bool)<br>    os_disk_size_gb              = optional(string, 128)<br>    os_disk_type                 = optional(string)<br>    os_sku                       = optional(string, "Ubuntu")<br>    pod_subnet_id                = optional(string)<br>    proximity_placement_group_id = optional(string)<br>    scale_down_mode              = optional(string)<br>    temporary_name_for_rotation  = optional(string)<br>    type                         = optional(string)<br>    tags                         = optional(map(string))<br>    ultra_ssd_enabled            = optional(bool)<br>    upgrade_settings = optional(object({<br>      max_surge = optional(string, "")<br>    }), {})<br>    workload_runtime = optional(string)<br>    zones            = optional(list(string))<br>  })</pre> | <pre>{<br>  "vm_size": "Standard_DS2_v2"<br>}</pre> | no |
| <a name="input_dns_prefix"></a> [dns\_prefix](#input\_dns\_prefix) | DNS prefix to set to cluster. Cannot be set if private\_cluster\_dns\_prefix is set. | `string` | `null` | no |
| <a name="input_dns_prefix_private_cluster"></a> [dns\_prefix\_private\_cluster](#input\_dns\_prefix\_private\_cluster) | (Optional) Specifies the DNS prefix to use with private clusters. Changing this forces a new resource to be created. | `string` | `null` | no |
| <a name="input_kubelet_identity_name"></a> [kubelet\_identity\_name](#input\_kubelet\_identity\_name) | The name of managed identity that will be created for kubelet identity usage. Must be set if aks\_identity\_type is set to UserAssigned | `string` | `""` | no |
| <a name="input_local_account_disabled"></a> [local\_account\_disabled](#input\_local\_account\_disabled) | Controls if local account should be enabled or not. If set to true AAD integration must be configured on cluster. | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | Name of the Azure region to use | `string` | `"westeurope"` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of AKS cluster | `string` | n/a | yes |
| <a name="input_network_profile"></a> [network\_profile](#input\_network\_profile) | n/a | <pre>object({<br>    network_plugin      = optional(string, "azure")<br>    network_mode        = optional(string, "transparent")<br>    outbound_type       = optional(string, "loadBalancer")<br>    network_policy      = optional(string, "calico")<br>    ebpf_data_plane     = optional(string)<br>    dns_service_ip      = string<br>    docker_bridge_cidr  = string<br>    network_plugin_mode = optional(string, "Overlay")<br>    pod_cidr            = optional(string)<br>    pod_cidrs           = optional(list(string))<br>    service_cidr        = optional(string)<br>    service_cidrs       = optional(list(string))<br>    ip_versions         = optional(list(string), ["IPv4"])<br>    load_balancer_sku   = optional(string)<br>    load_balancer_profile = optional(object({<br>      idle_timeout_in_minutes     = optional(number, 30)<br>      managed_outbound_ip_count   = optional(number, 1)<br>      managed_outbound_ipv6_count = optional(number)<br>      outbound_ip_address_ids     = optional(list(string))<br>      outbound_ip_prefix_ids      = optional(list(string))<br>      outbound_ports_allocated    = optional(string)<br>    }), {})<br>    nat_gateway_profile = optional(object({<br>      idle_timeout_in_minutes   = optional(number, 10)<br>      managed_outbound_ip_count = optional(number)<br>    }), {})<br>  })</pre> | n/a | yes |
| <a name="input_node_pools"></a> [node\_pools](#input\_node\_pools) | Settings used for additional node pools. | <pre>list(object({<br>    name                          = string<br>    vm_size                       = string<br>    capacity_reservation_group_id = optional(string)<br>    custom_ca_trust_enabled       = optional(bool, false)<br>    enable_auto_scaling           = optional(bool, true)<br>    max_count                     = optional(number, 0)<br>    min_count                     = optional(number, 0)<br>    node_count                    = optional(number, 1)<br>    enable_host_encryption        = optional(bool, false)<br>    enable_node_public_ip         = optional(bool, false)<br>    eviction_policy               = optional(string)<br>    host_group_id                 = optional(string)<br>    fips_enabled                  = optional(bool, false)<br>    max_pods                      = optional(number, 35)<br>    mode                          = optional(string, "User")<br>    node_network_profile = optional(object({<br>      node_public_ip_tags = optional(map(string))<br>    }), {})<br>    node_labels                  = optional(map(string), {})<br>    node_public_ip_prefix_id     = optional(string)<br>    node_taints                  = optional(list(string), [])<br>    os_disk_size_gb              = optional(string, 128)<br>    os_disk_type                 = optional(string)<br>    pod_subnet_id                = optional(string)<br>    os_sku                       = optional(string, "Ubuntu")<br>    os_type                      = optional(string)<br>    priority                     = optional(string)<br>    proximity_placement_group_id = optional(string)<br>    spot_max_price               = optional(string)<br>    tags                         = optional(map(string))<br>    scale_down_mode              = optional(string)<br>    ultra_ssd_enabled            = optional(bool)<br>    vnet_subnet_id               = optional(string)<br>    windows_profile = optional(object({<br>      outbound_nat_enabled = optional(bool, true)<br>    }), {})<br>    workload_runtime = optional(string)<br>    zones            = optional(list(string), [])<br>  }))</pre> | `[]` | no |
| <a name="input_node_resource_group_name"></a> [node\_resource\_group\_name](#input\_node\_resource\_group\_name) | Name of the node resource group used by AKS cluster | `string` | n/a | yes |
| <a name="input_oidc_issuer_enabled"></a> [oidc\_issuer\_enabled](#input\_oidc\_issuer\_enabled) | Controls wether the oidc issuer should be enabled on the cluster. | `bool` | `false` | no |
| <a name="input_private_cluster_enabled"></a> [private\_cluster\_enabled](#input\_private\_cluster\_enabled) | Controls if the cluster should use a private endpoint for its API server. | `bool` | `false` | no |
| <a name="input_private_cluster_public_fqdn_enabled"></a> [private\_cluster\_public\_fqdn\_enabled](#input\_private\_cluster\_public\_fqdn\_enabled) | (Optional) Specifies whether a Public FQDN for this Private Cluster should be added. Defaults to false | `bool` | `false` | no |
| <a name="input_private_dns_zone_id"></a> [private\_dns\_zone\_id](#input\_private\_dns\_zone\_id) | Private dns zone ID to use for private cluster. Should only be set if `private_cluster_enabled` is true but `create_dns_zones` is false | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Resource group to use for module deployment. | `string` | n/a | yes |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | Azure Kubernetes cluster tier | `string` | `"Free"` | no |
| <a name="input_subnet_address_prefix"></a> [subnet\_address\_prefix](#input\_subnet\_address\_prefix) | Address prefix for the subnet creared by this module | `string` | `null` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Name of the subnet created by this module. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags which will be added to the resource group and its resources. | `map(string)` | `{}` | no |
| <a name="input_user_managed_nat_gateway_resource_id"></a> [user\_managed\_nat\_gateway\_resource\_id](#input\_user\_managed\_nat\_gateway\_resource\_id) | Must be set if network\_profile.outbound\_type is set to userAssignedNATGateway. Is used to associate new AKS subnets with a pre-exsiting NAT gateway. | `string` | `null` | no |
| <a name="input_virtual_network_id"></a> [virtual\_network\_id](#input\_virtual\_network\_id) | ID of the virtual network used for the cluster | `string` | `null` | no |
| <a name="input_vnet_integration_enabled"></a> [vnet\_integration\_enabled](#input\_vnet\_integration\_enabled) | (Optional) Should API Server VNet Integration be enabled? | `bool` | `false` | no |
| <a name="input_workload_identity_enabled"></a> [workload\_identity\_enabled](#input\_workload\_identity\_enabled) | Wether workload identity should be enabled or not | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks_user_assigned_identity_client_id"></a> [aks\_user\_assigned\_identity\_client\_id](#output\_aks\_user\_assigned\_identity\_client\_id) | n/a |
| <a name="output_aks_user_assigned_identity_id"></a> [aks\_user\_assigned\_identity\_id](#output\_aks\_user\_assigned\_identity\_id) | n/a |
| <a name="output_aks_user_assigned_identity_principal_id"></a> [aks\_user\_assigned\_identity\_principal\_id](#output\_aks\_user\_assigned\_identity\_principal\_id) | n/a |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | n/a |
| <a name="output_kubelet_user_assigned_identity_client_id"></a> [kubelet\_user\_assigned\_identity\_client\_id](#output\_kubelet\_user\_assigned\_identity\_client\_id) | n/a |
| <a name="output_kubelet_user_assigned_identity_id"></a> [kubelet\_user\_assigned\_identity\_id](#output\_kubelet\_user\_assigned\_identity\_id) | n/a |
| <a name="output_kubelet_user_assigned_identity_principal_id"></a> [kubelet\_user\_assigned\_identity\_principal\_id](#output\_kubelet\_user\_assigned\_identity\_principal\_id) | n/a |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | n/a |
| <a name="output_public_key"></a> [public\_key](#output\_public\_key) | n/a |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | n/a |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | n/a |
| <a name="output_subnet_id"></a> [subnet\_id](#output\_subnet\_id) | n/a |
<!-- END_TF_DOCS -->
