

resource "kubernetes_namespace" "eks_namespace" {
  for_each = {for i,v in var.ns: i=>v}
metadata {
  annotations = {
    name = var.ns[each.key].namespace_name
  }
  labels = {
    istio-injection = "enabled"
  }
  name = var.ns[each.key].namespace_name
}
}