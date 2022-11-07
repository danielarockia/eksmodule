variable "cluster_name" {default = "dev-aws-eks-ap-south-1"}
variable "cluster_env" {default = "dev-aws-eks-ap-south-1"}
variable "region" {default = "us-east-2"}
variable "ns" {
  type = list(object({
    namespace_name = string
  }))
}