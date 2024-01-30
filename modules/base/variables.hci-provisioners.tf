# variable "location"               "ref/main/location"
# variable "siteId"                 "ref/main/siteId"
# variable "siteName"               "ref/main/siteName"
# variable "subscriptionId"         "ref/main/subscriptionId"
# variable "servers"                "ref/hci/servers"
# variable "deploymentUserName"     "ref/hci/deploymentUserName"
# variable "deploymentUserPassword" "ref/hci/deploymentUserPassword"
# variable "localAdminUser"         "ref/hci/localAdminUser"
# variable "localAdminPassword"     "ref/hci/localAdminPassword"
# variable "domainFqdn"             "ref/hci/domainFqdn"
# variable "adouPath"               "ref/hci/adouPath"
# variable "tenant"                 "ref/hci/tenant"
# variable "servicePrincipalId"     "ref/hci/servicePrincipalId"
# variable "servicePrincipalSecret" "ref/hci/servicePrincipalSecret"

variable "enableProvisioners" {
  type        = bool
  default     = true
  description = "Whether to enable provisioners."
}

variable "domainServerIP" {
  description = "The ip of the domain server."
  type        = string
}

variable "destory_adou" {
  description = "whether destroy previous adou"
  default     = false
  type        = bool
}

variable "domainAdminUser" {
  sensitive   = true
  type        = string
  description = "The username for the domain administrator account."
}

variable "domainAdminPassword" {
  sensitive   = true
  type        = string
  description = "The password for the domain administrator account."
}

variable "authenticationMethod" {
  type        = string
  description = "The authentication method for Enter-PSSession."
  validation {
    condition     = can(regex("^(Default|Basic|Negotiate|NegotiateWithImplicitCredential|Credssp|Digest|Kerberos)$", var.authenticationMethod))
    error_message = "Value of authenticationMethod should be {Default | Basic | Negotiate | NegotiateWithImplicitCredential | Credssp | Digest | Kerberos}"
  }
  default = "Default"
}

# Virtual host related variables
variable "virtualHostIp" {
  type        = string
  description = "The virtual host IP address."
  default     = ""
}

variable "dcPort" {
  type        = number
  description = "Domain controller winrm port in virtual host"
  default     = 5985
}

variable "serverPorts" {
  type        = map(number)
  description = "Server winrm ports in virtual host"
  default     = {}
}
