# 区域
aws_primary_region = "us-east-1"

# 网络
aws_vpc_cidr        = "10.2.0.0/16"
aws_az_count        = 2
aws_public_subnets  = ["10.2.0.0/24", "10.2.1.0/24"]
aws_private_subnets = ["10.2.16.0/20", "10.2.32.0/20"]

# 数据库
aws_db_name                    = "corecommerce"
aws_db_username                = "corecommerce_admin"
aws_db_instance_class          = "db.r5.xlarge"
aws_db_backup_retention_days   = 35
aws_enable_secret_rotation     = true
aws_secret_rotation_days       = 30

# Redis
aws_redis_node_type = "cache.m5.xlarge"

# EKS
aws_eks_cluster_name        = "corecommerce-cluster"
aws_eks_node_min_size       = 3
aws_eks_node_max_size       = 15
aws_eks_node_desired_size   = 5
aws_eks_node_instance_types = ["t3.medium", "t3.large"]

# ECR
aws_ecr_repository_name = "corecommerce-web"

# DMS
aws_dms_instance_class      = "dms.r5.xlarge"
aws_dms_allocated_storage   = 100
aws_dms_engine_version      = "3.5.2"
aws_dms_maintenance_window  = "sun:03:00-sun:05:00"

# ------------------------------------------
# Azure 灾备中心配置
# ------------------------------------------

# 区域
azure_dr_location = "eastasia"

# 网络
azure_vnet_address_space = ["10.1.0.0/16"]
azure_aks_subnets        = ["10.1.16.0/20", "10.1.32.0/20"]
azure_db_subnets         = ["10.1.48.0/24"]
azure_app_gateway_subnets = ["10.1.64.0/24"]

# Key Vault
azure_kv_enable_purge_protection     = true
azure_kv_soft_delete_retention_days  = 90

# AKS
azure_aks_cluster_name       = "corecommerce-dr-cluster"
azure_aks_kubernetes_version  = "1.28"
azure_aks_node_count         = 3
azure_aks_node_vm_size       = "Standard_D4s_v5"
azure_aks_min_node_count     = 3
azure_aks_max_node_count     = 10

# PostgreSQL
azure_sql_admin_username = "psqladmin"
azure_sql_sku_name       = "GP_Standard_D4s_v3"
azure_sql_storage_mb     = 262144  # 256 GB

# Redis
azure_redis_sku_name = "Premium"
azure_redis_capacity = 2

#DMS
aws_dms_instance_class      = "dms.r5.xlarge"
aws_dms_allocated_storage   = 100
aws_dms_engine_version      = "3.5.2"
aws_dms_maintenance_window  = "sun:03:00-sun:05:00"

tags = {
  Project       = "CoreCommerce"
  Owner         = "PlatformEngineering"
  CostCenter    = "ECommerce-001"
  SecurityLevel = "High"
  Compliance    = "PCI-DSS"
  DataClass     = "Confidential"
  DR-Enabled    = "true"
  IaC-Tool      = "Terraform"
}