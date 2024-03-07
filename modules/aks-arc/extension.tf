resource "azapi_update_resource" "k8sExtension" {
  count     = var.isExported ? 0 : 1
  type      = "Microsoft.KubernetesConfiguration/extensions@2023-05-01"
  parent_id = var.arbId
  name      = "hybridaksextension"
  payload = {
    properties = {
      autoUpgradeMinorVersion = false
      releaseTrain            = "stable"
      version                 = "1.0.36"
    }
  }
  timeouts {}
}

resource "terraform_data" "replacement" {
  count = var.isExported ? 0 : 1
  input = var.resourceGroup.name
}

locals {
  osSku = var.agentPoolProfiles[0].osSKU
}

// this is a known issue for arc aks, it need to wait for the kubernate vhd ready to deploy aks
resource "terraform_data" "waitAksVhdReady" {
  count      = var.isExported ? 0 : 1
  depends_on = [azapi_update_resource.k8sExtension]
  provisioner "local-exec" {
    command     = "powershell.exe -ExecutionPolicy Bypass -NoProfile -File ${path.module}/readiness.ps1 -customLocationResourceId ${var.customLocationId} -kubernetesVersion ${var.kubernetesVersion} -osSku ${local.osSku}"
    interpreter = ["PowerShell", "-Command"]
  }

  lifecycle {
    replace_triggered_by = [terraform_data.replacement[0]]
  }
}
