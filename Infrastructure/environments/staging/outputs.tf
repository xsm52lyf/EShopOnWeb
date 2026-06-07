output "aws_eks_cluster_name" { value = module.aws_eks.cluster_name }
output "aws_rds_endpoint" { value = module.aws_data.rds_endpoint; sensitive = true }
output "aws_redis_endpoint" { value = module.aws_data.redis_endpoint; sensitive = true }
output "azure_aks_cluster_name" { value = module.azure_dr_aks.cluster_name }
output "azure_postgres_fqdn" { value = module.azure_dr_data.postgres_server_fqdn; sensitive = true }
output "dms_replication_task_id" { value = module.aws_dms_dr.replication_task_id }
output "dms_replication_status" { value = module.aws_dms_dr.replication_task_status }
output "environment_info" {
  value = {
    environment = "staging"
    dr_enabled  = true
    purpose     = "Pre-production validation - mirrors production"
    note        = "Use for final sign-off before production deployment"
  }
}