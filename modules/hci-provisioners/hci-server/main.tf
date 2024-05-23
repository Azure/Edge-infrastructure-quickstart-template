resource "terraform_data" "replacement" {
  input = var.resourceGroupName
}

resource "terraform_data" "provisioner" {
  provisioner "local-exec" {
    command = "echo Connect ${var.serverName} to Azure Arc..."
  }

  provisioner "local-exec" {
    command     = "powershell.exe -ExecutionPolicy Bypass -NoProfile -File ${path.module}/connect.ps1 -userName ${var.localAdminUser} -password \"${var.localAdminPassword}\" -authType ${var.authenticationMethod} -ip ${var.serverIP} -port ${var.winrmPort} -subscriptionId ${var.subscriptionId} -resourceGroupName ${var.resourceGroupName} -region ${var.location} -tenant ${var.tenant} -servicePrincipalId ${var.servicePrincipalId} -servicePrincipalSecret ${var.servicePrincipalSecret} -expandC ${var.expandC}"
    interpreter = ["PowerShell", "-Command"]
  }

  provisioner "local-exec" {
    command = "echo connected ${var.serverName}"
  }

  lifecycle {
    replace_triggered_by = [terraform_data.replacement]
  }
}
