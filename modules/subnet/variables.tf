variable "cidr_block" {
  default = "172.31.0.0/16"
}

variable "name_prefix" {}

variable "subnets_count" {
  description = "number of subnets per type"  
}

variable "private_subnets_count" {
  description = "number of subnets per type"  
}

variable "newbits" {
  description = "24 for IICS and 25 for MA"
}
variable "businessunit" {
  default = "CLOUDTRUST"
}

variable "tags" {
  description = "A map of tags to add"
  type        = map
  default = {
     "env" = "test"
  }
} 