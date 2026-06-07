variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "location" {
  description = "Azure region for disaster recovery."
  type        = string
  default     = "eastasia"
}

variable "vnet_address_space" {
  description = "Address space for the VNet."
  type        = list(string)
}

variable "subnet_config" {
  description = "Configuration for subnets: aks, db, and appgateway."
  type = object({
    aks_subnets         = list(string)
    db_subnets          = list(string)
    app_gateway_subnets = list(string)
  })
}

variable "tags" {
  description = "Common tags for all resources."
  type        = map(string)
  default     = {}
}