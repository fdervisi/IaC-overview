# Basic Terraform with flat structure and variables
This is a simple example with a flat structure where we use a separate file to abstract the parameters, which is the recommended way.

## [aws.tf](aws.tf)
Here we find all the resources for AWS. The parameters are hard coded in the code

## [azure.tf](azure.tf)
Here we find all the resources for Azure. The parameters are hard coded in the code

## [provider.tf](provider.tf)
Here we define the AWS and Azure provider which will be used.

## [variables.tf](variables.tf)
Here we define the *type* of variables to be used in the code

## [terraform.tfvars](terraform.tfvars)
Here we define the *value* of variables to be used in the code