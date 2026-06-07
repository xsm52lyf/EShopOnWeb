variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group."
  type        = string
}

variable "cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
  default     = "corecommerce-aks"
}

variable "kubernetes_version" {
  description = "Kubernetes version."
  type        = string
  default     = "1.28"
}

variable "subnet_ids" {
  description = "List of subnet IDs for the AKS node pools."
  type        = list(string)
}

variable "node_count" {
  description = "Number of nodes in the default node pool."
  type        = number
  default     = 3
}

variable "node_vm_size" {
  description = "VM size for the AKS nodes."
  type        = string
  default     = "Standard_D4s_v5"
}

variable "min_node_count" {
  description = "Minimum node count for auto-scaling."
  type        = number
  default     = 3
}

variable "max_node_count" {
  description = "Maximum node count for auto-scaling."
  type        = number
  default     = 10
}

variable "key_vault_id" {
  description = "ID of the Azure Key Vault for secrets."
  type        = string
}

variable "service_cidr" {
  description = "CIDR for Kubernetes services."
  type        = string
  default     = "172.16.0.0/16"
}

variable "dns_service_ip" {
  description = "DNS service IP within the service CIDR."
  type        = string
  default     = "172.16.0.10"
}

variable "docker_bridge_cidr" {
  description = "Docker bridge CIDR."
  type        = string
  default     = "172.17.0.1/16"
}

variable "tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}