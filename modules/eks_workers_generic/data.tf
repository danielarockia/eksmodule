data "aws_eks_cluster" "controlplane" {
  name = "${var.cluster_name}"
}

data "aws_iam_role" "worker" {
  name = "${var.worker_iam_role}"
}

data "aws_iam_instance_profile" "worker" {
  name = "${var.worker_iam_role}"
}

data "aws_region" "current" {}

data "aws_security_group" "worker" {
  tags = {
    Name = "${var.cluster_name}-worker"
 }
}

data "aws_iam_role" "worker_asg" {
  name = "${var.worker_asg_role}"
}
