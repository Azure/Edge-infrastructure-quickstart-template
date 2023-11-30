locals{
    computerNameList = join(",",flatten([for server in var.servers: server.name]))
    dcIP = var.virtualHostIp == "" ? var.domainServerIP : var.virtualHostIp
}
// this is following https://learn.microsoft.com/en-us/azure-stack/hci/deploy/deployment-tool-active-directory
resource "terraform_data" "ad_creation_provisioner" {
  depends_on = [ azurerm_resource_group.rg ]

  provisioner "local-exec" {
    command = "powershell.exe -ExecutionPolicy Bypass -File ${path.module}\\ad.ps1 -userName ${var.localAdminUser} -password ${var.localAdminPassword} -ip ${local.dcIP} -port ${var.dcPort} -adouPath ${var.adouPath} -computerNames ${local.computerNameList} -domainFqdn ${var.domainFqdn} -ifdeleteadou ${var.destory_adou} -siteID ${var.siteId} -domainAdminUser ${var.domainAdminUser} -domainAdminPassword ${var.domainAdminPassword}"
  }
}