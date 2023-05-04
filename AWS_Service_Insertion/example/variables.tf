variable "aws_profile" {
  default = "fullstack-apps"
}
variable "aws_region" {
  default = "us-west-1"
}

variable "deregistration_delay" {
  description = "See the `aws` provider [documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#deregistration_delay)."
  default     = null
  type        = number
}

variable "health_check_enabled" {
  description = "See the `aws` provider [documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#health_check)."
  default     = null
  type        = bool
}

variable "health_check_interval" {
  description = "Approximate amount of time, in seconds, between health checks of an individual target. Minimum 5 and maximum 300 seconds."
  default     = 5 # override the AWS default of 10 seconds
  type        = number
}

variable "health_check_matcher" {
  description = "See the `aws` provider [documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#health_check)."
  default     = null
  type        = string
}

variable "health_check_path" {
  description = "See the `aws` provider [documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group#health_check)."
  default     = null
  type        = string
}

variable "health_check_port" {
  description = "The port on a target to which the load balancer sends health checks."
  default     = 80
  type        = number
}

variable "health_check_protocol" {
  description = "Protocol to use when communicating with `health_check_port`. Either HTTP, HTTPS, or TCP."
  default     = "TCP"
  type        = string
}

variable "health_check_timeout" {
  description = "After how many seconds to consider the health check as failed without a response. Minimum 2 and maximum 120. Required to be `null` when `health_check_protocol` is TCP."
  default     = null
  type        = number
}

variable "healthy_threshold" {
  description = "The number of successful health checks required before an unhealthy target becomes healthy. Minimum 2 and maximum 10."
  default     = 3
  type        = number
}

variable "unhealthy_threshold" {
  description = "The number of failed health checks required before a healthy target becomes unhealthy. Minimum 2 and maximum 10."
  default     = 3
  type        = number
}