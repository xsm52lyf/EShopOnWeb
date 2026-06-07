output "replication_instance_arn" {
  description = "ARN of the DMS replication instance."
  value       = aws_dms_replication_instance.main.replication_instance_arn
}

output "source_endpoint_arn" {
  description = "ARN of the source endpoint."
  value       = aws_dms_endpoint.source.endpoint_arn
}

output "target_endpoint_arn" {
  description = "ARN of the target endpoint."
  value       = aws_dms_endpoint.target.endpoint_arn
}

output "replication_task_arn" {
  description = "ARN of the replication task."
  value       = aws_dms_replication_task.cdc.replication_task_arn
}

output "replication_task_id" {
  description = "ID of the replication task."
  value       = aws_dms_replication_task.cdc.replication_task_id
}

output "replication_task_status" {
  description = "Status of the replication task."
  value       = aws_dms_replication_task.cdc.replication_task_status
}