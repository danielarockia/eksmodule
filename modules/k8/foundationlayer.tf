resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace = "argocd"
  depends_on = [
    kubernetes_namespace.eks_namespace
  ]

  values = [
    file("D:\\AWS-TF\\tf-single-subnet\\infra-terraform-environments\\env\\dev\\dev\\ap-south-1\\eks\\eks_controlplane\\foundationlayer\\argocd\\argocd-values.yaml")
  ]

}


resource "helm_release" "aws-load-balancer-controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace = "lb"
  depends_on = [
    kubernetes_namespace.eks_namespace
  ]
  values = [
    file("D:\\AWS-TF\\tf-single-subnet\\infra-terraform-environments\\env\\dev\\dev\\ap-south-1\\eks\\eks_controlplane\\foundationlayer\\aws-loadbalancer-controller\\aws-loadbalancer-controller-values.yaml")
  ]

}


resource "helm_release" "aws-ebs-csi-driver" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  values = [
    file("D:\\AWS-TF\\tf-single-subnet\\infra-terraform-environments\\env\\dev\\dev\\ap-south-1\\eks\\eks_controlplane\\foundationlayer\\ebs-csi-driver\\aws-ebs-csi-driver-values.yaml")
  ]

}

resource "helm_release" "metrics" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"

  values = [
    file("D:\\AWS-TF\\tf-single-subnet\\infra-terraform-environments\\env\\dev\\dev\\ap-south-1\\eks\\eks_controlplane\\foundationlayer\\metric-server\\metrics-server-values.yaml")
  ]

}
