resource "tls_private_key" "rsaKey" {
  count     = var.sshPublicKey == null ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_key_vault_secret" "sshPublicKey" {
  count        = var.sshPublicKey == null ? 1 : 0
  name         = var.sshPublicKeySecretName
  key_vault_id = var.sshKeyVaultId
  value        = tls_private_key.rsaKey[0].public_key_openssh
}

resource "azurerm_key_vault_secret" "sshPrivateKeyPem" {
  count        = var.sshPublicKey == null ? 1 : 0
  name         = var.sshPrivateKeyPemSecretName
  key_vault_id = var.sshKeyVaultId
  value        = tls_private_key.rsaKey[0].private_key_pem
}

locals {
  sshPublicKey = var.sshPublicKey == null ? tls_private_key.rsaKey[0].public_key_openssh : var.sshPublicKey
}
