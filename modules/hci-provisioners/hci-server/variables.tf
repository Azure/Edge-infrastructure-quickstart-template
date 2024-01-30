variable "serverName" {
  type        = string
  description = "The name of the server."
}

variable "resourceGroupName" {
  type        = string
  description = "The name of the resource group."
}

variable "localAdminUser" {
  type        = string
  sensitive   = true
  description = "The username for the local administrator account."
}

variable "localAdminPassword" {
  type        = string
  sensitive   = true
  description = "The password for the local administrator account."
}

variable "authenticationMethod" {
  type        = string
  description = "The authentication method for Enter-PSSession."
  validation {
    condition = can(regex("^(Default|Basic|Negotiate|NegotiateWithImplicitCredential|Credssp|Digest|Kerberos)$", var.authenticationMethod))
    error_message = "Value of authenticationMethod should be {Default | Basic | Negotiate | NegotiateWithImplicitCredential | Credssp | Digest | Kerberos}"
  }
  default = "Default"
}

variable "serverIP" {
  type        = string
  description = "The IP address of the server."
}

variable "subscriptionId" {
  type        = string
  description = "The subscription ID for the Azure account."
}

variable "location" {
  type        = string
  description = "The Azure region where the resources will be deployed."
}

variable "tenant" {
  type        = string
  description = "The tenant ID for the Azure account."
}

variable "servicePrincipalId" {
  type        = string
  description = "The service principal ID for the Azure account."
}

variable "servicePrincipalSecret" {
  type        = string
  sensitive   = true
  description = "The service principal secret for the Azure account."
}

variable "winrmPort" {
  type        = number
  description = "WinRM port"
  default     = 5985
}

variable "expandC" {
  type = bool
  default = false
}
