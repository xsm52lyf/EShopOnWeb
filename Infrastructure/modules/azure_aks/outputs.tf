output "cluster_id" {
  description = "The ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.id
}

output "cluster_name" {
  description = "The name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.name
}

output "kube_config" {
  description = "Kubeconfig for the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "cluster_fqdn" {
  description = "FQDN of the AKS cluster."
  value       = azurerm_kubernetes_cluster.main.fqdn
}

output "cluster_identity_principal_id" {
  description = "Principal ID of the cluster managed identity."
  value       = azurerm_kubernetes_cluster.main.identity[0].principal_id
}

output "node_resource_group_name" {
  description = "Node resource group name."
  value       = azurerm_kubernetes_cluster.main.node_resource_group
}