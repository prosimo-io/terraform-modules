data "aws_availability_zones" "available" {}

resource "aws_vpc" "my_vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "Security_VPC"
  }
}

locals {
  public_subnet_count = 4
  private_subnet_count = 2

  public_subnets_cidr_blocks = [for i in range(local.public_subnet_count): cidrsubnet(var.vpc_cidr_block, local.public_subnet_count, i)]
  private_subnets_cidr_blocks = [for i in range(local.private_subnet_count): cidrsubnet(var.vpc_cidr_block, local.private_subnet_count, i + local.private_subnet_count)]

}

resource "aws_subnet" "public_subnet_az1" {
  count = 2
  cidr_block = element(local.public_subnets_cidr_blocks, count.index)
  vpc_id = aws_vpc.my_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "${count.index == 0 ? "mgmt" : "untrust"}-subnet-az1"
  }
}

resource "aws_subnet" "private_subnet_az1" {
  count = 1
  cidr_block = element(local.private_subnets_cidr_blocks, count.index)
  vpc_id = aws_vpc.my_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false
  tags = {
    Name = "trust-subnet-az1"
  }
}

resource "aws_subnet" "public_subnet_az2" {
  count = 2
  cidr_block = element(local.public_subnets_cidr_blocks, count.index+2)
  vpc_id = aws_vpc.my_vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name = "${count.index == 0 ? "mgmt" : "untrust"}-subnet-az2"
  }
}

resource "aws_subnet" "private_subnet_az2" {
  count = 1
  cidr_block = element(local.private_subnets_cidr_blocks, count.index+1)
  vpc_id = aws_vpc.my_vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false
  tags = {
    Name = "trust-subnet-az2"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_eip" "nat_eip" {
  vpc = true
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id      = aws_subnet.public_subnet_az1[0].id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.my_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }
}

resource "aws_route_table_association" "public_subnet_association_az1" {
  count = 2
  subnet_id = aws_subnet.public_subnet_az1[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_az2" {
  count = 2
  subnet_id = aws_subnet.public_subnet_az2[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_association" {
  count = 1
  subnet_id = aws_subnet.private_subnet_az1[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_association_az2" {
  count = 1
  subnet_id = aws_subnet.private_subnet_az2[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}


output "trust_subnet_az1" {
  value = aws_subnet.private_subnet_az1[0].id

}

output "trust_subnet_az2" {
  value = aws_subnet.private_subnet_az2[0].id

}

output "mgmt_subnet_az1" {
  value = aws_subnet.public_subnet_az1[0].id

}

output "mgmt_subnet_az2" {
  value = aws_subnet.public_subnet_az2[0].id

}

output "untrust_subnet_az1" {
  value = aws_subnet.public_subnet_az1[0].id

}

output "untrust_subnet_az2" {
  value = aws_subnet.public_subnet_az2[0].id

}

output "vpc_id"{
  value = aws_vpc.my_vpc.id
}