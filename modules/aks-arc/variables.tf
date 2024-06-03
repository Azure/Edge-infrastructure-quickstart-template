variable "resourceGroup" {
  description = "The resource group where the resources will be deployed."
}

variable "customLocationId" {
  description = "The id of the Custom location that used to create hybrid aks"
  type        = string
}

variable "aksArcName" {
  type        = string
  description = "The name of the hybrid aks"
}

variable "logicalNetworkId" {
  description = "The id of the logical network that the AKS nodes will be connected to."
  type        = string
}

variable "controlPlaneIp" {
  type        = string
  description = "The ip address of the control plane"
}

variable "arbId" {
  type        = string
  description = "The id of the arc bridge resource, this is used to update hybrid aks extension"
}

variable "sshPublicKey" {
  type        = string
  description = "The SSH public key that will be used to access the kubernetes cluster nodes. If not specified, a new SSH key pair will be generated."
  default     = null
}

variable "sshKeyVaultId" {
  type        = string
  description = "The id of the key vault that contains the SSH public and private keys."
  default     = null
}

variable "sshPublicKeySecretName" {
  type        = string
  description = "The name of the secret in the key vault that contains the SSH public key."
  default     = "AksArcAgentSshPublicKey"
}

variable "sshPrivateKeyPemSecretName" {
  type        = string
  description = "The name of the secret in the key vault that contains the SSH private key PEM."
  default     = "AksArcAgentSshPrivateKeyPem"
}

// putting validation here is because the condition of a variable can only refer to the variable itself in terraform.
locals {
  # tflint-ignore: terraform_unused_declarations
  validateSshKeyVault = (var.sshPublicKey == null && var.sshKeyVaultId == null) ? tobool("sshPrivateKeyPemSecretName must be specified if sshPublicKey is not specified") : true
  validateSshKey      = (var.sshPublicKey == null && var.sshPrivateKeyPemSecretName == "") ? tobool("sshPrivateKeyPemSecretName must be specified if sshPublicKey is not specified") : true
  validateRbac        = (var.enableAzureRBAC == true && length(var.rbacAdminGroupObjectIds) == 0) ? tobool("At least one admin group object id must be specified") : true
}

variable "enableAzureRBAC" {
  type        = bool
  description = "Enable Azure RBAC for the kubernetes cluster"
  default     = true
}

variable "rbacAdminGroupObjectIds" {
  type        = list(string)
  description = "The object id of the admin group of the azure rbac"
  default     = []
}

variable "kubernetesVersion" {
  type        = string
  description = "The kubernetes version"
  default     = "1.28.5"

  validation {
    condition     = can(regex("^[0-9]+\\.[0-9]+\\.[0-9]+$", var.kubernetesVersion))
    error_message = "kubernetesVersion must be in the format of 'x.y.z'"
  }
}

variable "controlPlaneCount" {
  type        = number
  description = "The count of the control plane"
  default     = 1
}

variable "controlPlaneVmSize" {
  type        = string
  description = "The size of the control plane VM"
  default     = "Standard_A4_v2"
}

variable "podCidr" {
  type        = string
  description = "The CIDR range for the pods in the kubernetes cluster"
  default     = "10.244.0.0/16"
}

variable "agentPoolProfiles" {
  type = list(object({
    count             = number
    enableAutoScaling = optional(bool)
    nodeTaints        = optional(list(string))
    nodeLabels        = optional(map(string))
    maxPods           = optional(number)
    name              = optional(string)
    osSKU             = optional(string, "CBLMariner")
    osType            = optional(string, "Linux")
    vmSize            = optional(string, "Standard_A4_v2")
  }))
  description = "The agent pool profiles"

  validation {
    condition     = length(var.agentPoolProfiles) > 0
    error_message = "At least one agent pool profile must be specified"
  }

  validation {
    condition = length([
      for profile in var.agentPoolProfiles : true
      if profile.enableAutoScaling == false || profile.enableAutoScaling == null
    ]) == length(var.agentPoolProfiles)
    error_message = "Agent pool profiles enableAutoScaling is not supported yet."
  }

  validation {
    condition = length([
      for profile in var.agentPoolProfiles : true
      if profile.osType == null
      || contains(["Linux", "Windows"], profile.osType)
    ]) == length(var.agentPoolProfiles)
    error_message = "Agent pool profiles osType must be either 'Linux' or 'Windows'"
  }

  validation {
    condition = length([
      for profile in var.agentPoolProfiles : true
      if profile.osSKU == null
      || contains(["CBLMariner", "Windows2019", "Windows2022"], profile.osSKU)
    ]) == length(var.agentPoolProfiles)
    error_message = "Agent pool profiles osSKU must be either 'CBLMariner', 'Windows2019' or 'Windows2022'"
  }

  validation {
    condition = length([
      for profile in var.agentPoolProfiles : true
      if profile.osType == null || profile.osSKU == null
      || !contains(["Linux"], profile.osType) || contains(["CBLMariner"], profile.osSKU)
    ]) == length(var.agentPoolProfiles)
    error_message = "Agent pool profiles osSKU must be 'CBLMariner' if osType is 'Linux'"
  }

  validation {
    condition = length([
      for profile in var.agentPoolProfiles : true
      if profile.osType == null || profile.osSKU == null
      || !contains(["Windows"], profile.osType) || contains(["Windows2019", "Windows2022"], profile.osSKU)
    ]) == length(var.agentPoolProfiles)
    error_message = "Agent pool profiles osSKU must be 'Windows2019' or 'Windows2022' if osType is 'Windows'"
  }
}

variable "isExported" {
  type    = bool
  default = false
}
