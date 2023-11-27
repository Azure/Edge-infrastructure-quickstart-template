//Authorize RP
locals {
  SPRoleList = [
    # "Azure Connected Machine Resource Manager",
    "User Access Administrator",
    "contributor"
  ]
}

resource "azurerm_role_assignment" "ServicePrincipalRoleAssign" {
  for_each             = toset(local.SPRoleList)
  scope                = azurerm_resource_group.rg.id
  role_definition_name = each.value
  principal_id         = var.rp_principal_id
}



data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "DeploymentKeyVault" {
  name                = "${var.siteId}-kv"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  enabled_for_deployment          = true
  enabled_for_template_deployment = true
  enabled_for_disk_encryption     = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  // arm template has enableSoftDelete": false, but terraform can't disable it after version 2.42.
  soft_delete_retention_days    = 30
  enable_rbac_authorization     = true
  public_network_access_enabled = true
  sku_name                      = "standard"

}

// TODO: Add RBAC to keyvault

resource "azurerm_key_vault_secret" "AzureStackLCMUserCredential" {
  name         = "AzureStackLCMUserCredential"
  content_type = "Secret"
  value        = base64encode("${var.domainAdminUser}:${var.domainAdminPassword}")
  key_vault_id = azurerm_key_vault.DeploymentKeyVault.id
  depends_on   = [azurerm_key_vault.DeploymentKeyVault]
}

resource "azurerm_key_vault_secret" "LocalAdminCredential" {
  name         = "LocalAdminCredential"
  content_type = "Secret"
  value        = base64encode("${var.localAdminUser}:${var.localAdminPassword}")
  key_vault_id = azurerm_key_vault.DeploymentKeyVault.id
  depends_on   = [azurerm_key_vault.DeploymentKeyVault]
}

resource "azurerm_key_vault_secret" "arbDeploymentSpnName" {
  name         = "DefaultARBApplication"
  content_type = "Secret"
  value        = base64encode("${var.servicePricipalId}:${var.servicePricipalSecret}")
  key_vault_id = azurerm_key_vault.DeploymentKeyVault.id
  depends_on   = [azurerm_key_vault.DeploymentKeyVault]
}

resource "azurerm_key_vault_secret" "storageWitnessName" {
  name         = "WitnessStorageKey"
  content_type = "Secret"
  value        = base64encode(azurerm_storage_account.witness.primary_access_key)
  key_vault_id = azurerm_key_vault.DeploymentKeyVault.id
  depends_on   = [azurerm_key_vault.DeploymentKeyVault]
}

//6. Get Arc server & assign roles to its system identity
# Get resources by type

//setup WSManCredSSP
locals {
  iplist = join(",", [for server in var.servers : server.ipv4Address])
}
resource "terraform_data" "WSManSetting" {
  depends_on = [terraform_data.ad_creation_provisioner]
  count      = var.virtualHostIp == "" ? 1 : 0
  provisioner "local-exec" {
    command     = "Enable-WSManCredSSP -Role Client -DelegateComputer ${local.iplist} -Force -ErrorAction SilentlyContinue"
    interpreter = ["PowerShell"]
  }
}

module "servers" {
  for_each = {
    for index, server in var.servers :
    server.name => server.ipv4Address
  }
  depends_on            = [azurerm_resource_group.rg, terraform_data.ad_creation_provisioner, terraform_data.WSManSetting]
  source                = "./hciserver"
  resourceGroup         = azurerm_resource_group.rg.name
  serverName            = each.key
  localAdminUser        = var.localAdminUser
  localAdminPassword    = var.localAdminPassword
  serverIP              = var.virtualHostIp == "" ? each.value : var.virtualHostIp
  winrmPort             = var.virtualHostIp == "" ? 5985 : var.serverPorts[each.key]
  subId                 = var.subId
  location              = var.location
  tenant                = var.tenant
  servicePricipalId     = var.servicePricipalId
  servicePricipalSecret = var.servicePricipalSecret
  expandC               = var.virtualHostIp == "" ? false : true
}
