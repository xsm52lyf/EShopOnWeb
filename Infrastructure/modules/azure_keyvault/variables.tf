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

variable "tenant_id" {
  description = "Azure AD tenant ID."
  type        = string
}

variable "object_ids" {
  description = "List of object IDs to grant access to Key Vault (e.g., AKS managed identity, DevOps SPN)."
  type        = list(string)
  default     = []
}

variable "enable_purge_protection" {
  description = "Enable purge protection for Key Vault."
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "Soft delete retention days."
  type        = number
  default     = 90
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}