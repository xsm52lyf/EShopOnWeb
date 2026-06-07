terraform {
  required_version = ">= 1.3"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_private_dns_zone" "postgres" {
  name                = "privatelink.postgres.database.azure.com"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "postgres" {
  name                  = "psql-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.postgres.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.subnet_ids[0]  # Assuming subnet_ids are from the same VNet
  registration_enabled  = false
}

resource "azurerm_postgresql_flexible_server" "main" {
  name                   = "psql-corecommerce-${var.environment}-dr"
  resource_group_name    = var.resource_group_name
  location               = var.location
  version                = "16"
  administrator_login    = var.sql_admin_username
  administrator_password = var.sql_admin_password
  zone                   = "1"

  storage_mb    = var.sql_storage_mb
  sku_name      = var.sql_sku_name
  storage_tier  = "P30"

  backup_retention_days = 35
  geo_redundant_backup_enabled = true

  delegated_subnet_id           = var.subnet_ids[0]
  private_dns_zone_id           = azurerm_private_dns_zone.postgres.id
  public_network_access_enabled = false

  high_availability {
    mode                      = "ZoneRedundant"
    standby_availability_zone = "2"
  }

  # 数据加密
  customer_managed_key {
    key_vault_key_id                  = "${var.key_vault_id}/keys/db-encryption"
    primary_user_assigned_identity_id = var.managed_identity_id
  }

  tags = var.tags
}

resource "azurerm_postgresql_flexible_server_database" "corecommerce" {
  name      = "corecommerce"
  server_id = azurerm_postgresql_flexible_server.main.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

resource "azurerm_private_dns_zone" "redis" {
  name                = "privatelink.redis.cache.windows.net"
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_dns_zone_virtual_network_link" "redis" {
  name                  = "redis-vnet-link"
  private_dns_zone_name = azurerm_private_dns_zone.redis.name
  resource_group_name   = var.resource_group_name
  virtual_network_id    = var.subnet_ids[0]
  registration_enabled  = false
}

resource "azurerm_redis_cache" "main" {
  name                = "redis-corecommerce-${var.environment}-dr"
  location            = var.location
  resource_group_name = var.resource_group_name
  capacity            = var.redis_capacity
  family              = var.redis_family
  sku_name            = var.redis_sku_name
  redis_version       = "6"
  minimum_tls_version = "1.2"

  subnet_id                   = var.subnet_ids[min(1, length(var.subnet_ids) - 1)]
  private_static_ip_address   = "10.1.48.10"

  redis_configuration {
    maxmemory_policy = "volatile-lru"
    maxmemory_reserved = 642
    maxmemory_delta    = 642
    rdb_backup_enabled = true
    rdb_backup_frequency = 60
    rdb_backup_max_snapshot_count = 1
    aof_backup_enabled = true

    enable_authentication = true
  }

  identity {
    type = "SystemAssigned"
  }

  customer_managed_key_enabled = true

  patch_schedule {
    day_of_week    = "Sunday"
    start_hour_utc = 2
  }

  tags = var.tags
}

resource "azurerm_key_vault_secret" "postgres_connection_string" {
  name         = "corecommerce-db-connection-string"
  value        = "Server=${azurerm_postgresql_flexible_server.main.fqdn};Database=corecommerce;Port=5432;User Id=${var.sql_admin_username};Password=${var.sql_admin_password};Ssl Mode=Require;"
  key_vault_id = var.key_vault_id
  content_type = "text/plain"

  tags = var.tags
}

resource "azurerm_key_vault_secret" "redis_connection_string" {
  name         = "corecommerce-redis-connection-string"
  value        = azurerm_redis_cache.main.primary_connection_string
  key_vault_id = var.key_vault_id
  content_type = "text/plain"

  tags = var.tags
}