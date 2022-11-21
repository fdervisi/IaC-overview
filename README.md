# IaC-overview

My goal is to describe the different possibilities in Terraform with two simple examples. The focus is to understand how to abstract the parameters from a flat structure where all the parameters are hard coded and finally get to a scalable modular design. 

This is the simple infrastructure example used each subdirectory:

## AWS:
1x VPC
1x Internet Gateway
1x Subnet
1x Virtual Machine

## Azure:
1x VNet
1x Internet Gateway
1x Subnet
1x Virtual Machine

![IaC](drawings/IaC_overview.png)

## Install Terraform CDK


https://developer.hashicorp.com/terraform/tutorials/cdktf/cdktf-install
sudo npm install --global cdktf-cli@latest
sudo npm install -g npm@9.1.1
cdktf init --template=typescript --local
npm install @cdktf/provider-aws
npm install @cdktf/provider-azurerm

![IaC](drawings/IaC_overview.png)