# vpc

This module creates an AWS VPC. The following resources are created along with this VPC.
* vpc
* Associate this vpc to infacloudops.net route53 zone
* mentioned number of public subnets in diff AZ
* mentioned number of Worker Layer Subnets in diff AZ
* nat gateways in each availability zone
* associate private subnets to respective AZ's nat g/w
* internet gateway
* route tables for each availability zone

```
variable "region" {
  default = "us-west-2"
}

# Get the s3 bucket name from https://github.com/infacloud/ct_tfmodules#aws-s3-buckets-for-storing-state-files
variable "region" {
  default = "us-west-2"
}

terraform {
  backend "s3" {
    bucket       = "cloudops-ichsprod"
    key          = "vpcs/iics-eks-cluster1/us-west-2/vpc/iics-eks-cluster1.tfstate"
    region       = "us-west-2"
  }
}

provider "aws" {
  region = "${var.region}"
} 


module "vpc" {
  source             = "git::ssh://git@github.com/infacloud/ct_tfmodules.git//modules/aws/vpc_eks?ref=1.14.0"
  name_prefix        = "IICS-EKS-CLUSTER1"
  
  newbits            = "22" 
  cidr_block         = "10.98.0.0/18"
  subnets_count       = "3"   
  tags {
    
    APPLICATIONENV = "PROD"
    BUSINESSENTITY = "CLOUDTRUST"
    BUSINESSUNIT = "CLOUDTRUST"
    SERVICENAME  =  "EKS"
    ALERTGROUP = "ops_team"
    BILLING = "55010"   
}

output "vpc_id" {
  value = "${module.vpc.id}"
}

output "subnets_layer1" {
  value = "${module.vpc.subnets_layer1}"
}

output "subnets_layer2" {
  value = "${module.vpc.subnets_layer2}"
}


output "subnets_public" {
  value = "${module.vpc.subnets_public}"
}

```

