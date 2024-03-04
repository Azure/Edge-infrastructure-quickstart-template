output "rsaPrivateKey" {
  value     = var.generateSshKey ? tls_private_key.rsaKey[0].private_key_pem : ""
  sensitive = true
}

output "aksCluster" {
  value       = azapi_resource.connectedCluster
  description = "Hybrid AKS Cluster instance"
}

// listAdminKubeconfig will raise 409 if run just after the cluster creation.
resource "time_sleep" "wait_10_seconds" {
  depends_on      = [azapi_resource.provisionedClusterInstance]
  create_duration = "10s"
}

resource "azapi_resource_action" "kubeconfigs" {
  depends_on             = [time_sleep.wait_10_seconds]
  type                   = "Microsoft.Kubernetes/connectedClusters@2024-01-01"
  resource_id            = azapi_resource.connectedCluster.id
  action                 = "listClusterUserCredential"
  method                 = "POST"
  response_export_values = ["kubeconfigs"]
  body = jsonencode({
    authenticationMethod = var.enableAzureRBAC ? "AAD" : "Token"
    clientProxy          = false // TODO: Add client proxy support
  })
}

output "kubeconfigs" {
  value     = resource.azapi_resource_action.kubeconfigs.output
  sensitive = true
}
