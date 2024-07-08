variable "vmAdminPassword" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
  default     = ""
}
