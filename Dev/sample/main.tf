# module "base" {
#   source          = "../../modules/base"
#   location        = "<location>"
#   siteId          = "<siteId>"
#   domainFqdn      = "<domainFqdn>"
#   startingAddress = "<startingAddress>"
#   endingAddress   = "<endingAddress>"
#   defaultGateway  = "<defaultGateway>"
#   dnsServers      = ["<dnsServer1>"]
#   adouPath        = "<adouPath>"
#   tenant          = "<tenant>"
#   domainServerIP  = "<domainServerIP>"
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
#   subId                  = var.subscriptionId
#   domainAdminUser        = var.domainAdminUser
#   domainAdminPassword    = var.domainAdminPassword
#   localAdminUser         = var.localAdminUser
#   localAdminPassword     = var.localAdminPassword
#   servicePrincipalId     = var.servicePrincipalId
#   servicePrincipalSecret = var.servicePrincipalSecret
# }
