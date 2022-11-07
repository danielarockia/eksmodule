# provider "kubernetes" {
#   # Configuration options
#   config_path = "~/.kube/config"
# }

provider "kubernetes" {
    host                   = data.aws_eks_cluster.controlplane.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.controlplane.certificate_authority.0.data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", data.aws_eks_cluster.controlplane.name]
      command     = "aws"
    }
}