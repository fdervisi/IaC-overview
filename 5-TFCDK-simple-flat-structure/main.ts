// Copyright (c) HashiCorp, Inc
// SPDX-License-Identifier: MPL-2.0
import { Construct } from 'constructs';
import { App, TerraformStack } from 'cdktf';
import { AwsProvider } from '@cdktf/provider-aws/lib/provider';
import { Vpc } from '@cdktf/provider-aws/lib/vpc';
import { Subnet } from '@cdktf/provider-aws/lib/subnet';
import { InternetGateway } from '@cdktf/provider-aws/lib/internet-gateway';
import { RouteTable } from '@cdktf/provider-aws/lib/route-table';
import { RouteTableAssociation } from '@cdktf/provider-aws/lib/route-table-association';
import { Route } from '@cdktf/provider-aws/lib/route';
import { DataAwsAmi } from '@cdktf/provider-aws/lib/data-aws-ami';

class MyStack extends TerraformStack {
  region: any;
  vpc: Vpc;
  subnet: Subnet;
  igw: InternetGateway;
  rt: RouteTable;
  rt_association: RouteTableAssociation;
  route_igw: Route;
  aws_ami: DataAwsAmi;
  constructor(scope: Construct, id: string) {
    super(scope, id);

    // define resources here
    this.region = 'eu-south-1';

    // Configure the AWS Provider
    new AwsProvider(this, 'AWS', { region: this.region });

    // Create a VPC
    this.vpc = new Vpc(this, 'vpc_1', {
      cidrBlock: '10.0.0.0/16',
      tags: { Name: 'vpc_1' },
    });

    // Create a Subnet
    this.subnet = new Subnet(this, 'subnet_1', {
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

    // Create a Route Default Route
    this.route_igw = new Route(this, 'route_igw', {
      routeTableId: this.rt.id,
      destinationCidrBlock: '0.0.0.0/0',
      gatewayId: this.igw.id,
    });

    // Get latest AWS Linux AMI
    this.aws_ami = new DataAwsAmi(this, 'aws_ami', {
      mostRecent: true,
      owners: ['amazon'],
    });
  }
}

const app = new App();
new MyStack(app, '5-TFCDK-simple-flat-structure');
app.synth();
