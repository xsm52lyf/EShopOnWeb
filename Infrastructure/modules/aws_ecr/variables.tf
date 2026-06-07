variable "repository_name" {
  description = "Name of the ECR repository."
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for ECR encryption."
  type        = string
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}