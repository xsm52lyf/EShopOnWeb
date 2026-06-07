# 区域
aws_primary_region = "us-east-1"

# 网络
aws_vpc_cidr        = "10.0.0.0/16"
aws_az_count        = 2
aws_public_subnets  = ["10.0.0.0/24", "10.0.1.0/24"]
aws_private_subnets = ["10.0.16.0/20", "10.0.32.0/20"]

# 数据库
aws_db_name                    = "corecommerce_dev"
aws_db_username                = "dev_admin"
aws_db_instance_class          = "db.t3.micro"
aws_db_backup_retention_days   = 1
aws_enable_secret_rotation     = false
aws_secret_rotation_days       = 0
aws_db_multi_az                = false

# Redis
aws_redis_node_type = "cache.t3.micro"
aws_redis_multi_az  = false

# EKS
aws_eks_cluster_name         = "corecommerce-dev-cluster"
aws_eks_node_min_size        = 1
aws_eks_node_max_size        = 3
aws_eks_node_desired_size    = 1
aws_eks_node_instance_types  = ["t3.small"]

# ECR
aws_ecr_repository_name = "corecommerce-web"

tags = {
  Project       = "CoreCommerce"
  Environment   = "dev"
  Owner         = "PlatformEngineering"
  CostCenter    = "ECommerce-001"
  AutoShutdown  = "true"
  Schedule      = "business-hours"
  IaC-Tool      = "Terraform"
}