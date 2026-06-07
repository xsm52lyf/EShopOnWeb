terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg-corecommerce-${var.environment}-dr"
  location = var.location

  tags = var.tags
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-corecommerce-${var.environment}-dr"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = var.vnet_address_space

  tags = var.tags
}

resource "azurerm_subnet" "aks" {
  count                = length(var.subnet_config.aks_subnets)
  name                 = "snet-aks-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_config.aks_subnets[count.index]]

  delegation {
    name = "aks-delegation"
    service_delegation {
      name    = "Microsoft.ContainerService/managedClusters"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_subnet" "db" {
  count                = length(var.subnet_config.db_subnets)
  name                 = "snet-db-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_config.db_subnets[count.index]]

  delegation {
    name = "db-delegation"
    service_delegation {
      name    = "Microsoft.Sql/managedInstances"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action"]
    }
  }
}

resource "azurerm_subnet" "app_gateway" {
  count                = length(var.subnet_config.app_gateway_subnets)
  name                 = "snet-appgateway-${count.index + 1}"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = [var.subnet_config.app_gateway_subnets[count.index]]
}

resource "azurerm_network_security_group" "aks" {
  name                = "nsg-aks-${var.environment}-dr"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowAzureLoadBalancer"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_network_security_group" "db" {
  name                = "nsg-db-${var.environment}-dr"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "AllowPostgresFromAKS"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefixes    = var.subnet_config.aks_subnets
    destination_address_prefix = "*"
  }

  tags = var.tags
}

resource "azurerm_subnet_network_security_group_association" "aks" {
  count                     = length(azurerm_subnet.aks)
  subnet_id                 = azurerm_subnet.aks[count.index].id
  network_security_group_id = azurerm_network_security_group.aks.id
}

resource "azurerm_subnet_network_security_group_association" "db" {
  count                     = length(azurerm_subnet.db)
  subnet_id                 = azurerm_subnet.db[count.index].id
  network_security_group_id = azurerm_network_security_group.db.id
}