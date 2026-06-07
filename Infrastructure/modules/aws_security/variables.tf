variable "environment" {
  description = "Deployment environment name."
  type        = string
}

variable "db_username" {
  description = "Database master username."
  type        = string
  default     = "corecommerce_admin"
}

variable "db_name" {
  description = "Database name."
  type        = string
  default     = "corecommerce"
}

variable "enable_rotation" {
  description = "Enable automatic password rotation via Lambda. Best practice for production."
  type        = bool
  default     = false
}

variable "rotation_days" {
  description = "Number of days between automatic password rotations."
  type        = number
  default     = 30
}

variable "tags" {
  description = "A map of tags to add to all resources."
  type        = map(string)
  default     = {}
}