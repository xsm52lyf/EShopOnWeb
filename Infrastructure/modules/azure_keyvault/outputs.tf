output "key_vault_id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "The URI of the Key Vault."
  value       = azurerm_key_vault.main.vault_uri
}

output "db_encryption_key_id" {
  description = "The ID of the database encryption key."
  value       = azurerm_key_vault_key.db_encryption.id
}

output "redis_encryption_key_id" {
  description = "The ID of the Redis encryption key."
  value       = azurerm_key_vault_key.redis_encryption.id
}

output "key_vault_name" {
  description = "The name of the Key Vault."
  value       = azurerm_key_vault.main.name
}