 module "base" {
  source          = "../../modules/base"
   location        = "eastus"
   siteId          = "Arizona"
   domainFqdn      = "adaptivecloudlab.com"
   startingAddress = "172.25.117.20"
   endingAddress   = "172.25.117.29"
   defaultGateway  = "172.25.117.1"
   dnsServers      = ["10.254.0.196", "10.254.0.197"]
   adouSuffix      = "<adouSuffix>"
   domainServerIP  = "<domainServerIP>"
   servers = [
    {
       name        = "AZ-Node1",
       ipv4Address = "172.25.117.11"
     },
     {
       name        = "AZ-Node2",
       ipv4Address = "172.25.117.13"
     },
      {
       name        = "AZ-Node3",
       ipv4Address = "172.25.117.15"
     },
      {
       name        = "AZ-Node4",
       ipv4Address = "172.25.117.17"
     }
   ]
    managementAdapters = ["Port1", "Port0"]
   storageNetworks = [
     {
       name               = "Storage1Network",
       networkAdapterName = "Port0",
       vlanId             = "21"
     },
     {
       name               = "Storage2Network",
       networkAdapterName = "Port1",
       vlanId             = "22"
     }
   ]
   rdmaEnabled                   = true     // Change to true if RDMA is enabled.
   storageConnectivitySwitchless = false     // Change to true if storage connectivity is switchless.
   enableProvisioners            = false      // Change to false when Arc servers are connected by yourself.
   authenticationMethod          = "Credssp" // or "Default"
   subscriptionId                = var.subscriptionId
   domainAdminUser               = var.domainAdminUser
   domainAdminPassword           = var.domainAdminPassword
   localAdminUser                = var.localAdminUser
   localAdminPassword            = var.localAdminPassword
   deploymentUserPassword        = var.deploymentUserPassword
   servicePrincipalId            = var.servicePrincipalId
   servicePrincipalSecret        = var.servicePrincipalSecret
   rpServicePrincipalObjectId    = var.rpServicePrincipalObjectId

   # Region HCI logical network parameters
   lnet-startingAddress = "172.25.117.200"
   lnet-endingAddress   = "172.25.117.220"   //This IP range should not overlap with HCI infra IP range.
   lnet-addressPrefix   = "172.25.117.0/24"   //E.g., 192.168.1.0/24
   lnet-defaultGateway  = "172.25.117.1"  //Default gateway can be same as HCI infra default gateway.
   lnet-dnsServers      = ["10.254.0.196", "10.254.0.197"]   // DNS servers can be same as HCI infra DNS servers.

   # Region AKS Arc parameters
   aksArc-controlPlaneIp   = "172.25.117.221"       //An IP address in the logical network IP range.
   rbacAdminGroupObjectIds = ["be0c17dc-9a37-48c5-9691-751a27a4c1b9", "f5157bd2-8ce4-48b6-82df-69b9de7540a9", "904e7142-bfcf-4071-a326-6d798140dd03"] // An AAD group that will have the admin permission of this AKS Arc cluster. Check ./doc/AKS-Arc-Admin-Groups.md for details

  #  Region HCI VM parameters
  #  Uncomment this section will create a windows server VM on HCI.
    downloadWinServerImage = true
    vmAdminPassword        = var.vmAdminPassword
    domainJoinPassword     = var.domainJoinPassword

    # Region site manager parameters
    # Uncomment this section will create site manager instance for the resource group.
    # Check ./doc/Add-Site-Manager.md for more information
    # country = "<country>"
 }