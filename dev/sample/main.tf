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
#   rdmaEnabled                   = false     // Change to true if RDMA is enabled.
#   storageConnectivitySwitchless = false     // Change to true if storage connectivity is switchless.
#   enableProvisioners            = true      // Change to false when Arc servers are connected by yourself.
#   authenticationMethod          = "CredSSP" // or "Default"
#   subscriptionId                = var.subscriptionId
#   domainAdminUser               = var.domainAdminUser
#   domainAdminPassword           = var.domainAdminPassword
#   localAdminUser                = var.localAdminUser
#   localAdminPassword            = var.localAdminPassword
#   deploymentUserName            = var.deploymentUserName
#   deploymentUserPassword        = var.deploymentUserPassword
#   servicePrincipalId            = var.servicePrincipalId
#   servicePrincipalSecret        = var.servicePrincipalSecret
#   rpServicePrincipalObjectId    = var.rpServicePrincipalObjectId


# # Region Hybrid AKS related parameters
#   aksArc-controlPlaneIp                   = "<aksArc-controlPlaneIp>"

#   // the following value only need to provide if you want to create a new logical network, if not, set aksArc-lnet-usingExistingLogicalNetwork to true and specify the existing logical network name in logicalNetworkName
#   aksArc-lnet-startingAddress             = "<aksArc-lnet-startingAddress>"
#   aksArc-lnet-endingAddress               = "<aksArc-lnet-endingAddress>"
#   aksArc-lnet-addressPrefix               = "<aksArc-lnet-addressPrefix>"
#   aksArc-lnet-defaultGateway              = "<aksArc-lnet-defaultGateway>"
#   aksArc-lnet-dnsServers                  = ["<aksArc-lnet-dnsServer>"]
# # end region of hybrid aks related parameters
# }
