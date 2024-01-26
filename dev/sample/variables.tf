variable "subscriptionId" {
  description = "The subscription id to register this environment."
  type        = string
}

variable "localAdminUser" {
  description = "The username of the local administrator account."
  sensitive   = true
  type        = string
}

variable "localAdminPassword" {
  description = "The password of the local administrator account."
  sensitive   = true
  type        = string
}

variable "domainAdminUser" {
  description = "The username of the domain account."
  sensitive   = true
  type        = string
}

variable "domainAdminPassword" {
  description = "The password of the domain account."
  sensitive   = true
  type        = string
}

variable "deploymentUserName" {
  sensitive   = true
  type        = string
  description = "The username for deployment user."
}

variable "deploymentUserPassword" {
  sensitive   = true
  type        = string
  description = "The password for deployment user."
}

variable "servicePrincipalId" {
  description = "The id of service principal to create hci cluster."
  sensitive   = true
  type        = string
}

variable "servicePrincipalSecret" {
  description = "The secret of service principal to create hci cluster."
  sensitive   = true
  type        = string
}

variable "rpServicePrincipalObjectId" {
  default     = ""
  type        = string
  description = "The object ID of the HCI resource provider service principal."
}
