# Potential global variables
  variable "domainFqdn" {
    description = "The domain FQDN."
    type        = string
  }

  variable "subnetMask" {
    default     = "255.255.255.0"
    type        = string
    description = "The subnet mask for the network."
  }

  variable "defaultGateway" {
    description = "The default gateway for the network."
    type        = string
  }

  variable "dnsServers" {
    type        = list(string)
    description = "A list of DNS server IP addresses."
  }

  variable "tenant" {
    type        = string
    description = "The tenant name."
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

  variable "rdmaEnabled" {
    type        = bool
    description = "Indicates whether RDMA is enabled."
  }

  variable "storageConnectivitySwitchless" {
    type        = bool
    description = "Indicates whether storage connectivity is switchless."
  }

# Site specific variables
  variable "servers" {
    description = "A list of servers with their names and IPv4 addresses."
    type = list(object({
      name        = string
      ipv4Address = string
    }))
  }

  variable "deploymentUserName" {
    sensitive   = true
    type        = string
    description = "The username for deployment user."
  }

  variable "startingAddress" {
    description = "The starting IP address of the IP address range."
    type        = string
  }

  variable "endingAddress" {
    description = "The ending IP address of the IP address range."
    type        = string
  }

  variable "adouPath" {
    type        = string
    description = "The Active Directory OU path."
  }

# Pass through variables
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
    sensitive   = true
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
# Reference variables
  # variable "location"       "ref/main/location"
  # variable "siteId"         "ref/main/siteId"
  # variable "siteName"       "ref/main/siteName"
  # variable "subscriptionId" "ref/main/subscriptionId"
