resource "azapi_update_resource" "k8sExtension" {
  type       = "Microsoft.KubernetesConfiguration/extensions@2023-05-01"
  parent_id  = var.arbId
  name       = "hybridaksextension"
  body = jsonencode({
    properties = {
      autoUpgradeMinorVersion = false
      releaseTrain            = "stable"
      version                 = "1.0.36"
    }
  })
}

resource "terraform_data" "replacement" {
  input = var.resourceGroup.name
}
// this is a known issue for arc aks, it need to wait for the kubernate vhd ready to deploy aks
resource "terraform_data" "waitAksVhdReady" {
  depends_on = [azapi_update_resource.k8sExtension]
  provisioner "local-exec" {
    command     = "powershell.exe -ExecutionPolicy Bypass -NoProfile -File ${path.module}/readiness.ps1 -customLocationResourceId ${var.customLocationId} -kubernetesVersion ${var.kubernetesVersion}"
    interpreter = ["PowerShell", "-Command"]
  }

  lifecycle {
    replace_triggered_by = [ terraform_data.replacement ]
  }
}