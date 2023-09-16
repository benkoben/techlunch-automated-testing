output "subnet_id" {
  value = azurerm_subnet.aks.id
}

output "aks_user_assigned_identity_id" {
  value = var.aks_identity_type == "UserAssigned" ? azurerm_user_assigned_identity.aks[0].id : null
}

output "aks_user_assigned_identity_client_id" {
  value = var.aks_identity_type == "UserAssigned" ? azurerm_user_assigned_identity.aks[0].client_id : null
}

output "aks_user_assigned_identity_principal_id" {
  value = var.aks_identity_type == "UserAssigned" ? azurerm_user_assigned_identity.aks[0].principal_id : null
}

output "kubelet_user_assigned_identity_id" {
  value = var.aks_identity_type == "UserAssigned" ? azurerm_user_assigned_identity.kubelet[0].id : null
}

output "kubelet_user_assigned_identity_client_id" {
  value = var.aks_identity_type == "UserAssigned" ? azurerm_user_assigned_identity.kubelet[0].client_id : null
}

output "kubelet_user_assigned_identity_principal_id" {
  value = var.aks_identity_type == "UserAssigned" ? azurerm_user_assigned_identity.kubelet[0].principal_id : null
}

output "oidc_issuer_url" {
  value = var.oidc_issuer_enabled ? azurerm_kubernetes_cluster.aks.oidc_issuer_url : null
}

output "public_key" {
  value = tls_private_key.aks.public_key_openssh
}

output "resource_group_name" {
  value = azurerm_resource_group.aks.name
}

output "resource_group_id" {
  value = azurerm_resource_group.aks.id
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}
