# IaC-overview

My goal is to illustrate the various capabilities of Terraform using two straightforward examples. The primary focus is to demonstrate how to extract parameters from a flat structure, where all parameters are hard-coded, and eventually achieve a scalable modular design.

The example infrastructure used in each subdirectory is a basic deployment that creates and manages resources in either AWS or Azure. The examples utilize standard modules from the Terraform registry to set up networking, create virtual machines, and other resources. Each example also includes a custom modular design that utilizes variables and modules to make the code reusable and scalable.

By examining the two examples, readers can gain an understanding of how to use Terraform to manage infrastructure, how to leverage modules to organize and encapsulate resource configurations, and how to use variables to customize resource configurations at runtime.

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

This directory contains an example of a simple Terraform infrastructure with a flat structure. This is often the first approach for someone new to IaC, where all the parameters are hard-coded into the code, and each resource is defined individually.

While this approach may be simple, it can become unwieldy and difficult to maintain as the infrastructure grows. Any changes to the resources require editing the code, which can be time-consuming and error-prone.

In this example, there is no use of modules, and all the resource definitions are contained in a single file. While this approach may be straightforward for a small infrastructure, it's not scalable and reusable.

However, this example is useful in understanding the basic concepts of Terraform and can serve as a starting point for learning how to organize and abstract the parameters to achieve a scalable modular design.

### Folder: [2-TF-simple-flat-structure-with-variables](2-TF-simple-flat-structure-with-variables)

This example demonstrates a simple Terraform code structure with no modular design. All the resources are defined in a single files, but the variables have been moved to a separate file.

The purpose of moving variables to a separate file is to provide a centralized location to manage and update the variables that are used across multiple resources. This makes it easier to update the resource configurations without modifying the resource code directly.

In this example, the variables file contains all the input variables that are required for the resources, such as the region, VPC, subnet, security group, and instance parameters. These variables are used in the resource definitions to create the infrastructure resources.


### Folder: [3-TF-custom-modules](3-TF-custom-modules)

This example demonstrates a modular structure approach in Terraform, which allows the infrastructure to be easily scaled and managed. By using modules, resource configurations are organized and encapsulated, making it easier to create and manage infrastructure resources that share common functionality and can be replicated as needed.

The use of modules also allows for easier maintenance and updating of the resources over time, and it enables the reuse of resource configurations across different projects.

With this modular approach, the infrastructure resources can be deployed and managed easily, making the code more scalable and maintainable over time.

### Folder: [4-TF-standard-modules](4-TF-standard-modules)

This example demonstrates a modular design approach for scaling infrastructure resources in Terraform. It uses standard modules from the [Terraform Registry](https://registry.terraform.io/browse/modules) to create AWS and Azure resources.

By using a modular design approach, it becomes easier to create and manage infrastructure resources that share common functionality and can be replicated as needed. The use of standard modules from the Terraform Registry further simplifies the process of creating and managing infrastructure resources by providing pre-built modules that can be easily customized and reused across different projects.

The benefit of using modules is that they provide a way to abstract the details of the resources and make them reusable across different projects. By using a modular design approach, it becomes easier to create and manage infrastructure resources that share common functionality and can be replicated as needed. This helps in reducing the duplication of code, making the code easier to manage, and reducing the likelihood of errors.

By combining modular design and standard modules from the Terraform Registry, the infrastructure resources can be deployed and managed easily, and it makes the code more scalable and maintainable over time.

# Advanced TOPIC still in Draft!
## What is Terraform CDK

[Cloud Development Kit for Terraform (CDKTF)](https://developer.hashicorp.com/terraform/cdktf) allows you to use familiar programming languages to define and provision infrastructure. This gives you access to the entire Terraform ecosystem without learning HashiCorp Configuration Language (HCL) and lets you leverage the power of your existing toolchain for testing, dependency management, etc.

One of the most popular languages for infrastructure-as-code is becoming [Typescript](https://www.typescriptlang.org/). [AWS CDK](https://aws.amazon.com/cdk/), [Terraform CDK](https://developer.hashicorp.com/terraform/cdktf), [Pulumi](https://www.pulumi.com/), and more support Typescript as a first-class citizen.

### Folder: [5-TFCDK-simple-flat-structure](5-TFCDK-simple-flat-structure/)

In this example, we use Terraform CDK with TypeScript to create a flat structure similar to the first example, where parameters are hard-coded directly in the code. The Terraform CDK enables the use of familiar programming languages such as TypeScript, which provides access to the entire Terraform ecosystem without requiring users to learn HashiCorp Configuration Language (HCL).


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


