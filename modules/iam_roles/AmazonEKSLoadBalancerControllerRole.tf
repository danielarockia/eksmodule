resource "aws_iam_role" "EKSLoadBalancerControllerRole" {
  name = "${var.env}_AmazonEKSLoadBalancerControllerRole"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy_attachment" "EKSLoadBalancerControllerRoleatc" {
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.devaccount.account_id}:policy/AWSLoadBalancerControllerIAMPolicy"
  role       = aws_iam_role.EKSLoadBalancerControllerRole.name
}
