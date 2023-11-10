variable "location" {
  default = "eastus"
}

variable "rp_principal_id" {
  default     = "f0e0e122-3f80-44ed-95d2-f56e6fdc514c"
  description = ""
}

variable "siteId" {
  description = ""
}

variable "servers" {
  description = "value is a map of server names and IPs"
  type = list(object({
    name        = string
    ipv4Address = string
  }))
}

variable "domainName" {

}

variable "domainAdminUser" {

}

variable "domainAdminPassword" {

}

variable "localAdminUser" {

}

variable "localAdminPassword" {

}

variable "arbDeploymentSpnValue" {

}

//deploymentSettings related variables
variable "domainSuffix" {
  description = "The domainFqdn is going to be {var.Site_ID}.{var.domainSuffix}"
}

variable "subnetMask" {
  default = "255.255.255.0"
}

variable "startingAddress" {
}

variable "endingAddress" {
}

variable "defaultGateway" {
}

variable "dnsServers" {
  type = list(string)
}

variable "adouPath" {
  type = string
}

variable "subId" {
  type = string
}

variable "tenant" {
  type = string
}

variable "servicePricipalId" {
  type = string
}

variable "servicePricipalSecret" {
  type = string

}
