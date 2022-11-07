data "aws_eks_cluster" "controlplane" {
  name = "${var.cluster_name}"
}

terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      #version = ">= 1.13.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 1.13"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.1.0"
    }
  }
  required_version = ">= 0.14"



}

provider "kubernetes" {
    host                   = data.aws_eks_cluster.controlplane.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.controlplane.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.controlplane.name]
      command     = "aws"
    }
}

# provider "kubernetes" {
#   # Configuration options
#   config_path = "~/.kube/config"
# }
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.controlplane.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.controlplane.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.controlplane.name]
      command     = "aws"
    }
  }
}



resource "kubernetes_namespace" "cert_manager" {
  count = var.create_namespace ? 1 : 0

  metadata {
    annotations = {
      name = var.namespace_name
    }
    name = var.namespace_name
  }
}

resource "helm_release" "cert_manager" {
  chart      = "cert-manager"
  repository = "https://charts.jetstack.io"
  name       = "cert-manager"
  namespace  = var.create_namespace ? kubernetes_namespace.cert_manager[0].id : var.namespace_name

  create_namespace = false

  set {
    name  = "installCRDs"
    value = "true"
  }

  dynamic "set" {
    for_each = var.additional_set
    content {
      name  = set.value.name
      value = set.value.value
      type  = lookup(set.value, "type", null)
    }
  }
}

resource "time_sleep" "wait" {
  create_duration = "60s"

  depends_on = [helm_release.cert_manager]
}

resource "kubectl_manifest" "cluster_issuer" {
     yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: selfsigned
spec:
  selfSigned: {}
YAML
 depends_on = [
   time_sleep.wait
 ]
}

resource "kubectl_manifest" "cert" {
     yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: first-tls
spec:
  secretName: ${var.secretName}
  dnsNames:
  - "*.${var.namespace_name}.svc.cluster.local"
  - "*.${var.namespace_name}"
  issuerRef:
    name: selfsigned
YAML
depends_on = [
  kubectl_manifest.cluster_issuer
]
}