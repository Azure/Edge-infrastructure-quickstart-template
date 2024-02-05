locals {
  computerNameList = join(",", flatten([for server in var.servers : server.name]))
  dcIP             = var.virtualHostIp == "" ? var.domainServerIP : var.virtualHostIp
}
// this is following https://learn.microsoft.com/en-us/azure-stack/hci/deploy/deployment-tool-active-directory
resource "terraform_data" "ad_creation_provisioner" {
  provisioner "local-exec" {
    command     = "powershell.exe -ExecutionPolicy Bypass -NoProfile -File ${path.module}/ad.ps1 -userName ${var.domainAdminUser} -password \"${var.domainAdminPassword}\" -authType ${var.authenticationMethod} -ip ${local.dcIP} -port ${var.dcPort} -adouPath ${var.adouPath} -computerNames ${local.computerNameList} -domainFqdn ${var.domainFqdn} -ifdeleteadou ${var.destory_adou} -siteID ${var.siteId} -clusterName ${var.clusterName} -deploymentUserName ${var.deploymentUserName} -deploymentUserPassword \"${var.deploymentUserPassword}\""
    interpreter = ["PowerShell", "-Command"]
  }

  lifecycle {
    replace_triggered_by = [terraform_data.replacement]
  }
}
