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
