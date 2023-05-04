resource "aws_security_group" "firewall_sg" {
  name        = "Firewall_SG"
  description = "Firewall_SG"
  vpc_id      = var.vpc_id

  ingress {
    description      = "SSH from My IP"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["76.126.18.128/32"]
  }

  ingress {
    description      = "All traffic from private networks"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "Firewall_VM"
  }
}

data "aws_ami" "pan_vm" {
  most_recent = true

  filter {
    name   = "name"
    values = ["PA-VM-AWS-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "product-code"
    values = [lookup(var.license_type_map, var.license_type, null)]
  }
}

## This is for deploying PAN VM
resource "aws_network_interface" "fw_untrust_interface_az" {
  count = 2
  subnet_id = count.index == 0 ? var.untrust_subnet_az1 : var.untrust_subnet_az2
  security_groups = [aws_security_group.firewall_sg.id]
  source_dest_check = false
  tags = { Name = "fw_untrust_interface_az${count.index + 1}"}
}
resource "aws_network_interface" "fw_mgmt_interface_az" {
  count = 2
  subnet_id = count.index == 0 ? var.mgmt_subnet_az1 : var.mgmt_subnet_az2
  security_groups = [aws_security_group.firewall_sg.id]
  source_dest_check = false
  tags = { Name = "fw_mgmt_interface_az${count.index + 1}"}
}
resource "aws_network_interface" "fw_trust_interface_az" {
  count = 2
  subnet_id = count.index ==0 ? var.trust_subnet_az1 : var.trust_subnet_az2
  security_groups = [aws_security_group.firewall_sg.id]
  source_dest_check = false
  tags = { Name = "fw_trust_interface_az${count.index + 1}"}
}
resource "aws_eip" "PAN_untrust_EIP" {
  count = 2
  vpc   = true
  network_interface   = aws_network_interface.fw_untrust_interface_az[count.index].id
}
resource "aws_eip" "PAN_mgmt_EIP" {
  count = 2
  vpc   = true
  network_interface   = aws_network_interface.fw_mgmt_interface_az[count.index].id
}

resource "aws_instance" "PAN_Instance" {
  count = 2
  disable_api_termination = false
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized = true
  ami = data.aws_ami.pan_vm.id
  instance_type = "m5.2xlarge"
  tags = { Name = "PAN_Firewall_AZ${count.index+1}"  }
  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp2"
    delete_on_termination = true
    volume_size = 60
  }
  key_name = var.fw_key_pair
  monitoring = false
  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.fw_mgmt_interface_az[count.index].id
}
user_data = <<EOF
mgmt-interface-swap=enable
plugin-op-commands=aws-gwlb-inspect:enable
sudo reboot
EOF
}

resource "aws_network_interface_attachment" "untrust" {
  count = 2
  instance_id          = aws_instance.PAN_Instance[count.index].id
  network_interface_id = aws_network_interface.fw_untrust_interface_az[count.index].id
  device_index         = 1
}

resource "aws_network_interface_attachment" "trust" {
  count = 2
  instance_id          = aws_instance.PAN_Instance[count.index].id
  network_interface_id = aws_network_interface.fw_trust_interface_az[count.index].id
  device_index         = 2
}

output "PAN_mgmt_EIP" {
  value = aws_eip.PAN_mgmt_EIP.*.public_ip
}

output "PAN_untrust_EIP" {
  value = aws_eip.PAN_untrust_EIP.*.public_ip
}

output "PAN_instance_Id" {
  value = aws_instance.PAN_Instance.*.id
}

output "PAN_trust_ip1" {
  #value = aws_network_interface.fw_trust_interface_az.*.private_ip[0]
  value = length(aws_network_interface.fw_trust_interface_az) > 0 ? aws_network_interface.fw_trust_interface_az[0].private_ip : null
}

output "PAN_trust_ip2" {
  #value = aws_network_interface.fw_trust_interface_az.*.private_ip[1]
  value = length(aws_network_interface.fw_trust_interface_az) > 1 ? aws_network_interface.fw_trust_interface_az[1].private_ip : null

}
