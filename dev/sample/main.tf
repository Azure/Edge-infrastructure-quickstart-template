# module "base" {
#   source          = "../../modules/base"
#   location        = "<location>"
#   siteId          = basename(abspath(path.module))
#   domainFqdn      = "<domainFqdn>"
#   startingAddress = "<startingAddress>"
#   endingAddress   = "<endingAddress>"
#   defaultGateway  = "<defaultGateway>"
#   dnsServers      = ["<dnsServer1>"]
#   adouSuffix      = "<adouSuffix>"
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
#   authenticationMethod          = "Credssp" // or "Default"
#   subscriptionId                = var.subscriptionId
#   domainAdminUser               = var.domainAdminUser
#   domainAdminPassword           = var.domainAdminPassword
#   localAdminUser                = var.localAdminUser
#   localAdminPassword            = var.localAdminPassword
#   deploymentUserPassword        = var.deploymentUserPassword
#   servicePrincipalId            = var.servicePrincipalId
#   servicePrincipalSecret        = var.servicePrincipalSecret
#   rpServicePrincipalObjectId    = var.rpServicePrincipalObjectId

#   # Region HCI logical network parameters
#   lnet-startingAddress = "<lnetStartingAddress>"
#   lnet-endingAddress   = "<lnetEndingAddress>"  # This IP range should not overlap with HCI infra IP range.
#   lnet-addressPrefix   = "<lnetAddressPrefix>"  # E.g., 192.168.1.0/24
#   lnet-defaultGateway  = "<lnetDefaultGateway>" # Default gateway can be same as HCI infra default gateway.
#   lnet-dnsServers      = ["<lnetDnsServer1>"]   # DNS servers can be same as HCI infra DNS servers.

#   # Region AKS Arc parameters
#   aksArc-controlPlaneIp   = "<aksArcControlPlanIp>"      # An IP address in the logical network IP range.
#   rbacAdminGroupObjectIds = ["<rbacAdminGroupObjectId>"] # An AAD group that will have the admin permission of this AKS Arc cluster. Check ./doc/AKS-Arc-Admin-Groups.md for details

#   # Region HCI VM parameters
#   # Uncomment this section will create a windows server VM on HCI.
#   # downloadWinServerImage = true
#   # vmAdminPassword        = var.vmAdminPassword
#   # domainJoinPassword     = var.domainJoinPassword

#   # Region site manager parameters
#   # Uncomment this section will create site manager instance for the resource group.
#   # Check ./doc/Add-Site-Manager.md for more information
#   # country = "<country>"
# }
