variable "location" {
  default     = "eastus"
  type        = string
  description = "The Azure region where the resources will be deployed."

  validation {
    condition     = can(regex("^(australiacentral|australiacentral2|australiaeast|australiasoutheast|brazilsouth|brazilsoutheast|brazilus|canadacentral|canadaeast|centralindia|centralus|centraluseuap|eastasia|eastus|eastus2|eastus2euap|francecentral|francesouth|germanynorth|germanywestcentral|israelcentral|italynorth|japaneast|japanwest|jioindiacentral|jioindiawest|koreacentral|koreasouth|malaysiasouth|mexicocentral|northcentralus|northeurope|norwayeast|norwaywest|polandcentral|qatarcentral|southafricanorth|southafricawest|southcentralus|southeastasia|southindia|spaincentral|swedencentral|swedensouth|switzerlandnorth|switzerlandwest|uaecentral|uaenorth|uksouth|ukwest|westcentralus|westeurope|westindia|westus|westus2|westus3|austriaeast|chilecentral|eastusslv|israelnorthwest|malaysiawest|newzealandnorth|northeuropefoundational|taiwannorth|taiwannorthwest)$", var.location))
    error_message = "supported Azure Locations:australiacentral,australiacentral2,australiaeast,australiasoutheast,brazilsouth,brazilsoutheast,brazilus,canadacentral,canadaeast,centralindia,centralus,centraluseuap,eastasia,eastus,eastus2,eastus2euap,francecentral,francesouth,germanynorth,germanywestcentral,israelcentral,italynorth,japaneast,japanwest,jioindiacentral,jioindiawest,koreacentral,koreasouth,malaysiasouth,mexicocentral,northcentralus,northeurope,norwayeast,norwaywest,polandcentral,qatarcentral,southafricanorth,southafricawest,southcentralus,southeastasia,southindia,spaincentral,swedencentral,swedensouth,switzerlandnorth,switzerlandwest,uaecentral,uaenorth,uksouth,ukwest,westcentralus,westeurope,westindia,westus,westus2,westus3,austriaeast,chilecentral,eastusslv,israelnorthwest,malaysiawest,newzealandnorth,northeuropefoundational,taiwannorth,taiwannorthwest"
  }
}

variable "rp_principal_id" {
  default     = "f0e0e122-3f80-44ed-95d2-f56e6fdc514c"
  type        = string
  description = "The principal ID of the resource provider."
}

variable "siteId" {
  type        = string
  description = "A unique identifier for the site."
  validation {
    condition = length(var.siteId) < 9 && length(var.siteId) > 0
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
