data "aws_eks_cluster" "controlplane" {
  name = "${var.cluster_name}"
}