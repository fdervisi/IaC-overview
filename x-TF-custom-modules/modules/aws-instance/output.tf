# AWS Instance Public
output "aws_ec2_public_ip" {
  value = aws_instance.ec2_linux.public_ip
}

# VPC id
output "vpc_id" {
  value = aws_vpc.vpc1.id
}

# Subnet id
output "subnet_id" {
  value = aws_subnet.subnet1.id
}