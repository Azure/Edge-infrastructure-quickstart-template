variable "servers" {
  type = list(object({
    name        = string
    ipv4Address = string
  }))
  description = "A list of servers with their names and IPv4 addresses."
}

variable "starting_address" {
  description = "The starting IP address of the IP address range."
  type        = string
}

variable "ending_address" {
  description = "The ending IP address of the IP address range."
  type        = string
}
