output "rsaPrivateKey" {
  value     = var.generateSshKey ? tls_private_key.rsaKey[0].private_key_pem : ""
  sensitive = true
}

output "aksCluster" {
  value       = azapi_resource.connectedCluster
  description = "Hybrid AKS Cluster instance"
}

resource "azapi_resource_action" "kubeconfig" {
  type                   = "Microsoft.HybridContainerService/provisionedClusterInstances@2024-01-01"
  resource_id            = azapi_resource.provisionedClusterInstance.id
  action                 = "listAdminKubeconfig"
  method                 = "POST"
  response_export_values = ["kubeconfigs"]
}
output "kubeConfig" {
  value     = resource.azapi_resource_action.kubeconfig.output
  sensitive = true
}
