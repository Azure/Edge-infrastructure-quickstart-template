output "kubeConfig" {
  value     = var.enableAksArc ? module.aks-arc[0].kubeConfig : ""
  sensitive = true
}

output "aksArcPrivateKey" {
  value     = var.enableAksArc ? module.aks-arc[0].rsaPrivateKey: ""
  sensitive = true
}
