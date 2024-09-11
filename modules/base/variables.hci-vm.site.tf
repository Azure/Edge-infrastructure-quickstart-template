variable "vm_admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
  default     = ""
}
