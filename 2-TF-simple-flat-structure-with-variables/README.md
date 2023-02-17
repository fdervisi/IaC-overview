# Basic Terraform with flat structure and variables
This is a simple example with a flat structure where we use a separate file to abstract the parameters, which is the recommended way.

## [aws.tf](aws.tf)
Here we find all the resources for AWS. The parameters are referenced as variables.

## [azure.tf](azure.tf)
Here we find all the resources for Azure. The parameters are referenced as variables.

## [provider.tf](provider.tf)
Here we define the AWS and Azure provider which will be used.

## [variables.tf](variables.tf)
Here we define the **type** of [variables](https://developer.hashicorp.com/terraform/language/values/variables) to be used in the code.

## [terraform.tfvars](terraform.tfvars)
Here we define the **value** of variables to be used in the code. Terraform also automatically loads variable definitions file when it named exacly as ```terraform.tfvars```