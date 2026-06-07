variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where database subnets will be created."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the DB subnet group."
  type        = list(string)
}

variable "db_name" {
  description = "Name for the database (within RDS instance)."
  type        = string
  default     = "corecommerce"
}

variable "db_username" {
  description = "Master username for the RDS instance."
  type        = string
  default     = "dbadmin"
}

variable "db_password" {
  description = "Master password for the RDS instance. Should be fetched from Secrets Manager in live envs."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "Instance class for RDS."
  type        = string
  default     = "db.t3.micro"
}

variable "redis_node_type" {
  description = "Node type for ElastiCache Redis."
  type        = string
  default     = "cache.t3.micro"
}

variable "enable_multi_az" {
  description = "Enable Multi-AZ deployment for RDS. Should be true for staging/prod."
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Number of days to retain backups."
  type        = number
  default     = 7
}

variable "db_master_secret_arn" {
  description = "ARN of the DB master secret in Secrets Manager."
  type        = string
}

variable "redis_auth_secret_arn" {
  description = "ARN of the Redis auth secret in Secrets Manager."
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key used for encryption at rest."
  type        = string
}

variable "tags" {
  description = "Common tags for all resources."
  type        = map(string)
  default     = {}
}