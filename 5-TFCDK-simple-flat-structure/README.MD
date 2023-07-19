# Terraform with AWS and Azure Example

This project provides a basic example of using the Cloud Development Kit for Terraform (CDKTF) to define and provision infrastructure on both AWS and Azure.

## Overview

The project is organized into two classes `MyAwsStack` and `MyAzureStack` representing the infrastructure being set up on AWS and Azure, respectively. For AWS, a Virtual Private Cloud (VPC) is created, along with a subnet, an Internet Gateway, a route table, an EC2 instance, and other necessary components. For Azure, a resource group, virtual network, subnet, network interface, and a Linux virtual machine are created.

## Requirements

1. [Node.js](https://nodejs.org/en/download/)
2. [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
3. [CDK for Terraform](https://learn.hashicorp.com/tutorials/terraform/cdktf)

## Installation

Clone this repository:

```bash
git clone https://github.com/<your_github_username>/terraform-aws-azure.git
cd terraform-aws-azure
```

Install the dependencies:

```bash
npm install
```

Generate CDK for Terraform constructs for AWS and Azure:

```bash
cdktf get
```

## Usage

To deploy the infrastructure, run:

```bash
cdktf deploy
```

## Outputs

The public IP of the EC2 instance will be output at the end of the `cdktf deploy` command.

## Cleaning Up

To destroy the provisioned infrastructure, run:

```bash
cdktf destroy
```

## Notes

Please note that you need to provide your own AWS and Azure credentials for Terraform to be able to provision resources on your behalf.

You may need to adjust the values in the code, like region, instance type, or the machine image, to match your needs and environment.

**Warning: This code will provision resources on AWS and Azure which may cost you money.**
