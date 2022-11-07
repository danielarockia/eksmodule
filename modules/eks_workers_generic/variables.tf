variable "cluster_name" {}
variable "asg_prefix" {}
variable "servicename" {}
variable "alertgroup" {}


variable "instance_type" {
}

variable "ami" {}

variable "keyname" {}

variable "min_instance_count" {
type = number
}

variable "max_instance_count" {
type = number
}

variable "desired_instance_count" {
type = number
default = null
}

variable "cluster_env" {}


variable "worker_subnets" {
  #type = list(string)
}

variable "root_volume_size" {
  default = 20
}

variable "worker_asg_role" {}

variable "term_policy" {}

variable "worker_iam_role" {
}

variable "kubelet_args" {
  default = ""
}

variable "root_volume_type" {
  type = string
  default = "gp3"
}
