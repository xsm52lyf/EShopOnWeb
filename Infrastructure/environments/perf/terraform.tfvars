# 区域
aws_primary_region = "us-east-1"

# 网络
aws_vpc_cidr        = "10.1.0.0/16"
aws_az_count        = 2
aws_public_subnets  = ["10.1.0.0/24", "10.1.1.0/24"]
aws_private_subnets = ["10.1.16.0/20", "10.1.32.0/20"]

# 数据库
aws_db_name                    = "corecommerce_perf"
aws_db_username                = "perf_admin"
aws_db_instance_class          = "db.r5.large"
aws_db_backup_retention_days   = 14
aws_enable_secret_rotation     = true
aws_secret_rotation_days       = 30
aws_db_multi_az                = true

# Redis
aws_redis_node_type = "cache.m5.large"
aws_redis_multi_az  = true

# EKS
aws_eks_cluster_name         = "corecommerce-perf-cluster"
aws_eks_node_min_size        = 3
aws_eks_node_max_size        = 10
aws_eks_node_desired_size    = 5
aws_eks_node_instance_types  = ["t3.medium", "t3.large"]

# ECR
aws_ecr_repository_name = "corecommerce-web"

# DMS
aws_dms_instance_class     = "dms.r5.large"
aws_dms_allocated_storage  = 50
aws_dms_engine_version     = "3.5.2"
aws_dms_maintenance_window = "sun:04:00-sun:06:00"

# ------------------------------------------
# Azure 灾备中心配置
# ------------------------------------------

# 区域
azure_dr_location = "eastasia"

# 网络
azure_vnet_address_space  = ["10.11.0.0/16"]
azure_aks_subnets         = ["10.11.16.0/20", "10.11.32.0/20"]
azure_db_subnets          = ["10.11.48.0/24"]
azure_app_gateway_subnets = ["10.11.64.0/24"]

# Key Vault
azure_kv_enable_purge_protection    = false
azure_kv_soft_delete_retention_days = 7

# AKS
azure_aks_cluster_name       = "corecommerce-perf-dr-cluster"
azure_aks_kubernetes_version = "1.28"
azure_aks_node_count         = 2
azure_aks_node_vm_size       = "Standard_D4s_v5"
azure_aks_min_node_count     = 2
azure_aks_max_node_count     = 6

# PostgreSQL
azure_sql_admin_username = "psqladmin"
azure_sql_sku_name       = "GP_Standard_D4s_v3"
azure_sql_storage_mb     = 131072  # 128 GB

# Redis
azure_redis_sku_name = "Premium"
azure_redis_capacity = 1

tags = {
  Project       = "CoreCommerce"
  Environment   = "perf"
  Owner         = "PerformanceEngineering"
  CostCenter    = "ECommerce-001"
  Purpose       = "performance-testing"
  DR-Enabled    = "true"
  IaC-Tool      = "Terraform"
}