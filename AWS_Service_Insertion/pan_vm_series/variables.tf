variable "aws_profile" {
  type = string
}
variable "aws_region" {
  type = string
}

variable "vpc_id" {
  default = null
  type = string
}

variable "untrust_subnet_az1" {
  default = null
  type = string
}

variable "trust_subnet_az1" {
  default = null
  type = string
}

variable "mgmt_subnet_az1" {
  default = null
  type = string
}

variable "untrust_subnet_az2" {
  default = null
  type = string
}

variable "trust_subnet_az2" {
  default = null
  type = string
}

variable "mgmt_subnet_az2" {
  default = null
  type = string
}

variable "license_type_map" {
  description = "A map of bundle names to values"
  type        = map(string)
  default     = {
    "Bundle 1" = "e9yfvyj3uag5uo5j2hjikv74n"
    "Bundle 2" = "hd44w1chf26uv4p52cdynb2o"
    "BYOL"    = "6njl1pau431dv1qxipg63mvah"
  }
}

variable "license_type" {
  type = string
  default = "Bundle 2"
}

variable "fw_key_pair" {
  default = "service_insertion"
  
}