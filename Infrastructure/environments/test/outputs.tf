output "eks_cluster_name" {
  description = "EKS cluster name."
  value       = module.aws_eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint."
  value       = module.aws_eks.cluster_endpoint
  sensitive   = true
}

output "rds_endpoint" {
  description = "RDS endpoint."
  value       = module.aws_data.rds_endpoint
  sensitive   = true
}

output "redis_endpoint" {
  description = "Redis endpoint."
  value       = module.aws_data.redis_endpoint
  sensitive   = true
}

output "ecr_repository_url" {
  description = "ECR repository URL."
  value       = module.aws_ecr.repository_url
}

output "environment_info" {
  description = "Environment summary."
  value = {
    environment = "test"
    region      = var.aws_primary_region
    cost_mode   = "lightweight (no NAT, single AZ)"
    purpose     = "Integration and automated testing"
  }
}