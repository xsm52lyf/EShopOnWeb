output "aws_rds_endpoint" {
  description = "Primary RDS endpoint."
  value       = module.aws_data.rds_endpoint
  sensitive   = true
}

output "aws_redis_endpoint" {
  description = "Primary Redis endpoint."
  value       = module.aws_data.redis_endpoint
  sensitive   = true
}

output "aws_eks_cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = module.aws_eks.cluster_endpoint
  sensitive   = true
}

output "aws_ecr_repository_url" {
  description = "ECR repository URL."
  value       = module.aws_ecr.repository_url
}

output "azure_aks_cluster_name" {
  description = "AKS cluster name (DR)."
  value       = module.azure_dr_aks.cluster_name
}

output "azure_postgres_fqdn" {
  description = "Azure PostgreSQL server FQDN (DR)."
  value       = module.azure_dr_data.postgres_server_fqdn
  sensitive   = true
}

output "azure_redis_hostname" {
  description = "Azure Redis hostname (DR)."
  value       = module.azure_dr_data.redis_hostname
  sensitive   = true
}

output "dms_replication_task_arn" {
  description = "ARN of the DMS replication task."
  value       = module.aws_dms_dr.replication_task_arn
}

output "dms_replication_task_id" {
  description = "ID of the active replication task."
  value       = module.aws_dms_dr.replication_task_id
}

output "dms_replication_status" {
  description = "Current status of the DMS replication task."
  value       = module.aws_dms_dr.replication_task_status
}

output "dms_monitoring_command" {
  description = "AWS CLI command to check DMS task status."
  value       = "aws dms describe-replication-tasks --filters Name=replication-task-id,Values=${module.aws_dms_dr.replication_task_id} --region ${var.aws_primary_region}"
}