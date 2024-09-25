# module "base" {
#   source           = "../../modules/base"
#   location         = "<location>"
#   site_id          = basename(abspath(path.module))
#   domain_fqdn      = "<domainFqdn>"
#   starting_address = "<startingAddress>"
#   ending_address   = "<endingAddress>"
#   default_gateway  = "<defaultGateway>"
#   dns_servers      = ["<dnsServer1>"]
#   adou_suffix      = "<adouSuffix>"
#   dc_ip            = "<domainControllerIp>"
#   servers = [
#     {
#       name         = "<server1Name>",
#       ipv4_address = "<server1Ipv4Address>"
#     },
#     {
#       name        = "<server2Name>",
#       ipv4Address = "<server2Ipv4Address>"
#     }
#   ]
#   management_adapters = ["<managementAdapter1>", "<managementAdapter2>"]
#   storage_networks = [
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
#   rdma_enabled                    = false     // Change to true if RDMA is enabled.
#   storage_connectivity_switchless = false     // Change to true if storage connectivity is switchless.
#   enable_provisioners             = true      // Change to false when Arc servers are connected by yourself.
#   authentication_method           = "Credssp" // or "Default"
#   subscription_id                 = var.subscription_id
#   domain_admin_user               = var.domain_admin_user
#   domain_admin_password           = var.domain_admin_password
#   local_admin_user                = var.local_admin_user
#   local_admin_password            = var.local_admin_password
#   deployment_user_password        = var.deployment_user_password
#   service_principal_id            = var.service_principal_id
#   service_principal_secret        = var.service_principal_secret
#   rp_service_principal_object_id  = var.rp_service_principal_object_id

#   # Region HCI logical network parameters
#   lnet_starting_address = "<lnetStartingAddress>"
#   lnet_ending_address   = "<lnetEndingAddress>"  # This IP range should not overlap with HCI infra IP range.
#   lnet_address_prefix   = "<lnetAddressPrefix>"  # E.g., 192.168.1.0/24
#   lnet_default_gateway  = "<lnetDefaultGateway>" # Default gateway can be same as HCI infra default gateway.
#   lnet_dns_servers      = ["<lnetDnsServer1>"]   # DNS servers can be same as HCI infra DNS servers.

#   # Region AKS Arc parameters
#   aks_arc_control_plane_ip    = "<aksArcControlPlanIp>"      # An IP address in the logical network IP range.
#   rbac_admin_group_object_ids = ["<rbacAdminGroupObjectId>"] # An AAD group that will have the admin permission of this AKS Arc cluster. Check ./doc/AKS-Arc-Admin-Groups.md for details

#   # Region HCI VM parameters
#   # Uncomment this section will create a windows server VM on HCI.
#   # download_win_server_image = true
#   # vm_admin_password         = var.vm_admin_password
#   # domain_join_password      = var.domain_join_password

#   # Region site manager parameters
#   # Uncomment this section will create site manager instance for the resource group.
#   # Check ./doc/Add-Site-Manager.md for more information
#   # country = "<country>"
# }
