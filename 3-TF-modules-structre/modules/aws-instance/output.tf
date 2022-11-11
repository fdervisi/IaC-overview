# Print AWS Instance Public
output "aws_ec2_public_ip" {
  value = aws_instance.ec2_linux.public_ip
}