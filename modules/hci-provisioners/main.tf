module "servers" {
  for_each = {
    for index, server in var.servers :
    server.name => server.ipv4Address
  }
  depends_on             = [terraform_data.ad_creation_provisioner]
  source                 = "./hci-server"
  resourceGroupName      = var.resourceGroup.name
  serverName             = each.key
  localAdminUser         = var.localAdminUser
  localAdminPassword     = var.localAdminPassword
  serverIP               = var.virtualHostIp == "" ? each.value : var.virtualHostIp
  winrmPort              = var.virtualHostIp == "" ? 5985 : var.serverPorts[each.key]
  subId                  = var.subId
  location               = var.resourceGroup.location
  tenant                 = var.tenant
  servicePrincipalId     = var.servicePrincipalId
  servicePrincipalSecret = var.servicePrincipalSecret
  expandC                = var.virtualHostIp == "" ? false : true
}

/*
 * There is a bug currently with the LCM extension. It needs to wait 10-20 minutes to allow the servers to be ready before it can be deployed.
 */

resource "terraform_data" "waitServersReady" {
  depends_on = [ module.servers ]
  provisioner "local-exec" {
    command = "powershell -command sleep 1200"
  }
}

output "servers" {
  value = module.servers
}
