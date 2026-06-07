variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "subnet_ids" {
  description = "Subnet IDs for database services."
  type        = list(string)
}

variable "sql_admin_username" {
  description = "PostgreSQL admin username."
  type        = string
  default     = "psqladmin"
}

variable "sql_admin_password" {
  description = "PostgreSQL admin password (fetched from AWS Secrets Manager in live)."
  type        = string
  sensitive   = true
}

variable "sql_sku_name" {
  description = "SKU for PostgreSQL Flexible Server."
  type        = string
  default     = "GP_Standard_D4s_v3"
}

variable "sql_storage_mb" {
  description = "Storage size in MB for PostgreSQL."
  type        = number
  default     = 131072  # 128 GB
}

variable "redis_sku_name" {
  description = "SKU for Azure Cache for Redis."
  type        = string
  default     = "Premium"
}

variable "redis_capacity" {
  description = "Capacity for Redis."
  type        = number
  default     = 2
}

variable "redis_family" {
  description = "Family for Redis."
  type        = string
  default     = "P"
}

variable "key_vault_id" {
  description = "Key Vault ID for storing generated secrets."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}