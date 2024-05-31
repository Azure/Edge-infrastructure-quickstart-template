 module "base" {
   source          = "../../modules/base"
   location        = "eastus"
   siteId          = "Arizona"
   domainFqdn      = "adaptivecloudlab.com"
   startingAddress = "172.25.117.20"
   endingAddress   = "172.25.117.29"
   defaultGateway  = "172.25.117.1"
   dnsServers      = ["10.254.0.196","10.254.0.197"]
   adouSuffix      = "OU=Hypervisors,OU=Servers,OU=Computers,OU=adaptivecloudlab,DC=adaptivecloudlab,DC=com"
   domainServerIP  = "10.254.0.196"
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


   # Region Hybrid AKS related parameters
   aksArc-controlPlaneIp = "172.25.117.221"

   // the following value only need to provide if you want to create a new logical network, if not, set aksArc-lnet-usingExistingLogicalNetwork to true and specify the existing logical network name in logicalNetworkName
   lnet-startingAddress = = "172.25.117.200"
   lnet-endingAddress   = "172.25.117.220"
   lnet-addressPrefix   = "172.25.117.0/24"
   lnet-defaultGateway  = "172.25.117.1"
   lnet-dnsServers      = ["10.254.0.196", "10.254.0.197"]
   rbacAdminGroupObjectIds     = ["be0c17dc-9a37-48c5-9691-751a27a4c1b9", "f5157bd2-8ce4-48b6-82df-69b9de7540a9", "904e7142-bfcf-4071-a326-6d798140dd03"]
   # End region of hybrid aks related parameters

   # Region site manager parameters
   # Check ./doc/Add-Site-Manager.md for more information
   # country = "United States"
   # End region site manager parameters
 }
