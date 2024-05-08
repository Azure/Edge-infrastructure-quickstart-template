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
    condition     = can(regex("^[a-zA-Z0-9-]{1,8}$", var.siteId))
    error_message = "value of siteId should be less than 9 characters and greater than 0 characters and only contain alphanumeric characters and hyphens, this is the requirement of name prefix in hci deploymentsetting"
  }
}

variable "servers" {
  description = "A list of servers with their names and IPv4 addresses."
  type = list(object({
    name        = string
    ipv4Address = string
  }))
}

variable "deploymentUser" {
  type        = string
  description = "The username for the domain administrator account."
}

variable "deploymentUserPassword" {
  sensitive   = true
  type        = string
  description = "The password for the domain administrator account."
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

variable "subscriptionId" {
  type        = string
  description = "The subscription ID for the Azure account."
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
}

variable "storageNetworks" {
  type = list(object({
    name               = string
    networkAdapterName = string
    vlanId             = string
  }))
}

variable "rdmaEnabled" {
  type        = bool
  description = "Indicates whether RDMA is enabled."
}

variable "storageConnectivitySwitchless" {
  type        = bool
  description = "Indicates whether storage connectivity is switchless."
}

variable "clusterName" {
  type = string
  description = "The name of the HCI cluster. Must be the same as the name when preparing AD."
  validation {
    condition     = length(var.clusterName) < 16 && length(var.clusterName) > 0
    error_message = "value of clusterName should be less than 16 characters and greater than 0 characters"
  }
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
