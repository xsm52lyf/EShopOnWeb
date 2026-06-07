terraform {
  required_version = ">= 1.3"

  backend "s3" {
    bucket         = "corecommerce-terraform-state-staging"
    key            = "corecommerce/staging/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    kms_key_id     = "alias/corecommerce-staging-state"
    dynamodb_table = "terraform-state-lock-staging"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90"
    }
  }
}

provider "aws" {
  region = var.aws_primary_region
  alias  = "primary"

  default_tags {
    tags = local.common_tags
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
      recover_soft_deleted_key_vaults = true
    }
    resource_group {
      prevent_deletion_if_contains_resources = true
    }
  }
  alias = "dr"
}

locals {
  environment = "staging"
  common_tags = merge(var.tags, {
    Environment = "staging"
  })
}

data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}
data "azurerm_client_config" "current" {
  provider = azurerm.dr
}

module "aws_security" {
  source = "../../modules/aws_security"
  providers = { aws = aws.primary }

  environment     = local.environment
  db_username     = var.aws_db_username
  db_name         = var.aws_db_name
  enable_rotation = var.aws_enable_secret_rotation
  rotation_days   = var.aws_secret_rotation_days
  tags            = local.common_tags
}

module "aws_network" {
  source = "../../modules/aws_network"
  providers = { aws = aws.primary }

  environment        = local.environment
  vpc_cidr           = var.aws_vpc_cidr
  azs                = slice(data.aws_availability_zones.available.names, 0, var.aws_az_count)
  public_subnets     = var.aws_public_subnets
  private_subnets    = var.aws_private_subnets
  enable_nat_gateway = true
  tags               = local.common_tags
}

module "aws_eks" {
  source = "../../modules/aws_eks"
  providers = { aws = aws.primary }

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
  providers = { aws = aws.primary }

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
  providers = { aws = aws.primary }

  repository_name = var.aws_ecr_repository_name
  kms_key_arn     = module.aws_security.kms_key_arn
  tags            = local.common_tags
}

# =============================================================================
# Azure 灾备中心模块
# =============================================================================

module "azure_dr_network" {
  source = "../../modules/azure_network"
  providers = { azurerm = azurerm.dr }

  environment        = local.environment
  location           = var.azure_dr_location
  vnet_address_space = var.azure_vnet_address_space
  subnet_config = {
    aks_subnets         = var.azure_aks_subnets
    db_subnets          = var.azure_db_subnets
    app_gateway_subnets = var.azure_app_gateway_subnets
  }
  tags = local.common_tags
}

module "azure_dr_keyvault" {
  source = "../../modules/azure_keyvault"
  providers = { azurerm = azurerm.dr }

  environment                 = local.environment
  location                    = var.azure_dr_location
  resource_group_name         = module.azure_dr_network.resource_group_name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  object_ids                  = []
  enable_purge_protection     = var.azure_kv_enable_purge_protection
  soft_delete_retention_days  = var.azure_kv_soft_delete_retention_days
  tags                        = local.common_tags
}

module "azure_dr_aks" {
  source = "../../modules/azure_aks"
  providers = { azurerm = azurerm.dr }

  environment         = local.environment
  location            = var.azure_dr_location
  resource_group_name = module.azure_dr_network.resource_group_name
  cluster_name        = var.azure_aks_cluster_name
  kubernetes_version  = var.azure_aks_kubernetes_version
  subnet_ids          = module.azure_dr_network.aks_subnet_ids
  node_count          = var.azure_aks_node_count
  node_vm_size        = var.azure_aks_node_vm_size
  min_node_count      = var.azure_aks_min_node_count
  max_node_count      = var.azure_aks_max_node_count
  key_vault_id        = module.azure_dr_keyvault.key_vault_id
  tags                = local.common_tags
}

module "azure_dr_data" {
  source = "../../modules/azure_data"
  providers = { azurerm = azurerm.dr }

  environment         = local.environment
  location            = var.azure_dr_location
  resource_group_name = module.azure_dr_network.resource_group_name
  subnet_ids          = module.azure_dr_network.db_subnet_ids
  sql_admin_username  = var.azure_sql_admin_username
  sql_admin_password  = "TempStagingPassword123!"  # 实际应从 Secrets Manager 获取
  sql_sku_name        = var.azure_sql_sku_name
  sql_storage_mb      = var.azure_sql_storage_mb
  redis_sku_name      = var.azure_redis_sku_name
  redis_capacity      = var.azure_redis_capacity
  key_vault_id        = module.azure_dr_keyvault.key_vault_id
  tags                = local.common_tags
}

data "aws_secretsmanager_secret_version" "db_master" {
  provider   = aws.primary
  secret_id  = module.aws_security.db_master_secret_arn
}

locals {
  db_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_master.secret_string)
}

module "aws_dms_dr" {
  source = "../../modules/aws_dms"
  providers = { aws = aws.primary }

  environment                = local.environment
  replication_instance_id    = "corecommerce-staging-dr-replication"
  replication_instance_class = var.aws_dms_instance_class
  allocated_storage          = var.aws_dms_allocated_storage
  engine_version             = var.aws_dms_engine_version
  vpc_security_group_ids     = [module.aws_data.rds_security_group_id]
  subnet_ids                 = module.aws_network.private_subnet_ids
  multi_az                   = true
  publicly_accessible        = false
  preferred_maintenance_window = var.aws_dms_maintenance_window

  source_endpoint_id    = "corecommerce-staging-source"
  source_engine_name    = "postgres"
  source_server_name    = module.aws_data.rds_endpoint
  source_port           = 5432
  source_username       = local.db_credentials.username
  source_password       = local.db_credentials.password
  source_database_name  = var.aws_db_name
  source_ssl_mode       = "require"

  target_endpoint_id    = "corecommerce-staging-target-azure"
  target_engine_name    = "postgres"
  target_server_name    = module.azure_dr_data.postgres_server_fqdn
  target_port           = 5432
  target_username       = var.azure_sql_admin_username
  target_password       = local.db_credentials.password
  target_database_name  = "corecommerce"
  target_ssl_mode       = "require"

  replication_task_id = "corecommerce-staging-cdc-to-azure"
  migration_type      = "full-load-and-cdc"
  tags                = local.common_tags
}