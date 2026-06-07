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

resource "aws_kms_key" "main" {
  description             = "CoreCommerce ${var.environment} master encryption key"
  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_key.json

  tags = merge(var.tags, {
    Name = "corecommerce-${var.environment}-kms-key"
  })
}

resource "aws_kms_alias" "main" {
  name          = "alias/corecommerce-${var.environment}"
  target_key_id = aws_kms_key.main.key_id
}

data "aws_iam_policy_document" "kms_key" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow Secrets Manager to use the key"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["secretsmanager.amazonaws.com"]
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
      "kms:DescribeKey"
    ]
    resources = ["*"]
  }
}

resource "random_password" "db_master" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_special      = 4
  min_upper        = 2
  min_lower        = 2
  min_numeric      = 2
}

resource "random_password" "redis_auth" {
  length  = 32
  special = false
}

resource "random_password" "app_secret" {
  length  = 64
  special = true
}

resource "aws_secretsmanager_secret" "db_master" {
  name                    = "corecommerce/${var.environment}/db-master-password"
  kms_key_id              = aws_kms_key.main.key_id
  recovery_window_in_days = 0

  tags = merge(var.tags, {
    Name = "corecommerce-${var.environment}-db-secret"
  })
}

resource "aws_secretsmanager_secret_version" "db_master" {
  secret_id     = aws_secretsmanager_secret.db_master.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db_master.result
    engine   = "postgres"
    host     = ""
    port     = 5432
    dbname   = var.db_name
  })
}

resource "aws_secretsmanager_secret" "redis_auth" {
  name                    = "corecommerce/${var.environment}/redis-auth"
  kms_key_id              = aws_kms_key.main.key_id
  recovery_window_in_days = 0

  tags = merge(var.tags, {
    Name = "corecommerce-${var.environment}-redis-secret"
  })
}

resource "aws_secretsmanager_secret_version" "redis_auth" {
  secret_id     = aws_secretsmanager_secret.redis_auth.id
  secret_string = jsonencode({
    auth_token = random_password.redis_auth.result
    endpoint   = "" 
    port       = 6379
  })
}

resource "aws_secretsmanager_secret" "app_config" {
  name                    = "corecommerce/${var.environment}/app-config"
  kms_key_id              = aws_kms_key.main.key_id
  recovery_window_in_days = 0

  tags = merge(var.tags, {
    Name = "corecommerce-${var.environment}-app-config"
  })
}

resource "aws_secretsmanager_secret_version" "app_config" {
  secret_id = aws_secretsmanager_secret.app_config.id
  secret_string = jsonencode({
    jwt_signing_key      = random_password.app_secret.result
    api_base_url         = "https://api.corecommerce-${var.environment}.yourdomain.com"
    allowed_cors_origins = "https://corecommerce-${var.environment}.yourdomain.com"
  })
}

data "aws_caller_identity" "current" {}

output "kms_key_arn" {
  description = "ARN of the main KMS encryption key."
  value       = aws_kms_key.main.arn
}

output "db_master_secret_arn" {
  description = "ARN of the DB master password secret in Secrets Manager."
  value       = aws_secretsmanager_secret.db_master.arn
}

output "redis_auth_secret_arn" {
  description = "ARN of the Redis auth token secret."
  value       = aws_secretsmanager_secret.redis_auth.arn
}

output "app_config_secret_arn" {
  description = "ARN of the global application configuration secret."
  value       = aws_secretsmanager_secret.app_config.arn
}