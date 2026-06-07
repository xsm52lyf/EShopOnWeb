# live/production/variables.tf
# 所有在 main.tf 中使用的变量声明

# =============================================================================
# AWS 变量
# =============================================================================
variable "aws_primary_region" {
  description = "AWS primary region."
  type        = string
}

variable "aws_vpc_cidr" { type = string }
variable "aws_az_count" { type = number }
variable "aws_public_subnets" { type = list(string) }
variable "aws_private_subnets" { type = list(string) }

variable "aws_db_name" { type = string }
variable "aws_db_username" { type = string }
variable "aws_db_instance_class" { type = string }
variable "aws_db_backup_retention_days" { type = number }
variable "aws_enable_secret_rotation" { type = bool }
variable "aws_secret_rotation_days" { type = number }

variable "aws_redis_node_type" { type = string }

variable "aws_eks_cluster_name" { type = string }
variable "aws_eks_node_min_size" { type = number }
variable "aws_eks_node_max_size" { type = number }
variable "aws_eks_node_desired_size" { type = number }
variable "aws_eks_node_instance_types" { type = list(string) }

variable "aws_ecr_repository_name" { type = string }

variable "aws_dms_instance_class" { type = string }
variable "aws_dms_allocated_storage" { type = number }
variable "aws_dms_engine_version" { type = string }
variable "aws_dms_maintenance_window" { type = string }

# =============================================================================
# Azure 变量
# =============================================================================
variable "azure_dr_location" { type = string }

variable "azure_vnet_address_space" { type = list(string) }
variable "azure_aks_subnets" { type = list(string) }
variable "azure_db_subnets" { type = list(string) }
variable "azure_app_gateway_subnets" { type = list(string) }

variable "azure_kv_enable_purge_protection" { type = bool }
variable "azure_kv_soft_delete_retention_days" { type = number }

variable "azure_aks_cluster_name" { type = string }
variable "azure_aks_kubernetes_version" { type = string }
variable "azure_aks_node_count" { type = number }
variable "azure_aks_node_vm_size" { type = string }
variable "azure_aks_min_node_count" { type = number }
variable "azure_aks_max_node_count" { type = number }

variable "azure_sql_admin_username" { type = string }
variable "azure_sql_sku_name" { type = string }
variable "azure_sql_storage_mb" { type = number }

variable "azure_redis_sku_name" { type = string }
variable "azure_redis_capacity" { type = number }

# =============================================================================
# 全局标签
# =============================================================================
variable "tags" {
  description = "Common tags applied to all resources."
  type        = map(string)
}