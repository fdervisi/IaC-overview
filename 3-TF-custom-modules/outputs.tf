## Output variable definitions
# Print AWS Instance Public
output "aws_ec2_public_ip" {
  value = module.aws__instances_1.aws_ec2_public_ip
}

# Print AWS Instance Public
output "azure_vm_public_ip" {
  value = module.azure_instances_1.azure_vm_public_ip
}