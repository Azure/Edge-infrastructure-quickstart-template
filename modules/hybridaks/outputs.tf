output "tls_private_key"{
    value = tls_private_key.example.private_key_pem
    sensitive = true
}

output "akscluster" {
  value       = azapi_resource.connectedCluster
  description = "Hybrid AKS Cluster instance"
}

# resource "azapi_resource_action" "kubeconfig" {
#   type        = "Microsoft.Resources/providers@2021-04-01"
#   resource_id = "/subscriptions/${data.azurerm_client_config.current.subscription_id}/providers/Microsoft.Compute"
#   action      = "listUserKubeconfig"
#   method      = "POST"
#   response_export_values =["kubeconfigs"]
# }
# output "kubeconfig"{
#     value = resource.azapi_resource_action.kubeconfig.output.kubeconfigs[0].value
#     sensitive = true
# }