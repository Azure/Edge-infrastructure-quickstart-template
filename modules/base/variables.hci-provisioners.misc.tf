# Pass through variables
variable "domain_admin_user" {
  type        = string
  description = "The username for the domain administrator account."
}

variable "domain_admin_password" {
  # sensitive   = true
  type        = string
  description = "The password for the domain administrator account."
}

# Virtual host related variables
variable "virtual_host_ip" {
  type        = string
  description = "The virtual host IP address."
  default     = ""
}

variable "dc_port" {
  type        = number
  description = "Domain controller winrm port in virtual host"
  default     = 5985
}

variable "server_ports" {
  type        = map(number)
  description = "Server winrm ports in virtual host"
  default     = {}
}


# Reference variables
# variable "location"                 "ref/main/location"
# variable "site_id"                  "ref/main/site_id"
# variable "site_name"                "ref/main/site_name"
# variable "subscription_id"          "ref/main/subscription_id"
# variable "servers"                  "ref/hci/servers"
# variable "deployment_user"          "ref/hci/deployment_user"
# variable "deployment_user_password" "ref/hci/deployment_user_password"
# variable "local_admin_user"         "ref/hci/local_admin_user"
# variable "local_admin_password"     "ref/hci/local_admin_password"
# variable "domain_fqdn"              "ref/hci/domain_fqdn"
# variable "adou_path"                "ref/hci/adou_path"
# variable "tenant"                   "ref/hci/tenant"
# variable "service_principal_id"     "ref/hci/service_principal_id"
# variable "service_principal_secret" "ref/hci/service_principal_secret"
