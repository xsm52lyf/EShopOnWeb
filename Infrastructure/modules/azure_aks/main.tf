terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.47"
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_log_analytics_workspace" "aks" {
  name                = "log-aks-${var.environment}-dr"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

resource "azurerm_kubernetes_cluster" "main" {
  name                = "${var.cluster_name}-${var.environment}-dr"
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = "${var.cluster_name}-${var.environment}"
  kubernetes_version  = var.kubernetes_version

  azure_active_directory_role_based_access_control {
    managed            = true
    azure_rbac_enabled = true
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin      = "azure"
    network_policy      = "calico"
    service_cidr        = var.service_cidr
    dns_service_ip      = var.dns_service_ip
    docker_bridge_cidr  = var.docker_bridge_cidr
    outbound_type       = "loadBalancer"
    load_balancer_sku   = "standard"
  }

  default_node_pool {
    name                = "default"
    node_count          = var.node_count
    vm_size             = var.node_vm_size
    vnet_subnet_id      = var.subnet_ids[0]
    enable_auto_scaling = true
    min_count           = var.min_node_count
    max_count           = var.max_node_count
    type                = "VirtualMachineScaleSets"
    os_disk_size_gb     = 100
    os_disk_type        = "Ephemeral"

    node_labels = {
      "corecommerce.io/environment" = var.environment
      "corecommerce.io/role"        = "general"
      "corecommerce.io/dr"          = "true"
    }

    tags = var.tags
  }

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.aks.id
  }

  monitor_metrics {}

  tags = var.tags

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "cpu_intensive" {
  name                  = "cpuintensive"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.main.id
  vm_size               = "Standard_D8s_v5"
  node_count            = 2
  enable_auto_scaling   = true
  min_count             = 1
  max_count             = 5
  vnet_subnet_id        = var.subnet_ids[min(1, length(var.subnet_ids) - 1)]
  os_disk_type          = "Ephemeral"

  node_labels = {
    "corecommerce.io/workload" = "cpu-intensive"
  }

  node_taints = [
    "workload=cpu-intensive:NoSchedule"
  ]

  tags = var.tags
}

resource "azurerm_key_vault_access_policy" "aks" {
  key_vault_id = var.key_vault_id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_kubernetes_cluster.main.key_vault_secrets_provider[0].secret_identity[0].object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Recover",
    "Backup",
    "Restore"
  ]

  key_permissions = [
    "Get",
    "List",
    "UnwrapKey",
    "WrapKey"
  ]
}

resource "null_resource" "get_credentials" {
  provisioner "local-exec" {
    command = <<-EOT
      az aks get-credentials \
        --resource-group ${var.resource_group_name} \
        --name ${azurerm_kubernetes_cluster.main.name} \
        --overwrite-existing \
        --file ${path.module}/kubeconfig-${var.environment}
    EOT
  }

  depends_on = [azurerm_kubernetes_cluster.main]
}