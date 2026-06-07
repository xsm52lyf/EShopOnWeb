terraform {
  required_version = ">= 1.3"

  backend "s3" {
    bucket         = "corecommerce-terraform-state-test"
    key            = "corecommerce/test/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "alias/corecommerce-test-state"
    dynamodb_table = "terraform-state-lock-test"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_primary_region

  default_tags {
    tags = local.common_tags
  }
}

locals {
  environment = "test"
  common_tags = merge(var.tags, {
    Environment = "test"
  })
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

module "aws_security" {
  source = "../../modules/aws_security"

  environment     = local.environment
  db_username     = var.aws_db_username
  db_name         = var.aws_db_name
  enable_rotation = var.aws_enable_secret_rotation
  rotation_days   = var.aws_secret_rotation_days
  tags            = local.common_tags
}

module "aws_network" {
  source = "../../modules/aws_network"

  environment        = local.environment
  vpc_cidr           = var.aws_vpc_cidr
  azs                = slice(data.aws_availability_zones.available.names, 0, var.aws_az_count)
  public_subnets     = var.aws_public_subnets
  private_subnets    = var.aws_private_subnets
  enable_nat_gateway = false  # 测试环境关闭 NAT 网关以节省成本
  tags               = local.common_tags
}

module "aws_eks" {
  source = "../../modules/aws_eks"

  environment             = local.environment
  cluster_name            = var.aws_eks_cluster_name
  vpc_id                  = module.aws_network.vpc_id
  private_subnet_ids      = module.aws_network.private_subnet_ids
  node_group_min_size     = var.aws_eks_node_min_size
  node_group_max_size     = var.aws_eks_node_max_size
  node_group_desired_size = var.aws_eks_node_desired_size
  node_instance_types     = var.aws_eks_node_instance_types
  tags                    = local.common_tags
}

module "aws_data" {
  source = "../../modules/aws_data"

  environment             = local.environment
  vpc_id                  = module.aws_network.vpc_id
  private_subnet_ids      = module.aws_network.private_subnet_ids
  db_name                 = var.aws_db_name
  db_instance_class       = var.aws_db_instance_class
  redis_node_type         = var.aws_redis_node_type
  enable_multi_az         = var.aws_db_multi_az
  backup_retention_period = var.aws_db_backup_retention_days
  kms_key_arn             = module.aws_security.kms_key_arn
  db_master_secret_arn    = module.aws_security.db_master_secret_arn
  redis_auth_secret_arn   = module.aws_security.redis_auth_secret_arn
  tags                    = local.common_tags
}

module "aws_ecr" {
  source = "../../modules/aws_ecr"

  repository_name = var.aws_ecr_repository_name
  kms_key_arn     = module.aws_security.kms_key_arn
  tags            = local.common_tags
}