# Basic Terraform with flat structure
This is the simplest example with a flat structure where all parameters are hard coded in the code. It works, but it is not a scalable and modular design.

## [aws.tf](aws.tf)
Here we find all the resources for AWS. The parameters are hard coded in the code

## [azure.tf](azure.tf)
Here we find all the resources for Azure. The parameters are hard coded in the code

## [provider.tf](provider.tf)
Here we define the AWS and Azure provider which will be used.

