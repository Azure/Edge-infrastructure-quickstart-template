resource "terraform_data" "provisioner" {
  provisioner "local-exec" {
    command = "echo Connect ${var.serverName} to Azure Arc..."
  }

  provisioner "local-exec" {
    command = "powershell.exe -ExecutionPolicy Bypass -File ${path.module}\\connect.ps1 -userName .\\${var.localAdminUser} -password ${var.localAdminPassword} -ip ${var.serverIP} -port ${var.winrmPort} -subId ${var.subId} -resourceGroupName ${var.resourceGroup} -region ${var.location} -tenant ${var.tenant} -servicePrincipalId ${var.servicePrincipalId} -servicePrincipalSecret ${var.servicePrincipalSecret} -expandC ${var.expandC}"
  }

  provisioner "local-exec" {
    command = "echo connected ${var.serverName}"
  }
}
