# Output variable definitions
output "aws_public_ip" {
  description = "Public IP of EC2"
  value       = module.ec2_instances.public_ip
}

output "azure_public_ip" {
  description = "Public IP of Virtual Instance"
  value       = module.vm.public_ip_address
}
