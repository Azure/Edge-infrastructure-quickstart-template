output "rsaPrivateKey" {
  value     = var.sshPublicKey == null ? tls_private_key.rsaKey[0].private_key_pem : ""
  sensitive = true
}

output "aksCluster" {
  value       = azapi_resource.connectedCluster
  description = "AKS Arc Cluster instance"
}

output "provisionedClusterInstance" {
  value       = azapi_resource.provisionedClusterInstance
  description = "AKS Arc Provisioned Cluster instance"
}
