# variable "subscriptionId" {
#   description           = "The subscription id to register this environment."
#   type                  = string
#   default               = "<subscriptionId>"
# }

# module "hci" {
#   source                = "../../modules/hci"
#   location              = "<location>"
#   siteId                = "<siteId>"
#   domainAdminUser       = "<domainAdminUser>"
#   domainAdminPassword   = "<domainAdminPassword>"
#   localAdminUser        = "<localAdminUser>"
#   localAdminPassword    = "<localAdminPassword>"
#   domainFqdn            = "<domainFqdn>"
#   startingAddress       = "<startingAddress>"
#   endingAddress         = "<endingAddress>"
#   defaultGateway        = "<defaultGateway>"
#   dnsServers            = ["<dnsServer1>"]
#   adouPath              = "<adouPath>"
#   subId                 = var.subscriptionId
#   tenant                = "<tenant>"
#   servicePricipalId     = "<servicePricipalId>"
#   servicePricipalSecret = "<servicePricipalSecret>"
#   domainServerIP        = "<domainServerIP>"
#   servers = [
#     {
#       name              = "<server1Name>",
#       ipv4Address       = "<server1Ipv4Address>"
#     },
#     {
#       name              = "<server2Name>",
#       ipv4Address       = "<server2Ipv4Address>"
#     }
#   ]
#   managementAdapters = ["<managementAdapter1>", "<managementAdapter2>"]
#   storageNetworks = [
#     {
#       name               = "Storage1Network",
#       networkAdapterName = "<storageAdapter1>",
#       vlanId             = "<storageAdapter1Vlan>"
#     },
#     {
#       name               = "Storage2Network",
#       networkAdapterName = "<storageAdapter2>",
#       vlanId             = "<storageAdapter2Vlan>"
#     }
#   ]
# }
