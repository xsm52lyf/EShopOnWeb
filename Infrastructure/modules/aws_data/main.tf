terraform {
  required_version = ">= 1.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

resource "aws_db_subnet_group" "main" {
  name       = "corecommerce-${var.environment}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name        = "corecommerce-${var.environment}-db-subnet-group"
    Environment = var.environment
  }
}

resource "aws_security_group" "rds" {
  name        = "corecommerce-${var.environment}-rds-sg"
  description = "Allow inbound Postgres traffic from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "corecommerce-${var.environment}-rds-sg"
    Environment = var.environment
  }
}

data "aws_secretsmanager_secret_version" "db_master" {
  secret_id = var.db_master_secret_arn
}

data "aws_secretsmanager_secret_version" "redis_auth" {
  secret_id = var.redis_auth_secret_arn
}

locals {
  db_master_credentials = jsondecode(data.aws_secretsmanager_secret_version.db_master.secret_string)
  redis_auth_credentials = jsondecode(data.aws_secretsmanager_secret_version.redis_auth.secret_string)
}

resource "aws_db_instance" "main" {
  identifier             = "corecommerce-${var.environment}"
  engine                 = "postgres"
  engine_version         = "16.1"
  instance_class         = var.db_instance_class

  username = local.db_master_credentials.username
  password = local.db_master_credentials.password

  allocated_storage       = 20
  max_allocated_storage   = 100
  storage_encrypted       = true
  kms_key_id              = var.kms_key_arn
  
  db_name                   = var.db_name
  db_subnet_group_name      = aws_db_subnet_group.main.name
  vpc_security_group_ids    = [aws_security_group.rds.id]
  multi_az                  = var.enable_multi_az
  backup_retention_period   = var.backup_retention_period
  skip_final_snapshot       = false
  final_snapshot_identifier = "corecommerce-${var.environment}-final-snapshot"
  deletion_protection       = var.environment == "production" ? true : false
  parameter_group_name      = aws_db_parameter_group.ssl_required.name

  tags = merge(var.tags, {
    Name = "corecommerce-${var.environment}-rds"
  })
}

resource "aws_db_parameter_group" "ssl_required" {
  name   = "corecommerce-${var.environment}-pg-ssl"
  family = "postgres16"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
    apply_method = "pending-reboot"
  }

  tags = var.tags
}

resource "aws_elasticache_subnet_group" "main" {
  name       = "corecommerce-${var.environment}-cache-subnet-group"
  subnet_ids = var.private_subnet_ids
}

resource "aws_security_group" "redis" {
  name        = "corecommerce-${var.environment}-redis-sg"
  description = "Allow inbound Redis traffic from EKS nodes"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "corecommerce-${var.environment}-redis-sg"
    Environment = var.environment
  }
}

resource "aws_elasticache_cluster" "main" {
  cluster_id           = "corecommerce-${var.environment}-redis"
  engine               = "redis"
  engine_version       = "7.1"
  node_type            = var.redis_node_type
  num_cache_nodes      = var.enable_multi_az ? 2 : 1
  parameter_group_name = "default.redis7"
  port                 = 6379

  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.redis.id]

  transit_encryption_enabled = true
  at_rest_encryption_enabled = true
  kms_key_id                = var.kms_key_arn

  auth_token = local.redis_auth_credentials.auth_token

  tags = merge(var.tags, {
    Name = "corecommerce-${var.environment}-redis"
  })
}

resource "aws_s3_bucket" "assets" {
  bucket = "corecommerce-assets-${var.environment}-${data.aws_caller_identity.current.account_id}"
  force_destroy = false

  tags = merge(var.tags, {
    Name = "corecommerce-assets-${var.environment}"
  })
}

resource "aws_s3_bucket_server_side_encryption_configuration" "assets" {
  bucket = aws_s3_bucket.assets.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = "aws:kms"
      kms_master_key_id = var.kms_key_arn
    }
  }
}

resource "aws_s3_bucket_public_access_block" "assets" {
  bucket = aws_s3_bucket.assets.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

data "aws_caller_identity" "current" {}

output "rds_endpoint" {
  value     = aws_db_instance.main.endpoint
  sensitive = true
}

output "redis_endpoint" {
  value     = aws_elasticache_cluster.main.cache_nodes[0].address
  sensitive = true
}

output "s3_bucket_arn" {
  value = aws_s3_bucket.assets.arn
}