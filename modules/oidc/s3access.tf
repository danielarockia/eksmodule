variable "cluster_env" {default="test"}

data "aws_eks_cluster" "controlplane" {
  name = "${var.cluster_name}"
}


resource "aws_iam_role" "eks_s3_access" {
  name = "${var.cluster_env}_s3_read_access"

 
   assume_role_policy = jsonencode({
    
        "Version": "2012-10-17",
        "Statement": [
            {
                "Effect": "Allow",
                "Principal": {
                    "Federated": "arn:aws:iam::649502456029:oidc-provider/oidc.eks.us-east-2.amazonaws.com/id/30631D37ED22198958E316AF96E2CD17"
                },
                "Action": "sts:AssumeRoleWithWebIdentity",
                "Condition": {
                    "StringEquals": {
                        "${element(split("oidc-provider/", "oidc.eks.us-east-2.amazonaws.com/id/30631D37ED22198958E316AF96E2CD17"), 1)}:sub": "system:serviceaccount:default:s3-read-access-sa"
                    }
                }
            }
        ]
 }
 )
 tags = {
    tag-key = "tag-value"
  }
}

resource "aws_iam_role_policy_attachment" "eks-s3_read_access" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.eks_s3_access.name
}

resource "kubernetes_service_account_v1" "s3_readaccess_sa" {
  depends_on = [ aws_iam_role_policy_attachment.eks-s3_read_access ]
  metadata {
    name = "s3-read-access-sa"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_s3_access.arn
      }
  }
}


# Resource: Kubernetes Job
resource "kubernetes_job_v1" "s3_read_access_job" {
  metadata {
    name = "s3-read-access"
  }
  depends_on = [
    kubernetes_service_account_v1.s3_readaccess_sa
  ]
  spec {
    template {
      metadata {
        labels = {
          app = "s3-read-access"
        }
      }
      spec {
        service_account_name = "s3-read-access-sa" 
        container {
          name    = "s3-read-access"
          image   = "amazon/aws-cli:latest"
          args = ["s3", "ls"]
          #args = ["ec2", "describe-instances", "--region", "${var.aws_region}"] # Should fail as we don't have access to EC2 Describe Instances for IAM Role
        }
        restart_policy = "Never"
      }
    }
  }
}


