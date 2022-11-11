# Input variable definitions
variable "vpc_azs" {
  description = "Availability zones for VPC"
  type        = list(string)
  default     = ["eu-south-1a", "eu-south-1b"]
}