resource "helm_release" "istio-base" {
  repository       = local.istio_charts_url
  chart            = "base"
  name             = "istio-base"
  namespace        = "istio-system"
  values = [ file("D:\\AWS-TF\\tf-single-subnet\\infra-terraform-environments\\env\\dev\\dev\\ap-south-1\\eks\\eks_controlplane\\istiovalues\\base-values.yaml" )]
  #version          = "1.12.1"
  #create_namespace = true
}

resource "helm_release" "istiod" {
  repository       = local.istio_charts_url
  chart            = "istiod"
  name             = "istiod"
  namespace        = "istio-system"
  #create_namespace = true
  #version          = "1.12.1"
  values = [ file("D:\\AWS-TF\\tf-single-subnet\\infra-terraform-environments\\env\\dev\\dev\\ap-south-1\\eks\\eks_controlplane\\istiovalues\\istiod-values.yaml") ]
  depends_on       = [helm_release.istio-base]
}

# resource "kubernetes_namespace" "istio-ingress" {
#   metadata {
#     labels = {
#       istio-injection = "enabled"
#     }

#     name = "istio-ingress"
#   }
# }

resource "helm_release" "istio-ingress" {
  repository = local.istio_charts_url
  chart      = "gateway"
  name       = "istio-ingress"
  namespace  = "istio-ingress"
  #version    = "1.12.1"
  values = [ file( "D:\\AWS-TF\\tf-single-subnet\\infra-terraform-environments\\env\\dev\\dev\\ap-south-1\\eks\\eks_controlplane\\istiovalues\\istiogateway-values.yaml" )]
  depends_on = [helm_release.istiod]
}