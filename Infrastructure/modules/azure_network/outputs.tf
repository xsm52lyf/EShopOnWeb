output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group."
  value       = azurerm_resource_group.main.location
}

output "vnet_id" {
  description = "ID of the Virtual Network."
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the Virtual Network."
  value       = azurerm_virtual_network.main.name
}

output "aks_subnet_ids" {
  description = "List of AKS subnet IDs."
  value       = azurerm_subnet.aks[*].id
}

output "db_subnet_ids" {
  description = "List of database subnet IDs."
  value       = azurerm_subnet.db[*].id
}

output "app_gateway_subnet_ids" {
  description = "List of Application Gateway subnet IDs."
  value       = azurerm_subnet.app_gateway[*].id
}