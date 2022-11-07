variable "name_prefix" {}
variable "vpc_id" {}
variable "private_endpoint" {}
variable "public_endpoint" {}
variable "servicename" {}
variable "alertgroup" {}
variable "worker_subnets" {
  #type = list(string)
}

variable "k8s_version" {}
variable "controlplane_iam_role" {}
variable "cluster_env" {}
