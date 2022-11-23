# IaC-overview

My goal is to describe the different possibilities of Terraform using two simple examples. The focus is to understand how to abstract the parameters from a flat structure, where all parameters are hard coded, to finally achieve a scalable modular design. 

This is the simple infrastructure example used each subdirectory:

### AWS:
* 1x VPC
* 1x Internet Gateway
* 1x Subnet
* 1x Virtual Machine

### Azure:
* 1x VNet
* 1x Internet Gateway
* 1x Subnet
* 1x Virtual Machine

![IaC](drawings/IaC_overview.png)

### Folder: [1-TF-simple-flat-structure](1-TF-simple-flat-structure)

This is the simplest and probably the first coding attempt of someone starting with IaC. Here the parameters are defined in code and each resource individually.

### Folder: [2-TF-simple-flat-structure-with-variables](2-TF-simple-flat-structure-with-variables)

Here the parameters have already been moved to a seperate file, but a flat structure is still used where the resources are created individually.

### Folder: [3-TF-custom-modules](3-TF-custom-modules)

Now the flat structure has been modularized and you can call the modules in a scalable way.

### Folder: [4-TF-standard-modules](4-TF-standard-modules)

Alternatively, you can use standard modules available in [Terraform Registry](https://registry.terraform.io/browse/modules). In this simple example it was possible without problems, but most of the time a combination of custom and standard modules is needed.

# Advanced TOPIC still in Draft!
## What is Terraform CDK

[Cloud Development Kit for Terraform (CDKTF)](https://developer.hashicorp.com/terraform/cdktf) allows you to use familiar programming languages to define and provision infrastructure. This gives you access to the entire Terraform ecosystem without learning HashiCorp Configuration Language (HCL) and lets you leverage the power of your existing toolchain for testing, dependency management, etc.

One of the most popular languages for infrastructure-as-code is becoming [Typescript](https://www.typescriptlang.org/). [AWS CDK](https://aws.amazon.com/cdk/), [Terraform CDK](https://developer.hashicorp.com/terraform/cdktf), [Pulumi](https://www.pulumi.com/), and more support Typescript as a first-class citizen.

### Folder: [5-TFCDK-simple-flat-structure](5-TFCDK-simple-flat-structure/)

Here we use Terraform CDK with TypeScript to create a flat structure with hard coded parmaters similar to the first example where we use Terraform HCL.


## General Ressources
### Install Terraform

[Here](https://developer.hashicorp.com/terraform/cdktf) you can find a guide how to install Terraform. After installation you have to authenticate against AWS and Azure.

#### AWS

[Here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs) you will find the process for authentication for AWS. The most simple solution is to export the Access and Secret Access Key:

```
$ export AWS_ACCESS_KEY_ID="anaccesskey"
$ export AWS_SECRET_ACCESS_KEY="asecretkey"
$ export AWS_REGION="us-west-2"
```

#### Azure

[Here](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash) ou will find the process for authentication for AWS. The most simple solution is to export the credentials: 

```
export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
export ARM_TENANT_ID="<azure_subscription_tenant_id>"
export ARM_CLIENT_ID="<service_principal_appid>"
export ARM_CLIENT_SECRET="<service_principal_password>"
```

### Install Terraform CDK

[Here](https://developer.hashicorp.com/terraform/tutorials/cdktf/cdktf-install) you can find how to install Terraform CDK. After installation you need to install the Azure and AWS provider:

```
npm install @cdktf/provider-aws
npm install @cdktf/provider-azurerm
```


