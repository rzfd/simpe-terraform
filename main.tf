# Configure AWS Provider
provider "aws" {
  region = "ap-south-1"
}

# Retrieve Data From AWS Region Server
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

# reused data 
locals {
  team        = "api_manag_dev"
  application = "corp_api"
  server_name = "ec2-${var.environment}-${var.variable_sub_az}"
}

# Define VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr
  tags = {
    Name        = var.vpc_name
    Environment = "demo-environment"
    Terraform   = "true"
    # Implementing Data Source
    Region      = data.aws_region.current.name
  }
}

# Load Balancer for Network
resource "aws_lb" "test" {
  name               = "test-lb-tf"
  internal           = false
  load_balancer_type = "network"
  subnets            = [for subnet in aws_subnet.public_subnets : subnet.id]

  enable_deletion_protection = true

  tags = {
    Environment = "development"
  }
}

# Deploy Private Subnets
resource "aws_subnet" "private_subnets" {
  for_each          = var.private_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, each.value)
  availability_zone = tolist(data.aws_availability_zones.available.names)[each.value]
  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

# Deploy Public Subnets
resource "aws_subnet" "public_subnets" {
  for_each                = var.public_subnets
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, each.value + 100)
  availability_zone       = tolist(data.aws_availability_zones.available.names)[each.value]
  map_public_ip_on_launch = true
  tags = {
    Name      = each.key
    Terraform = "true"
  }
}

# Create Public Route tables
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name      = "demo_public_rtb"
    Terraform = "true"
  }
}

# Create Private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }
  tags = {
    Name      = "demo_private_rtb"
    Terraform = "true"
  }
}

# Create Route for Table Associations
resource "aws_route_table_association" "public" {
  depends_on     = [aws_subnet.public_subnets]
  route_table_id = aws_route_table.public_route_table.id
  for_each       = aws_subnet.public_subnets
  subnet_id      = each.value.id
}

resource "aws_route_table_association" "private" {
  depends_on     = [aws_route_table.private_route_table]
  route_table_id = aws_route_table.private_route_table.id
  for_each       = aws_subnet.private_subnets
  subnet_id      = each.value.id
}

# Create Internet Gateways
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "demo_igw"
  }
}

# Create EIP for NAT
resource "aws_eip" "nat_gateway_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "demo_igw_eip"
  }
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  depends_on    = [aws_subnet.public_subnets]
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_subnets["public_subnet_1"].id
  tags = {
    Name = "demo_nat_gateway"
  }
}

# Define aws AMI data resource
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-24.04-amd64-server-*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["008971666708"]
}

resource "aws_instance" "web" {
  ami                    = "ami-0aebec83a182ea7ea"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnets["public_subnet_1"].id
  vpc_security_group_ids = ["sg-0a1b147eb160d6204"]
  tags = {
    Name  = local.server_name
    Owner = local.team
    App   = local.application
  }
}

resource "aws_s3_bucket" "my-new-S3-bucket" {
  bucket = "my-new-bucket-terops12"
  tags = {
    Name    = "My S3 Bucket"
    Purpose = "Intro to Lab"
  }
}

resource "aws_s3_bucket_acl" "my-new-S3-bucket-acl" {
  bucket = aws_s3_bucket.my-new-S3-bucket.id
  acl    = "private"
}

resource "aws_security_group" "my-new-group_security" {
  name        = "web-server-inbound"
  description = "Inbound at tcp/443"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description = "Allow 443 from the internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "web-server-inbound"
    Purpose = "to manage server inbound"
  }
}

resource "aws_subnet" "variables_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.variable_sub_cidr
  availability_zone       = var.variable_sub_az
  map_public_ip_on_launch = var.variable_sub_auto_ip

  tags = {
    Name      = "sub-variables-${var.variable_sub_az}"
    Terraform = "true"
  }
}