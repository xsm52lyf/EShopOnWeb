aws_primary_region = "us-east-1"

aws_vpc_cidr        = "10.3.0.0/16"
aws_az_count        = 2
aws_public_subnets  = ["10.3.0.0/24", "10.3.1.0/24"]
aws_private_subnets = ["10.3.16.0/20", "10.3.32.0/20"]

# 数据库
aws_db_name                    = "corecommerce_staging"
aws_db_username                = "staging_admin"
aws_db_instance_class          = "db.r5.xlarge"
aws_db_backup_retention_days   = 30
aws_enable_secret_rotation     = true
aws_secret_rotation_days       = 30
aws_db_multi_az                = true

aws_redis_node_type = "cache.m5.xlarge"
aws_redis_multi_az  = true

# EKS
aws_eks_cluster_name         = "corecommerce-staging-cluster"
aws_eks_node_min_size        = 3
aws_eks_node_max_size        = 12
aws_eks_node_desired_size    = 5
aws_eks_node_instance_types  = ["t3.medium", "t3.large"]

aws_ecr_repository_name = "corecommerce-web"

# DMS
aws_dms_instance_class     = "dms.r5.xlarge"
aws_dms_allocated_storage  = 100
aws_dms_engine_version     = "3.5.2"
aws_dms_maintenance_window = "sun:03:00-sun:05:00"

# ------------------------------------------
# Azure 灾备中心配置
# ------------------------------------------

azure_dr_location = "eastasia"

azure_vnet_address_space  = ["10.13.0.0/16"]
azure_aks_subnets         = ["10.13.16.0/20", "10.13.32.0/20"]
azure_db_subnets          = ["10.13.48.0/24"]
azure_app_gateway_subnets = ["10.13.64.0/24"]

azure_kv_enable_purge_protection    = true
azure_kv_soft_delete_retention_days = 90

azure_aks_cluster_name       = "corecommerce-staging-dr-cluster"
azure_aks_kubernetes_version = "1.28"
azure_aks_node_count         = 3
azure_aks_node_vm_size       = "Standard_D4s_v5"
azure_aks_min_node_count     = 3
azure_aks_max_node_count     = 10

azure_sql_admin_username = "psqladmin"
azure_sql_sku_name       = "GP_Standard_D8s_v3"
azure_sql_storage_mb     = 262144  # 256 GB

azure_redis_sku_name = "Premium"
azure_redis_capacity = 2

tags = {
  Project       = "CoreCommerce"
  Environment   = "staging"
  Owner         = "PlatformEngineering"
  CostCenter    = "ECommerce-001"
  SecurityLevel = "High"
  Purpose       = "pre-production-validation"
  DR-Enabled    = "true"
  IaC-Tool      = "Terraform"
}