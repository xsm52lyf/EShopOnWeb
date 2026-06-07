variable "environment" {
  description = "Environment name (e.g., dev, test， perf , Staging , production)"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "azs" {
  description = "A list of availability zones in the region"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnets" {
  description = "A list of CIDR blocks for private subnets"
  type        = list(string)
}

variable "public_subnets" {
  description = "A list of CIDR blocks for public subnets"
  type        = list(string)
}

variable "enable_nat_gateway" {
  description = "Should be true to create NAT gateways. Set to false for dev/test to save costs"
  type        = bool
  default     = false
}