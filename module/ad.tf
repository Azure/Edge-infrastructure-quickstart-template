locals{
    computerNameList = flatten([for server in var.servers: server.name])
}

resource "terraform_data" "ad_creation_provisioner" {

  provisioner "local-exec" {
    command = "powershell.exe -ExecutionPolicy Bypass -File ${path.module}\\ad.ps1 -userName .\\${var.domainAdminUser} -password ${var.domainAdminPassword} -ip ${var.adou_ip} -adouPath ${var.adouPath} -computerNameList ${local.computerNameList} --domainSuffix ${var.domainSuffix} -ifdeleteadou ${var.destory_adou}"
  }
}