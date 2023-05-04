module "security_vpc" {
  source = "../security_vpc"
  vpc_cidr_block = "10.40.1.0/24"
  aws_profile = var.aws_profile
  aws_region = var.aws_region
}

module "aws_glb" {
  source     = "../aws_gwlb"
  aws_profile = var.aws_profile
  aws_region = var.aws_region
  trust_subnet_az1 = module.security_vpc.trust_subnet_az1
  trust_subnet_az2 = module.security_vpc.trust_subnet_az2
  vpc_id = module.security_vpc.vpc_id
  PAN_instance_Ip1 = module.pan_vm_series.PAN_trust_ip1
  PAN_instance_Ip2 = module.pan_vm_series.PAN_trust_ip2
}

module "pan_vm_series" {
  source = "../pan_vm_series"
  aws_profile = var.aws_profile
  aws_region = var.aws_region
  vpc_id = module.security_vpc.vpc_id
  trust_subnet_az1 = module.security_vpc.trust_subnet_az1
  untrust_subnet_az1 = module.security_vpc.untrust_subnet_az1
  mgmt_subnet_az1 = module.security_vpc.mgmt_subnet_az1
  trust_subnet_az2 = module.security_vpc.trust_subnet_az2
  untrust_subnet_az2 = module.security_vpc.untrust_subnet_az2
  mgmt_subnet_az2 = module.security_vpc.mgmt_subnet_az2
  fw_key_pair = "us-west-1-salab"
}
