resource "tls_private_key" "rsaKey" {
  count     = var.generateSshKey ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "sshPublicKey" {
  count        = var.generateSshKey ? 1 : 0
  name         = var.sshPublicKeySecretName
  key_vault_id = var.sshKeyVaultId
  value        = tls_private_key.rsaKey[0].public_key_openssh
}

resource "azurerm_key_vault_secret" "sshPrivateKeyPem" {
  count        = var.generateSshKey ? 1 : 0
  name         = var.sshPrivateKeyPemSecretName
  key_vault_id = var.sshKeyVaultId
  value        = tls_private_key.rsaKey[0].private_key_pem
}

data "azurerm_key_vault_secret" "sshPublicKey" {
  count        = var.generateSshKey ? 0 : 1
  name         = var.sshPublicKeySecretName
  key_vault_id = var.sshKeyVaultId
}

locals {
  sshPublicKey = var.generateSshKey ? tls_private_key.rsaKey[0].public_key_openssh : data.azurerm_key_vault_secret.sshPublicKey[0].value
}
