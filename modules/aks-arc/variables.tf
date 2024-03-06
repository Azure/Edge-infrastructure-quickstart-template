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

variable "logicalNetworkName" {
  type        = string
  description = "The name of the logical network"
}

variable "controlPlaneIp" {
  type        = string
  description = "The ip address of the control plane"
}

variable "arbId" {
  type        = string
  description = "The id of the arc bridge resource, this is used to update hybrid aks extension"
}

variable "usingExistingLogicalNetwork" {
  type        = bool
  description = "Whether using existing logical network"
  default     = false
}

variable "startingAddress" {
  description = "The starting IP address of the IP address range."
  type        = string
  default     = null
}

variable "endingAddress" {
  description = "The ending IP address of the IP address range."
  type        = string
  default     = null
}

variable "defaultGateway" {
  description = "The default gateway for the network."
  type        = string
  default     = null
}

variable "dnsServers" {
  type        = list(string)
  description = "A list of DNS server IP addresses."
  default     = []
}

variable "addressPrefix" {
  type        = string
  description = "The CIDR prefix of the subnet that used by kubernetes cluster nodes, it will create VM with the ip address in this range"
  default     = null
}

variable "vlanId" {
  type        = string
  description = "The vlan id of the logical network, default means no vlan id is specified"
  default     = null
}

variable "generateSshKey" {
  type        = bool
  description = "Whether to generate a new SSH key for the cluster agent pools."
  default     = true
}

variable "sshKeyVaultId" {
  type        = string
  description = "The id of the key vault that contains the SSH public and private keys."
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
  validateSshKey = (var.generateSshKey == true && var.sshPrivateKeyPemSecretName == "") ? tobool("sshPrivateKeyPemSecretName must be specified if generateSshKey is true") : true
}

variable "enableAzureRBAC" {
  type        = bool
  description = "whether to enable azure rbac"
  default     = false
}

variable "azureRBACTenantId" {
  type        = string
  description = "The tenant id of the azure rbac"
  default     = ""
}

variable "rbacAdminGroupObjectIds" {
  type        = list(string)
  description = "The object id of the admin group of the azure rbac"
  default     = []
}

variable "kubernetesVersion" {
  type        = string
  description = "The kubernetes version"
  default     = "1.25.11"

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

variable "agentPoolProfiles" {
  type = list(object({
    count             = number
    enableAutoScaling = optional(bool, false)
    nodeTaints        = optional(list(string))
    nodeLabels        = optional(map(string))
    maxPods           = optional(number)
    name              = optional(string)
    osSKU             = optional(string, "CBLMariner")
    osType            = optional(string, "Linux")
    vmSize            = optional(string)
  }))
  description = "The agent pool profiles"

  validation {
    condition     = length(var.agentPoolProfiles) > 0
    error_message = "At least one agent pool profile must be specified"
  }

  validation {
    condition = length([
      for profile in var.agentPoolProfiles : true
      if profile.enableAutoScaling == false
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
