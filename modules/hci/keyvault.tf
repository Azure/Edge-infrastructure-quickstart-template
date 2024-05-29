data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "DeploymentKeyVault" {
  name                = var.randomSuffix ? "${var.keyvaultName}-${random_integer.random_suffix.result}" : var.keyvaultName
  location            = var.resourceGroup.location
  resource_group_name = var.resourceGroup.name
  tags                = {}

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

resource "azurerm_key_vault_secret" "AzureStackLCMUserCredential" {
  name         = "AzureStackLCMUserCredential"
  content_type = "Secret"
  value        = base64encode("${var.deploymentUser}:${var.deploymentUserPassword}")
  key_vault_id = azurerm_key_vault.DeploymentKeyVault.id
  depends_on   = [azurerm_key_vault.DeploymentKeyVault]
  tags         = {}
}

resource "azurerm_key_vault_secret" "LocalAdminCredential" {
  name         = "LocalAdminCredential"
  content_type = "Secret"
  value        = base64encode("${var.localAdminUser}:${var.localAdminPassword}")
  key_vault_id = azurerm_key_vault.DeploymentKeyVault.id
  depends_on   = [azurerm_key_vault.DeploymentKeyVault]
  tags         = {}
}

resource "azurerm_key_vault_secret" "DefaultARBApplication" {
  name         = "DefaultARBApplication"
  content_type = "Secret"
  value        = base64encode("${var.servicePrincipalId}:${var.servicePrincipalSecret}")
  key_vault_id = azurerm_key_vault.DeploymentKeyVault.id
  depends_on   = [azurerm_key_vault.DeploymentKeyVault]
  tags         = {}
}

resource "azurerm_key_vault_secret" "WitnessStorageKey" {
  name         = "WitnessStorageKey"
  content_type = "Secret"
  value        = base64encode(azurerm_storage_account.witness.primary_access_key)
  key_vault_id = azurerm_key_vault.DeploymentKeyVault.id
  depends_on   = [azurerm_key_vault.DeploymentKeyVault]
  tags         = {}
}
