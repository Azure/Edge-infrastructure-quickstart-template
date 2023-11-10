variable "location" {  
  default     = "eastus"  
  description = "The Azure region where the resources will be deployed."  
}  
  
variable "rp_principal_id" {  
  default     = "f0e0e122-3f80-44ed-95d2-f56e6fdc514c"  
  description = "The principal ID of the resource provider."  
}  
  
variable "siteId" {  
  description = "A unique identifier for the site."  
}  
  
variable "servers" {  
  description = "A list of servers with their names and IPv4 addresses."  
  type        = list(object({  
    name        = string  
    ipv4Address = string  
  }))  
}  
  
variable "domainName" {  
  description = "The domain name for the environment."  
}  
  
variable "domainAdminUser" {  
  description = "The username for the domain administrator account."  
}  
  
variable "domainAdminPassword" {  
  description = "The password for the domain administrator account."  
}  
  
variable "localAdminUser" {  
  description = "The username for the local administrator account."  
}  
  
variable "localAdminPassword" {  
  description = "The password for the local administrator account."  
}  
  
variable "arbDeploymentSpnValue" {  
  description = "The service principal value for the deployment in the format '<ServicePrincipalId>:<ServicePrincipalSecret>'."  
}  
  
//deploymentSettings related variables  
variable "domainSuffix" {  
  description = "The domain FQDN is going to be '{var.siteId}.{var.domainSuffix}'."  
}  
  
variable "subnetMask" {  
  default     = "255.255.255.0"  
  description = "The subnet mask for the network."  
}  
  
variable "startingAddress" {  
  description = "The starting IP address of the IP address range."  
}  
  
variable "endingAddress" {  
  description = "The ending IP address of the IP address range."  
}  
  
variable "defaultGateway" {  
  description = "The default gateway for the network."  
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
  
variable "servicePricipalId" {  
  type        = string  
  description = "The service principal ID for the Azure account."  
}  
  
variable "servicePricipalSecret" {  
  type        = string  
  description = "The service principal secret for the Azure account."  
}  
