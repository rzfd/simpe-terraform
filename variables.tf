variable "aws_region" {
  type    = string
  default = "ap-south-1"
}
variable "vpc_name" {
  type    = string
  default = "demo_vpc"
}
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}
variable "private_subnets" {
  default = {
    "private_subnet_1" = 0
    "private_subnet_2" = 1
  }
}
variable "public_subnets" {
  default = {
    "public_subnet_1" = 1
    "public_subnet_2" = 2
  }
}
variable "variable_sub_cidr" {
  description = "CIDR block for the variables subnet"
  type        = string
  default     = "10.0.202.0/24"
}
variable "variable_sub_az" {
  description = "Avalaibality Zone used Variables subnet"
  type        = string
  default     = "ap-south-1a"
}
variable "variable_sub_auto_ip" {
  description = "Set Automatic variables for subnet"
  type        = bool
  default     = true
}
variable "environment" {
  description = "Environment for development"
  type        = string
  default     = "def"
}