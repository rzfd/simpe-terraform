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
  description = "A map of private subnets"
  type        = map(number)
  default     = {
    private_subnet_1 = 0
    private_subnet_2 = 1
  }
}

variable "public_subnets" {
  description = "A map of public subnets"
  type        = map(number)
  default     = {
    public_subnet_1 = 0
    public_subnet_2 = 1
  }
}