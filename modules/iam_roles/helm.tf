 provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

resource "helm_release" "kubewatch" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"

  values = [
    file("D:\\AWS-TF\\tf-single-subnet\\infra-terraform-environments\\env\\dev\\dev\\ap-south-1\\eks\\eks_controlplane\\foundationlayer\\metric-server\\metrics-server-values.yaml")
  ]

}

