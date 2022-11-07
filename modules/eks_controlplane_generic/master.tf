resource "aws_eks_cluster" "controlplane" {
  name     = "${var.name_prefix}"
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  role_arn = "${data.aws_iam_role.controlplane.arn}"
  version  = "${var.k8s_version}"

  vpc_config {
    security_group_ids = ["${aws_security_group.controlplane.id}"]
    subnet_ids         = flatten(["${var.worker_subnets}"])
    endpoint_private_access = "${var.private_endpoint}"
    endpoint_public_access = "${var.public_endpoint}"
  }
  tags = {
           APPLICATIONENV = "${upper(var.cluster_env)}"
           SERVICENAME = "${var.servicename}"
           ALERTGROUP = "${var.alertgroup}"
         }
}
