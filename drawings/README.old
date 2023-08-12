# Infrastructure as Code (IaC) with Terraform: A Comprehensive Guide

Welcome to the comprehensive guide for Infrastructure as Code (IaC) with Terraform. This guide aims to present various capabilities of Terraform through easy-to-understand examples. We'll transition from a basic flat structure, where parameters are hard-coded, to a highly scalable modular design. The examples utilize standard Terraform modules and custom modules, featuring resources deployed in both AWS and Azure.

## What Will We Deploy?
Here's a glimpse of the infrastructure components we'll deploy in both AWS and Azure:

**AWS**:
- VPC
- Internet Gateway
- Subnet
- Virtual Machine

**Azure**:
- VNet
- Internet Gateway
- Subnet
- Virtual Machine

![IaC Overview](drawings/IaC_overview.png)

## Repository Structure

This guide is divided into several subfolders, each focusing on a particular aspect of IaC with Terraform.

### 1. [Simple Flat Structure](1-TF-simple-flat-structure)

This example starts with a simple, flat structure, typical of someone new to IaC. All parameters are hard-coded and each resource is defined individually. It serves as a foundation to understand the basic concepts of Terraform and sets the stage for future optimizations.

### 2. [Flat Structure with Variables](2-TF-simple-flat-structure-with-variables)

This example introduces variables, which are extracted into a separate file. While it still lacks a modular design, using variables facilitates centralized management and updating of shared parameters across resources.

### 3. [Custom Modules](3-TF-custom-modules)

This section features Terraform's modular structure approach, which improves scalability and manageability. By encapsulating common functionalities into modules, we enhance resource replication, and make maintenance and updating easier.

### 4. [Standard Modules](4-TF-standard-modules)

Here, we introduce the use of standard modules from the [Terraform Registry](https://registry.terraform.io/browse/modules) to create AWS and Azure resources. This approach not only continues the benefits realized in the Custom Modules section but also simplifies resource creation through pre-built, customizable modules.

## Advanced Topic - Draft In Progress

Stay tuned for a detailed discussion on the Cloud Development Kit for Terraform (CDKTF) - a powerful tool that enables the use of familiar programming languages like TypeScript for defining and provisioning infrastructure.

### [Terraform CDK - Simple Flat Structure](5-TFCDK-simple-flat-structure/)

In this upcoming section, we'll explore how the Terraform CDK with TypeScript is used to create a flat structure similar to our first example.

## Setting Up Your Environment

Before diving into the examples, ensure your environment is set up correctly. This includes installing Terraform, the Terraform CDK, and authenticating against AWS and Azure. You can find a guide on how to install Terraform [here](https://developer.hashicorp.com/terraform/cdktf).

### AWS Authentication
To authenticate with AWS, follow the steps outlined [here](https://registry.terraform.io/providers/hashicorp/aws/latest/docs). As a quick reference, the environment variables to be exported are:

```bash
export AWS_ACCESS_KEY_ID="anaccesskey"
export AWS_SECRET_ACCESS_KEY="asecretkey"
export AWS_REGION="us-west-2"
```

### Azure Authentication
For Azure authentication, refer to the process [here](https://learn.microsoft.com/en-us/azure/developer/terraform/authenticate-to-azure?tabs=bash). You'll need to export the following credentials:

```bash
export ARM_SUBSCRIPTION_ID="<azure_subscription_id>"
export ARM_TENANT_ID="<azure_subscription_tenant_id>"
export ARM_CLIENT_ID="<service_principal_appid>"
export ARM_CLIENT_SECRET="<service_principal_password>"
```

### Installing Terraform CDK
You can find the guide to install Terraform CDK [here](https://developer.hashicorp.com/terraform/tutorials/cdktf/cdktf-install). Following installation, remember to install Azure and AWS providers:

```bash
npm install @cdktf/provider-aws
npm install @cdktf/provider-azurerm
```
