variable "v_cpu_count" {
  description = "Number of vCPUs"
  type        = number
  default     = 2
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 8192
}

variable "dynamic_memory" {
  description = "Enable dynamic memory"
  type        = bool
  default     = false
}

variable "dynamic_memory_max" {
  description = "Maximum memory in MB when dynamic memory is enabled"
  type        = number
  default     = 8192
}

variable "dynamic_memory_min" {
  description = "Minimum memory in MB when dynamic memory is enabled"
  type        = number
  default     = 512
}

variable "dynamic_memory_buffer" {
  description = "Buffer memory in MB when dynamic memory is enabled"
  type        = number
  default     = 20
}

variable "data_disk_params" {
  description = "The array description of the dataDisks to attach to the vm. Provide an empty array for no additional disks, or an array following the example below."
  type = map(object({
    diskSizeGB = number
    dynamic    = bool
    name       = string
  }))
  default = {}
}

variable "private_ip_address" {
  description = "The private IP address of the NIC"
  type        = string
  default     = ""
}

variable "domain_to_join" {
  description = "Optional Domain name to join - specify to join the VM to domain. example: contoso.com - If left empty, ou, username and password parameters will not be evaluated in the deployment."
  type        = string
  default     = ""
}

variable "domain_target_ou" {
  description = "Optional domain organizational unit to join. example: ou=computers,dc=contoso,dc=com - Required if 'domainToJoin' is specified."
  type        = string
  default     = ""
}

variable "domain_join_user_name" {
  description = "Optional User Name with permissions to join the domain. example: domain-joiner - Required if 'domainToJoin' is specified."
  type        = string
  default     = ""
}

variable "domain_join_password" {
  description = "Optional Password of User with permissions to join the domain. - Required if 'domainToJoin' is specified."
  type        = string
  sensitive   = true
  default     = ""
}
