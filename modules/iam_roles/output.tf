output "EKSControlPlaneRole" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value = "${aws_iam_role.eks_master_role.name}"
}