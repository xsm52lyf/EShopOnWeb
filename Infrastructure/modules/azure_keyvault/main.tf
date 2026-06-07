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

resource "random_string" "kv_suffix" {
  length  = 6
  special = false
  upper   = false
}

resource "azurerm_key_vault" "main" {
  name                       = "kv-corecommerce-${var.environment}-${random_string.kv_suffix.result}"
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = var.tenant_id
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.enable_purge_protection
  sku_name                   = "premium"

  enable_rbac_authorization = true

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
    ip_rules       = []
    virtual_network_subnet_ids = []
  }

  tags = var.tags
}

resource "azurerm_key_vault_key" "db_encryption" {
  name         = "db-encryption"
  key_vault_id = azurerm_key_vault.main.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }
    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }

  tags = var.tags
}

resource "azurerm_key_vault_key" "redis_encryption" {
  name         = "redis-encryption"
  key_vault_id = azurerm_key_vault.main.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  rotation_policy {
    automatic {
      time_before_expiry = "P30D"
    }
    expire_after         = "P90D"
    notify_before_expiry = "P29D"
  }

  tags = var.tags
}

resource "azurerm_role_assignment" "key_vault_secrets_user" {
  count                = length(var.object_ids)
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.object_ids[count.index]
}

resource "azurerm_role_assignment" "key_vault_crypto_user" {
  count                = length(var.object_ids)
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Crypto User"
  principal_id         = var.object_ids[count.index]
}