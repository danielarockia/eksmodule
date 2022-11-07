data "aws_availability_zones" "azs" {}

data "aws_vpc" "defaultvpc" {

  default = true
}
  
data "aws_internet_gateway" "internatgateway" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.defaultvpc.id]
  }
}

