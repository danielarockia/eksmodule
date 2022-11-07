 locals {
    common_tags = "${tomap(
      {"Name" = "${var.name_prefix}"}
      #"ALERTGROUP" , "${var.alertgroup}"
    )}"
  } 

resource "aws_security_group" "controlplane" {
  name        = "${var.name_prefix}-controlplane"
  description = "EKS control plane ENI"
  vpc_id      = "${data.aws_vpc.eks.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
tags = {
   NAME         = "${var.name_prefix}-controlplane"
   APPLICATIONENV = "${upper(var.cluster_env)}"
   SERVICENAME = "${var.servicename}"
   ALERTGROUP = "${var.alertgroup}"
 }
  
}

resource "aws_security_group_rule" "controlplane_443" {
  cidr_blocks       = ["${data.aws_vpc.eks.cidr_block}"]
  description       = "Allow access to Controller from Management VPC"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.controlplane.id}"
  to_port           = 443
  type              = "ingress"
}



resource "aws_security_group" "worker" {
  name        = "${var.name_prefix}-worker"
  description = "Worker nodes for ${var.name_prefix} controlplane"
  vpc_id      = "${data.aws_vpc.eks.id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(
    local.common_tags,
    tomap(
      {"Name" = "${var.name_prefix}-worker"}
    ),
    tomap(
      {"NAME" =  "${var.name_prefix}-worker"}
    )
  )}"
}

resource "aws_security_group_rule" "worker_ingress_self" {
  description              = "Allow ${var.name_prefix} worker nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = "${aws_security_group.worker.id}"
  source_security_group_id = "${aws_security_group.worker.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_cluster" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster ${var.name_prefix} controlplane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.worker.id}"
  source_security_group_id = "${aws_security_group.controlplane.id}"
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_ssh_vpc" {
  description       = "SSH access from within VPC"
  cidr_blocks       = ["${data.aws_vpc.eks.cidr_block}"]
  from_port         = 22
  protocol          = "tcp"
  security_group_id = "${aws_security_group.worker.id}"
  to_port           = 22
  type              = "ingress"
}

resource "aws_security_group_rule" "worker_ingress_from_controlplane_https" {
  description       = "Allow https to the nodes from the controlplane for metrics"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.worker.id}"
  source_security_group_id = "${aws_security_group.controlplane.id}"
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "controlplane_ingress_from_worker_https" {
  description              = "Allow pods to communicate with the ${var.name_prefix} controlplane API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = "${aws_security_group.controlplane.id}"
  source_security_group_id = "${aws_security_group.worker.id}"
  to_port                  = 443
  type                     = "ingress"
}
