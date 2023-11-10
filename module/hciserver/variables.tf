variable "serverName" {  
  type        = string  
  description = "The name of the server."  
}  
  
variable "resourceGroup" {  
  type        = string  
  description = "The name of the resource group."  
}  
  
variable "localAdminUser" {  
  description = "The username for the local administrator account."  
}  
  
variable "localAdminPassword" {  
  description = "The password for the local administrator account."  
}  
  
variable "serverIP" {  
  type        = string  
  description = "The IP address of the server."  
}  
  
variable "subId" {  
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
  
variable "servicePricipalId" {  
  type        = string  
  description = "The service principal ID for the Azure account."  
}  
  
variable "servicePricipalSecret" {  
  type        = string  
  description = "The service principal secret for the Azure account."  
}  
