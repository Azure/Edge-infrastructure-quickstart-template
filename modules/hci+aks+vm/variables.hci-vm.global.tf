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
