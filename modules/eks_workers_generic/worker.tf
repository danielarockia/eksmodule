locals {
  worker_userdata = <<USERDATA
#!/bin/bash -xe

/etc/eks/bootstrap.sh ${data.aws_eks_cluster.controlplane.name} ${var.kubelet_args}
AWS_AVAIL_ZONE=$(curl http://169.254.169.254/latest/meta-data/placement/availability-zone)
AWS_REGION="`echo \"$AWS_AVAIL_ZONE\" | sed 's/[a-z]$//'`"
AWS_INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
ROOT_VOLUME_IDS=$(aws ec2 describe-instances --region $AWS_REGION --instance-id $AWS_INSTANCE_ID --output text --query Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId)
aws ec2 create-tags --resources $ROOT_VOLUME_IDS --region $AWS_REGION --tags Key="ALERTGROUP",Value="${var.alertgroup}" Key="Name",Value="${var.cluster_name}-${var.asg_prefix}-worker-root-volume"  Key="APPLICATIONROLE",Value="EKS_WORKER" Key="APPLICATIONENV",Value="${upper(var.cluster_env)}" Key="SERVICENAME",Value="${upper(var.servicename)}"


USERDATA
}

resource "aws_launch_configuration" "worker" {
  enable_monitoring           = false
  associate_public_ip_address = false
  iam_instance_profile        = "${data.aws_iam_instance_profile.worker.name}"
  image_id                    = "${var.ami}"
  instance_type               = "${var.instance_type}"
  name_prefix                 = "${var.cluster_name}-${var.asg_prefix}-worker"
  security_groups             = ["${data.aws_security_group.worker.id}"]
  user_data_base64            = "${base64encode(local.worker_userdata)}"
  key_name                    = "${var.keyname}"

  root_block_device {
    volume_type = "${var.root_volume_type}"
    volume_size = "${var.root_volume_size}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "worker" {
  count                   = length(flatten(["${var.worker_subnets}"]))
  desired_capacity        = "${var.desired_instance_count}"
  launch_configuration    = "${aws_launch_configuration.worker.id}"
  max_size                = "${var.max_instance_count}"
  min_size                = "${var.min_instance_count}"
  name                    = "${var.cluster_name}-${var.asg_prefix}-worker-${count.index}"
  vpc_zone_identifier     = [flatten(["${var.worker_subnets}"])[count.index]]
  service_linked_role_arn = "${data.aws_iam_role.worker_asg.arn}"
  termination_policies    = ["${var.term_policy}"]

  tag {
    key                 = "Name"
    value               = "${var.cluster_name}-${var.asg_prefix}-eks-worker-${count.index}"
    propagate_at_launch = true
  }

  tag {
    key                 = "kubernetes.io/cluster/${data.aws_eks_cluster.controlplane.name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "NAME"
    value               = "${var.cluster_name}-${var.asg_prefix}-eks-worker-${count.index}"
    propagate_at_launch = true
  }

  tag {
    key                 = "ASG_SUBNET"
    value               = flatten(["${var.worker_subnets}"])[count.index]
    propagate_at_launch = true
  }


  tag {
    key                 = "APPLICATIONROLE"
    value               = "EKS_WORKER"
    propagate_at_launch = true
  }

  tag {
    key                 = "APPLICATIONENV"
    value               = "${upper(var.cluster_env)}"
    propagate_at_launch = true
  }

  tag {
    key                 = "SERVICENAME"
    value               = "${upper(var.servicename)}"
    propagate_at_launch = true
  }
  
  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = true
  }

  tag {
    key                 = "k8s.io/cluster-autoscaler/enabled"
    value               = "true"
    propagate_at_launch = true
  }

}

resource "aws_autoscaling_lifecycle_hook" "worker" {
  depends_on             = [aws_autoscaling_group.worker]
  count                  = length(flatten(["${var.worker_subnets}"]))
  name                   = "ASGLifecycleHook"
  autoscaling_group_name = "${var.cluster_name}-${var.asg_prefix}-worker-${count.index}"
  default_result         = "CONTINUE"
  heartbeat_timeout      = 300
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_TERMINATING"

}
