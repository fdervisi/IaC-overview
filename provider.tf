# initiate required Providers
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    azurerm = {
      source = "hashicorp/azurerm"
    }
  }
}