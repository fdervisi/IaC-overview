# Output variable definitions

output "aws_public_ip" {
  description = "Public IP of EC2"
  value       = module.ec2_instances.public_ip
}