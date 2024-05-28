 module "base" {
   source          = "../../modules/base"
   location        = "eastus"
   siteId          = "Arizona"
   domainFqdn      = "adaptivecloud.com"
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
   enableProvisioners            = true      // Change to false when Arc servers are connected by yourself.
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
   aksArc-controlPlaneIp = "<aksArc-controlPlaneIp>"

   // the following value only need to provide if you want to create a new logical network, if not, set aksArc-lnet-usingExistingLogicalNetwork to true and specify the existing logical network name in logicalNetworkName
   aksArc-lnet-startingAddress = "<aksArc-lnet-startingAddress>"
   aksArc-lnet-endingAddress   = "<aksArc-lnet-endingAddress>"
   aksArc-lnet-addressPrefix   = "<aksArc-lnet-addressPrefix>"
   aksArc-lnet-defaultGateway  = "<aksArc-lnet-defaultGateway>"
   aksArc-lnet-dnsServers      = ["<aksArc-lnet-dnsServer>"]
   rbacAdminGroupObjectIds     = ["<rbacAdminGroupObjectId1>"]
   # End region of hybrid aks related parameters

   # Region site manager parameters
   # Check ./doc/Add-Site-Manager.md for more information
   country = "United States"
   # End region site manager parameters
 }