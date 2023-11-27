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
variable "servicePricipalId" {
  description = "The id of service principal to create hci cluster."
  sensitive   = true
  type        = string
}
variable "servicePricipalSecret" {
  description = "The secret of service principal to create hci cluster."
  sensitive   = true
  type        = string
}