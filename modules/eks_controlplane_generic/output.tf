output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value = "${aws_eks_cluster.controlplane.name}"
}