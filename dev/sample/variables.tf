variable "subscription_id" {
  description = "The subscription id to register this environment."
  type        = string
}

variable "local_admin_user" {
  description = "The username of the local administrator account."
  sensitive   = true
  type        = string
}

variable "local_admin_password" {
  description = "The password of the local administrator account."
  sensitive   = true
  type        = string
}

variable "domain_admin_user" {
  description = "The username of the domain account."
  sensitive   = true
  type        = string
}

variable "domain_admin_password" {
  description = "The password of the domain account."
  sensitive   = true
  type        = string
}

variable "deployment_user_password" {
  sensitive   = true
  type        = string
  description = "The password for deployment user."
}

variable "service_principal_id" {
  description = "The id of service principal to create hci cluster."
  sensitive   = true
  type        = string
}

variable "service_principal_secret" {
  description = "The secret of service principal to create hci cluster."
  sensitive   = true
  type        = string
}

variable "rp_service_principal_object_id" {
  default     = ""
  type        = string
  description = "The object ID of the HCI resource provider service principal."
}

variable "vm_admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
  default     = ""
}

variable "domain_join_password" {
  description = "Password of User with permissions to join the domain."
  type        = string
  sensitive   = true
  default     = ""
}
