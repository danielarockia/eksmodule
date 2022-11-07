data "aws_caller_identity" "account" {
  
}

resource "aws_iam_role" "k8s_devops_assuemrole_admin" {
  name = "${var.env}_k8s-devops-assumerole_aws_full_access"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.account.account_id}:root"
        }
      },
    ]
  })
  tags = {
    tag-key = "${var.env}_k8s_devops_assumerole_aws_full_access"
  }
}

resource "aws_iam_group" "k8s_devops_assuemgroup_aws_full_access" {
  name = "${var.env}_eks-devops-assumegroup_aws_full_access"
  path = "/"
}




resource "aws_iam_policy" "k8s_devops_assuempolicy_assumerole_policy" {
  name  = "${var.env}_eksdeveloper-group-policy"
  

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Sid    = "123"
        Resource = "${aws_iam_role.k8s_devops_assuemrole_admin.arn}"
      },
    ]
  })
}

resource "aws_iam_group_policy_attachment" "k8s_devops_attacheadminpolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  group      = aws_iam_group.k8s_devops_assuemgroup_aws_full_access.name
}

resource "aws_iam_group_policy_attachment" "k8s_devops_attacheassumepolicy" {
  policy_arn = aws_iam_policy.k8s_devops_assuempolicy_assumerole_policy.arn
  group      = aws_iam_group.k8s_devops_assuemgroup_aws_full_access.name
}

# resource "aws_iam_group_policy_attachment" "k8s_devops_attacheassumepolicy_eks" {
#   policy_arn = aws_iam_policy.k8s_devops_assuempolicy_assumerole_policy_eks.arn
#   group      = aws_iam_group.k8s_devops_assuemgroup.name
# }


resource "aws_iam_role" "k8s_devops_assuemrole_eks_admin" {
  name = "${var.env}_k8s-devops-assumerole_eks_full_access"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.account.account_id}:root"
        }
      },
    ]
  })
  tags = {
    tag-key = "${var.env}_k8s_devops_assumerole_eks_full_access"
  }
}


resource "aws_iam_group" "k8s_devops_assuemgroup_eks_full_access" {
  name = "${var.env}_eks-devops-assumegroup_eks_full_access"
  path = "/"
}

resource "aws_iam_policy" "k8s_devops_assuempolicy_assumerole_policy_eks" {
  name  = "${var.env}_eksdeveloper-group-policy_eks"
  

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Sid    = "123"
        Resource = "${aws_iam_role.k8s_devops_assuemrole_eks_admin.arn}"
      },
    ]
  })
}

resource "aws_iam_policy" "k8s_devops_assuempolicy_assumerole_policy_eks_full" {
  name  = "${var.env}_eksdeveloper-group-policy_eks_fullaccess"
  

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "iam:ListRoles",
              "eks:*",
              "ssm:GetParameter"
          ],
          "Resource": "*"
      }
   ]
 })
}

resource "aws_iam_group_policy_attachment" "k8s_devops_attacheassumepolicy_read" {
  policy_arn = aws_iam_policy.k8s_devops_assuempolicy_assumerole_policy_eks.arn
  group      = aws_iam_group.k8s_devops_assuemgroup_eks_full_access.name
}

 resource "aws_iam_group_policy_attachment" "k8s_devops_attacheassumepolicy_eks" {
   policy_arn = aws_iam_policy.k8s_devops_assuempolicy_assumerole_policy_eks_full.arn
   group      = aws_iam_group.k8s_devops_assuemgroup_eks_full_access.name
 }

 resource "aws_iam_role" "k8s_devops_assuemrole_eks_readonly" {
  name = "${var.env}_k8s-devops-assumerole_eks_readonly"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.account.account_id}:root"
        }
      },
    ]
  })
  tags = {
    tag-key = "${var.env}_k8s_devops_assumerole_eks_readonly"
  }
}


resource "aws_iam_group" "k8s_devops_assuemgroup_eks_readonly" {
  name = "${var.env}_eks-devops-assumegroup_eks_readonly"
  path = "/"
}

resource "aws_iam_policy" "k8s_devops_assuempolicy_assumerole_policy_eks_readonly" {
  name  = "${var.env}_eksdeveloper-group-policy_readonly"
  

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
        ]
        Effect   = "Allow"
        Sid    = "123"
        Resource = "${aws_iam_role.k8s_devops_assuemrole_eks_readonly.arn}"
      },
    ]
  })
}

resource "aws_iam_policy" "k8s_devops_assuempolicy_assumerole_policy_eks_readonly_custom" {
  name  = "${var.env}_eksdeveloper-group-policy_eks_readonly"
  

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
              "eks:DescribeCluster",
              "eks:ListClusters",
              "ssm:GetParameter"
          ],
          "Resource": "*"
      }
   ]
 })
}

resource "aws_iam_group_policy_attachment" "k8s_devops_attacheassumepolicy_readonly" {
  policy_arn = aws_iam_policy.k8s_devops_assuempolicy_assumerole_policy_eks_readonly_custom.arn
  group      = aws_iam_group.k8s_devops_assuemgroup_eks_readonly.name
}

 resource "aws_iam_group_policy_attachment" "k8s_devops_attacheassumepolicy_eks_readonly" {
   policy_arn = aws_iam_policy.k8s_devops_assuempolicy_assumerole_policy_eks_readonly.arn
   group      = aws_iam_group.k8s_devops_assuemgroup_eks_readonly.name
 }