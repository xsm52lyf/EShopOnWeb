output "postgres_server_fqdn" {
  description = "FQDN of the PostgreSQL server."
  value       = azurerm_postgresql_flexible_server.main.fqdn
  sensitive   = true
}

output "postgres_server_id" {
  description = "ID of the PostgreSQL server."
  value       = azurerm_postgresql_flexible_server.main.id
}

output "redis_hostname" {
  description = "Hostname of Redis."
  value       = azurerm_redis_cache.main.hostname
  sensitive   = true
}

output "redis_ssl_port" {
  description = "SSL port of Redis."
  value       = azurerm_redis_cache.main.ssl_port
}

output "redis_primary_key" {
  description = "Primary access key for Redis."
  value       = azurerm_redis_cache.main.primary_access_key
  sensitive   = true
}