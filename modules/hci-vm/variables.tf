variable "customLocationId" {
  description = "The custom location ID for the Azure Stack HCI cluster."
  type        = string
}

variable "userStorageId" {
  description = "The user storage ID to store images."
  type        = string
  default     = ""
}

variable "resourceGroupId" {
  description = "The resource group ID for the Azure Stack HCI cluster."
  type        = string
}

variable "location" {
  description = "The Azure region where the resources will be deployed."
  type        = string
}

variable "vmName" {
  description = "Name of the VM resource"
  type        = string

  validation {
    condition     = length(var.vmName) > 0
    error_message = "The vmName cannot be empty"
  }

  validation {
    condition     = length(var.vmName) <= 15
    error_message = "The vmName must be less than or equal to 15 characters"
  }

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]*$", var.vmName))
    error_message = "The vmName must contain only alphanumeric characters and hyphens"
  }
}

variable "vCPUCount" {
  description = "Number of vCPUs"
  type        = number
  default     = 2
}

variable "memoryMB" {
  description = "Memory in MB"
  type        = number
  default     = 8192
}

variable "dynamicMemory" {
  description = "Enable dynamic memory"
  type        = bool
  default     = false
}

variable "dynamicMemoryMax" {
  description = "Maximum memory in MB when dynamic memory is enabled"
  type        = number
  default     = 8192
}

variable "dynamicMemoryMin" {
  description = "Minimum memory in MB when dynamic memory is enabled"
  type        = number
  default     = 512
}

variable "dynamicMemoryBuffer" {
  description = "Buffer memory in MB when dynamic memory is enabled"
  type        = number
  default     = 20
}

variable "imageId" {
  description = "The name of a Marketplace Gallery Image already downloaded to the Azure Stack HCI cluster. For example: winServer2022-01"
  type        = string
}

variable "logicalNetworkId" {
  description = "The ID of the logical network to use for the NIC."
  type        = string
}

variable "adminUsername" {
  description = "Admin username"
  type        = string

  validation {
    condition     = length(var.adminUsername) > 0
    error_message = "The adminUsername cannot be empty"
  }
}

variable "adminPassword" {
  description = "Admin password"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.adminPassword) > 0
    error_message = "The adminPassword cannot be empty"
  }
}

variable "domainToJoin" {
  description = "Optional Domain name to join - specify to join the VM to domain. example: contoso.com - If left empty, ou, username and password parameters will not be evaluated in the deployment."
  type        = string
  default     = ""
}

variable "domainTargetOu" {
  description = "Optional domain organizational unit to join. example: ou=computers,dc=contoso,dc=com - Required if 'domainToJoin' is specified."
  type        = string
  default     = ""
}

variable "domainJoinUserName" {
  description = "Optional User Name with permissions to join the domain. example: domain-joiner - Required if 'domainToJoin' is specified."
  type        = string
  default     = ""
}

variable "domainJoinPassword" {
  description = "Optional Password of User with permissions to join the domain. - Required if 'domainToJoin' is specified."
  type        = string
  sensitive   = true
  default     = ""
}

variable "dataDiskParams" {
  description = "The array description of the dataDisks to attach to the vm. Provide an empty array for no additional disks, or an array following the example below."
  type = list(object({
    diskSizeGB = number
    dynamic    = bool
  }))
  default = []
}

variable "privateIPAddress" {
  description = "The private IP address of the NIC"
  type        = string
  default     = ""
}
