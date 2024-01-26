resource "azapi_update_resource" "k8sextension" {
  type = "Microsoft.KubernetesConfiguration/extensions@2023-05-01"
  name = "hybridaksextension"
  body = jsonencode({
    properties = {
      autoUpgradeMinorVersion = false
      releaseTrain = "stable"
      version = "1.0.36"
    }
  })
}
