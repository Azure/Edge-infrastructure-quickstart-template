variable "resourceGroup" {
  description = "The resource group where the resources will be deployed."
}

variable "rpServicePrincipalObjectId" {
  default     = ""
  type        = string
  description = "The object ID of the HCI resource provider service principal."
}

variable "siteId" {
  type        = string
  description = "A unique identifier for the site."
  validation {
    condition     = length(var.siteId) < 9 && length(var.siteId) > 0
    error_message = "value of siteId should be less than 9 characters and greater than 0 characters"
  }
}

variable "servers" {
  description = "A list of servers with their names and IPv4 addresses."
  type = list(object({
    name        = string
    ipv4Address = string
  }))
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

variable "localAdminUser" {
  sensitive   = true
  type        = string
  description = "The username for the local administrator account."
}

variable "localAdminPassword" {
  sensitive   = true
  type        = string
  description = "The password for the local administrator account."
}

//deploymentSettings related variables  
variable "domainFqdn" {
  description = "The domain FQDN."
  type        = string
}

variable "subnetMask" {
  default     = "255.255.255.0"
  type        = string
  description = "The subnet mask for the network."
}

variable "startingAddress" {
  description = "The starting IP address of the IP address range."
  type        = string
}

variable "endingAddress" {
  description = "The ending IP address of the IP address range."
  type        = string
}

variable "defaultGateway" {
  description = "The default gateway for the network."
  type        = string
}

variable "dnsServers" {
  type        = list(string)
  description = "A list of DNS server IP addresses."
}

variable "adouPath" {
  type        = string
  description = "The Active Directory OU path."
}

variable "subId" {
  type        = string
  description = "The subscription ID for the Azure account."
}

variable "tenant" {
  type        = string
  description = "The tenant ID for the Azure account."
}

variable "servicePrincipalId" {
  type        = string
  sensitive   = true
  description = "The service principal ID for the Azure account."
}

variable "servicePrincipalSecret" {
  type        = string
  sensitive   = true
  description = "The service principal secret for the Azure account."
}

variable "managementAdapters" {
  type    = list(string)
  default = ["ethernet", "ethernet 2"]
}

variable "storageNetworks" {
  type = list(object({
    name               = string
    networkAdapterName = string
    vlanId             = string
  }))
}

variable "clusterName" {
  type = string
  description = "The name of the HCI cluster. Must be the same as the name when preparing AD."
}

variable "customLocationName" {
  type = string
  description = "The name of the custom location."
}

variable "keyvaultName" {
  type        = string
  description = "The name of the key vault."
}

variable "witnessStorageAccountName" {
  type        = string
  description = "The name of the witness storage account."
}

variable "randomSuffix" {
  type    = bool
  default = true
}

variable "isExported" {
  type    = bool
  default = false
}
