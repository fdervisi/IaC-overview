## Input variable definitions
# AWS

variable "aws_region" {
  description = "Region of AWS"
  type        = string
}

variable "aws_vpc_name" {
  description = "Name of VPC"
  type        = string
}

variable "aws_vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_subnet_cidr" {
  description = "Subnet CIDR"
  type        = string
  default     = "10.0.1.0/24"
}

variable "aws_subnet_name" {
  description = "Name of Subnet"
  type        = string
}

variable "aws_ec2_name" {
  description = "Name of EC2"
  type        = string
}

variable "aws_ec2_instance_type" {
  description = "Instance Type of EC2"
  type        = string
  default     = "t3.micro"
}

variable "aws_ec2_key_pair_name" {
  description = "Key Pair Name for EC2"
  type        = string
}