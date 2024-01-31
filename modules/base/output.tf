output "kubeConfig" {
  value     = var.enableAksArc ? module.hybrid-aks[0].kubeConfig : ""
  sensitive = true
}

output "aksArcPrivateKey" {
  value     = var.enableAksArc ? module.hybrid-aks[0].rsaPrivateKey: ""
  sensitive = true
}
