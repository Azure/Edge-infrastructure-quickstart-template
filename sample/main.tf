# variable "subscriptionId" {
#   description = "The subscription id for the environment."
#   type        = string
#   default     = "<subscriptionId>"
# }
# module "hci" {
#   source                = "../module"
#   location              = "<location>"
#   siteId                = "<siteId>"
#   domainName            = "<domainName>"
#   domainAdminUser       = "<domainAdminUser>"
#   domainAdminPassword   = "<domainAdminPassword>"
#   localAdminUser        = "<localAdminUser>"
#   localAdminPassword    = "<localAdminPassword>"
#   arbDeploymentSpnValue = "<arbDeploymentSpnValue>"
#   domainFqdn            = "<domainFqdn>"
#   startingAddress       = "<startingAddress>"
#   endingAddress         = "<endingAddress>"
#   defaultGateway        = "<defaultGateway>"
#   dnsServers            = ["<dnsServer1>"]
#   adouPath              = "<adouPath>"
#   servers = [
#     {
#       name        = "<server1Name>",
#       ipv4Address = "<server1Ipv4Address>"
#     },
#     {
#       name        = "<server2Name>",
#       ipv4Address = "<server2Ipv4Address>"
#     }
#   ]
#   subId                 = var.subscriptionId
#   tenant                = "<tenant>"
#   servicePricipalId     = "<servicePricipalId>"
#   servicePricipalSecret = "<servicePricipalSecret>"

#   domainServerIP = "<domainServerIP>"
#   destory_adou   = true
# }

