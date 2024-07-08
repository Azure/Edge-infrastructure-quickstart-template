variable "rpServicePrincipalObjectId" {
  default     = ""
  type        = string
  description = "The object ID of the HCI resource provider service principal."
}

variable "deploymentUserPassword" {
  sensitive   = true
  type        = string
  description = "The password for deployment user."
}

variable "localAdminUser" {
  type        = string
  description = "The username for the local administrator account."
}

variable "localAdminPassword" {
  sensitive   = true
  type        = string
  description = "The password for the local administrator account."
}

variable "servicePrincipalId" {
  type        = string
  sensitive   = true
  description = "The service principal ID for ARB."
}

variable "servicePrincipalSecret" {
  type        = string
  sensitive   = true
  description = "The service principal secret."
}

# variable "location"       "ref/main/location"
# variable "siteId"         "ref/main/siteId"
# variable "siteName"       "ref/main/siteName"
# variable "subscriptionId" "ref/main/subscriptionId"
# variable "deploymentUser" "ref/naming/deploymentUserName"
