variable "rp_service_principal_object_id" {
  default     = ""
  type        = string
  description = "The object ID of the HCI resource provider service principal."
}

variable "deployment_user_password" {
  sensitive   = true
  type        = string
  description = "The password for deployment user."
}

variable "local_admin_user" {
  type        = string
  description = "The username for the local administrator account."
}

variable "local_admin_password" {
  sensitive   = true
  type        = string
  description = "The password for the local administrator account."
}

variable "service_principal_id" {
  type        = string
  sensitive   = true
  description = "The service principal ID for ARB."
}

variable "service_principal_secret" {
  type        = string
  sensitive   = true
  description = "The service principal secret."
}

# variable "location"       "ref/main/location"
# variable "siteId"         "ref/main/siteId"
# variable "siteName"       "ref/main/siteName"
# variable "subscriptionId" "ref/main/subscriptionId"
# variable "deploymentUser" "ref/naming/deploymentUserName"
