# IaC-overview

This is basic AWS and Azure example how to deploy a Virtual Machine with public IP


## Install Terraform CDK


https://developer.hashicorp.com/terraform/tutorials/cdktf/cdktf-install
sudo npm install --global cdktf-cli@latest
sudo npm install -g npm@9.1.1
cdktf init --template=typescript --local
npm install @cdktf/provider-aws
npm install @cdktf/provider-azurerm

![IaC](drawings/IaC_overview.png)