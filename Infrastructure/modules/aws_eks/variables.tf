variable "environment" {
  description = "The deployment environment. e.g., dev, test， perf , Staging , production"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "corecommerce-cluster"
}

variable "vpc_id" {
  description = "ID of the VPC to deploy the cluster into"
  type        = string
}

variable "private_subnet_ids" {
  description = "A list of private subnet IDs for the worker nodes"
  type        = list(string)
}

variable "node_group_min_size" {
  description = "Minimum size of the node group"
  type        = number
  default     = 2
}

variable "node_group_max_size" {
  description = "Maximum size of the node group"
  type        = number
  default     = 5
}

variable "node_group_desired_size" {
  description = "Desired size of the node group"
  type        = number
  default     = 2
}

variable "node_instance_types" {
  description = "EC2 instance types for the worker nodes"
  type        = list(string)
  default     = ["t3.medium"]
}