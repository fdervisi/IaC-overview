// Copyright (c) HashiCorp, Inc
// SPDX-License-Identifier: MPL-2.0
import { Construct } from 'constructs';
import { App, TerraformOutput, TerraformStack } from 'cdktf';
import { AwsProvider } from '@cdktf/provider-aws/lib/provider';
import { AzurermProvider } from '@cdktf/provider-azurerm/lib/provider';
import { Vpc } from '@cdktf/provider-aws/lib/vpc';
import { Subnet as AwsSubnet } from '@cdktf/provider-aws/lib/subnet';
import { InternetGateway } from '@cdktf/provider-aws/lib/internet-gateway';
import { RouteTable } from '@cdktf/provider-aws/lib/route-table';
import { RouteTableAssociation } from '@cdktf/provider-aws/lib/route-table-association';
import { Route } from '@cdktf/provider-aws/lib/route';
import { DataAwsAmi } from '@cdktf/provider-aws/lib/data-aws-ami';
import { SecurityGroup } from '@cdktf/provider-aws/lib/security-group';
import { Instance } from '@cdktf/provider-aws/lib/instance';
import { ResourceGroup } from '@cdktf/provider-azurerm/lib/resource-group';
import { VirtualNetwork } from '@cdktf/provider-azurerm/lib/virtual-network';
import { LinuxVirtualMachine } from '@cdktf/provider-azurerm/lib/linux-virtual-machine';
import { Subnet } from '@cdktf/provider-azurerm/lib/subnet';
import { NetworkInterface } from '@cdktf/provider-azurerm/lib/network-interface';

class MyAwsStack extends TerraformStack {
  region: any;
  vpc: Vpc;
  subnet: AwsSubnet;
  igw: InternetGateway;
  rt: RouteTable;
  rt_association: RouteTableAssociation;
  route_igw: Route;
  aws_ami: DataAwsAmi;
  sg: SecurityGroup;
  ec2: Instance;
  constructor(scope: Construct, id: string) {
    super(scope, id);

    // Region
    this.region = 'eu-south-1';

    // Configure the AWS Provider
    new AwsProvider(this, 'AWS', { region: this.region });

    // Create a VPC
    this.vpc = new Vpc(this, 'vpc_1', {
      cidrBlock: '10.0.0.0/16',
      tags: { Name: 'vpc_1' },
    });

    // Create a Subnet
    this.subnet = new AwsSubnet(this, 'subnet_1', {
      cidrBlock: '10.0.0.0/24',
      vpcId: this.vpc.id,
      tags: { Name: 'subnet_1' },
    });

    // Create a IGW
    this.igw = new InternetGateway(this, 'igw', {
      vpcId: this.vpc.id,
      tags: { Name: 'igw_vpc_1' },
    });

    // Create a Route Table
    this.rt = new RouteTable(this, 'rt', {
      vpcId: this.vpc.id,
      tags: { Name: 'rt_vpc_1' },
    });

    // Create a Route Table Association
    this.rt_association = new RouteTableAssociation(
      this,
      'rt_association_vpc1',
      { routeTableId: this.rt.id, subnetId: this.subnet.id }
    );

    // Create a Default Route
    this.route_igw = new Route(this, 'route_igw', {
      routeTableId: this.rt.id,
      destinationCidrBlock: '0.0.0.0/0',
      gatewayId: this.igw.id,
    });

    // Get latest AWS Linux AMI
    this.aws_ami = new DataAwsAmi(this, 'aws_ami', {
      mostRecent: true,
      owners: ['amazon'],
      filter: [{ name: 'name', values: ['amzn2-ami-kernel-5*'] }],
    });

    // Create Security Group
    this.sg = new SecurityGroup(this, 'sg', {
      name: 'sg_allow_ssh',
      vpcId: this.vpc.id,
      ingress: [
        { description: 'ssh', protocol: 'tcp', fromPort: 22, toPort: 22 },
      ],
    });

    // Create EC2 instance
    this.ec2 = new Instance(this, 'ec2_1', {
      ami: this.aws_ami.id,
      associatePublicIpAddress: true,
      subnetId: this.subnet.id,
      instanceType: 't3.micro',
      vpcSecurityGroupIds: [this.sg.id],
      userData: `
        #! /bin/bash
        sudo yum update -y
        sudo touch /home/ec2-user/USERDATA_EXECUTED
        `,
      tags: { Name: 'ec2_1' },
    });

    // Output Public IP
    new TerraformOutput(this, 'public_ip', {
      value: this.ec2.publicIp,
      description: 'EC2 Public IP',
    });
  }
}

class MyAzureStack extends TerraformStack {
  rg: ResourceGroup;
  vnet: VirtualNetwork;
  subnet: Subnet;
  network_interface: NetworkInterface;
  vm: LinuxVirtualMachine;

  constructor(scope: Construct, name: string) {
    super(scope, name);

    new AzurermProvider(this, 'AzureRm', {
      features: {
        resourceGroup: { preventDeletionIfContainsResources: false },
      },
    });

    // Create a Ressource Group
    this.rg = new ResourceGroup(this, 'rg', {
      name: 'fdervisi_IaC_basic',
      location: 'North Europe',
    });

    // Create a VNet
    this.vnet = new VirtualNetwork(this, 'vnet_1', {
      resourceGroupName: this.rg.name,
      name: 'vnet_1',
      location: this.rg.location,
      addressSpace: ['10.0.0.0/16'],
    });

    // Create a Subnet
    this.subnet = new Subnet(this, 'subnet', {
      addressPrefixes: ['10.0.0.0/16'],
      resourceGroupName: this.rg.name,
      virtualNetworkName: this.vnet.name,
      name: 'subnet_1',
    });

    // Create Network Interface
    this.network_interface = new NetworkInterface(this, 'nic', {
      name: 'nic_1',
      location: this.rg.location,
      resourceGroupName: this.rg.name,
      ipConfiguration: [
        {
          name: 'nic_ip',
          subnetId: this.subnet.id,
          privateIpAddressAllocation: 'Dynamic',
        },
      ],
    });

    // Create a VM
    this.vm = new LinuxVirtualMachine(this, 'vm', {
      name: 'vm-1',
      location: this.rg.location,
      resourceGroupName: this.rg.name,
      size: 'Standard_DS1_v2',
      networkInterfaceIds: [this.network_interface.id],
      disablePasswordAuthentication: false,
      adminUsername: 'Fatos',
      adminPassword: 'Zscaler2022',
      osDisk: { caching: 'ReadWrite', storageAccountType: 'Standard_LRS' },
      sourceImageReference: {
        publisher: 'Canonical',
        offer: 'UbuntuServer',
        sku: '16.04-LTS',
        version: 'latest',
      },
    });
  }
}

const app = new App();
new MyAwsStack(app, 'AwsStack');
new MyAzureStack(app, 'AzureStack');

app.synth();
