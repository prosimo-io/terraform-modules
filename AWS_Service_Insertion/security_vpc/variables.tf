variable "aws_profile" {
  type = string
}
variable "aws_region" {
  type = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.40.1.0/24"
}

variable "public_subnet_count" {
  description = "The number of subnets to create"
  type        = number
  default     = 4
}

variable "private_subnet_count" {
  description = "The number of subnets to create"
  type        = number
  default     = 2
}