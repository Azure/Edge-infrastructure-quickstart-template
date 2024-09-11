resource "azurerm_resource_group" "rg" {
  depends_on = [
    data.external.lnet_ip_check
  ]
  name     = local.resource_group_name
  location = var.location
  tags = {
    siteId = var.site_id
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

data "azurerm_client_config" "current" {}

module "edge_site" {
  source  = "Azure/avm-res-edge-site/azurerm"
  version = "~>0.0"

  enable_telemetry = var.enable_telemetry

  location              = azurerm_resource_group.rg.location
  address_resource_name = local.address_resource_name
  country               = var.country
  resource_group_id     = azurerm_resource_group.rg.id
  site_display_name     = local.site_display_name
  site_resource_name    = local.site_resource_name
}

# Prepare AD
module "hci_ad_provisioner" {
  source  = "Azure/avm-ptn-hci-ad-provisioner/azurerm"
  version = "~>0.0"

  count            = var.enable_provisioners ? 1 : 0
  enable_telemetry = var.enable_telemetry

  resource_group_name      = azurerm_resource_group.rg.name
  dc_port                  = var.dc_port
  dc_ip                    = var.dc_ip
  authentication_method    = var.authentication_method
  domain_fqdn              = var.domain_fqdn
  deployment_user_password = var.deployment_user_password
  domain_admin_user        = var.domain_admin_user
  domain_admin_password    = var.domain_admin_password
  deployment_user          = local.deployment_user_name
  adou_path                = local.adou_path
}

# Prepare arc server
module "hci_server_provisioner" {
  source  = "Azure/avm-ptn-hci-server-provisioner/azurerm"
  version = "~>0.0"

  for_each = var.enable_provisioners ? {
    for index, server in var.servers :
    server.name => server.ipv4Address
  } : {}

  enable_telemetry = var.enable_telemetry

  name                     = each.key
  resource_group_name      = azurerm_resource_group.rg.name
  local_admin_user         = var.local_admin_user
  local_admin_password     = var.local_admin_password
  authentication_method    = var.authentication_method
  server_ip                = var.virtual_host_ip == "" ? each.value : var.virtual_host_ip
  winrm_port               = var.virtual_host_ip == "" ? 5985 : var.server_ports[each.key]
  subscription_id          = var.subscription_id
  location                 = azurerm_resource_group.rg.location
  tenant                   = data.azurerm_client_config.current.tenant_id
  service_principal_id     = var.service_principal_id
  service_principal_secret = var.service_principal_secret
}

module "hci_cluster" {
  source  = "Azure/avm-res-azurestackhci-cluster/azurerm"
  version = "~>0.0"

  depends_on       = [module.hci_server_provisioner, module.hci_ad_provisioner]
  enable_telemetry = var.enable_telemetry

  location                        = azurerm_resource_group.rg.location
  name                            = local.cluster_name
  resource_group_name             = azurerm_resource_group.rg.name
  site_id                         = var.site_id
  domain_fqdn                     = var.domain_fqdn
  starting_address                = var.starting_address
  ending_address                  = var.ending_address
  subnet_mask                     = var.subnet_mask
  default_gateway                 = var.default_gateway
  dns_servers                     = var.dns_servers
  adou_path                       = local.adou_path
  servers                         = var.servers
  management_adapters             = var.management_adapters
  storage_networks                = var.storage_networks
  rdma_enabled                    = var.rdma_enabled
  storage_connectivity_switchless = var.storage_connectivity_switchless
  custom_location_name            = local.custom_location_name
  witness_storage_account_name    = local.witness_storage_account_name
  keyvault_name                   = local.keyvault_name
  random_suffix                   = local.random_suffix
  deployment_user                 = local.deployment_user_name
  deployment_user_password        = var.deployment_user_password
  local_admin_user                = var.local_admin_user
  local_admin_password            = var.local_admin_password
  service_principal_id            = var.service_principal_id
  service_principal_secret        = var.service_principal_secret
  rp_service_principal_object_id  = var.rp_service_principal_object_id
}

module "hci_logicalnetwork" {
  source  = "Azure/avm-res-azurestackhci-logicalnetwork/azurerm"
  version = "~>0.0"

  depends_on       = [module.hci_cluster]
  enable_telemetry = var.enable_telemetry

  location            = azurerm_resource_group.rg.location
  name                = local.logical_network_name
  resource_group_name = azurerm_resource_group.rg.name
  resource_group_id   = azurerm_resource_group.rg.id
  custom_location_id  = module.hci_cluster.customlocation.id
  vm_switch_name      = module.hci_cluster.v_switch_name
  starting_address    = var.lnet_starting_address
  ending_address      = var.lnet_ending_address
  dns_servers         = length(var.lnet_dns_servers) == 0 ? var.dns_servers : var.lnet_dns_servers
  default_gateway     = var.lnet_default_gateway == "" ? var.default_gateway : var.lnet_default_gateway
  address_prefix      = var.lnet_address_prefix
  vlan_id             = var.lnet_vlan_id
}

module "aks_arc" {
  source  = "Azure/avm-res-hybridcontainerservice-provisionedclusterinstance/azurerm"
  version = "~>0.0"

  depends_on       = [module.hci_cluster, module.hci_logicalnetwork]
  enable_telemetry = var.enable_telemetry

  location                    = azurerm_resource_group.rg.location
  name                        = local.aks_arc_name
  resource_group_name         = azurerm_resource_group.rg.name
  custom_location_id          = module.hci_cluster.customlocation.id
  logical_network_id          = module.hci_logicalnetwork.resource_id
  agent_pool_profiles         = var.agent_pool_profiles
  ssh_key_vault_id            = module.hci_cluster.keyvault.id
  control_plane_ip            = var.aks_arc_control_plane_ip
  kubernetes_version          = var.kubernetes_version
  control_plane_count         = var.control_plane_count
  rbac_admin_group_object_ids = var.rbac_admin_group_object_ids
}

locals {
  server_names = [for server in var.servers : server.name]
}

module "hci_insights" {
  source  = "Azure/avm-ptn-azuremonitorwindowsagent/azurerm"
  version = "~>0.2"

  depends_on       = [module.hci_cluster]
  enable_telemetry = var.enable_telemetry

  count                            = var.enable_insights ? 1 : 0
  resource_group_name              = azurerm_resource_group.rg.name
  server_names                     = local.server_names
  arc_setting_id                   = module.hci_cluster.arc_settings.id
  data_collection_rule_resource_id = var.data_collection_rule_resource_id
  create_data_collection_resources = var.data_collection_rule_resource_id == "" ? true : false
  data_collection_rule_name        = local.data_collection_rule_name
  data_collection_endpoint_name    = local.data_collection_endpoint_name
  workspace_name                   = local.workspace_name
}

resource "azapi_resource" "hci_alerts" {
  depends_on = [module.hci_cluster]
  count      = var.enable_alerts && var.enable_insights ? 1 : 0
  type       = "Microsoft.AzureStackHCI/clusters/ArcSettings/Extensions@2023-08-01"
  parent_id  = module.hci_cluster.arc_settings.id
  name       = "AzureEdgeAlerts"
  body = {
    properties = {
      extensionParameters = {
        enableAutomaticUpgrade  = true
        autoUpgradeMinorVersion = false
        publisher               = "Microsoft.AzureStack.HCI.Alerts"
        type                    = "AlertsForWindowsHCI"
        settings                = {}
      }
    }
  }
}

resource "azapi_resource" "hci_win_image" {
  count     = var.download_win_server_image ? 1 : 0
  type      = "Microsoft.AzureStackHCI/marketplaceGalleryImages@2023-09-01-preview"
  name      = "winServer2022-01"
  parent_id = azurerm_resource_group.rg.id
  location  = var.location
  timeouts {
    create = "24h"
    delete = "60m"
  }
  lifecycle {
    ignore_changes = [
      body.properties.version.properties.storageProfile.osDiskImage
    ]
  }
  body = {
    properties = {
      containerId      = null
      osType           = "Windows"
      hyperVGeneration = "V2"
      identifier = {
        publisher = "MicrosoftWindowsServer"
        offer     = "WindowsServer"
        sku       = "2022-datacenter-azure-edition"
      }
      version = {
        name = "20348.2113.231109"
        properties = {
          storageProfile = {
            osDiskImage = {
            }
          }
        }
      }
    }
    extendedLocation = {
      name = module.hci_cluster.customlocation.id
      type = "CustomLocation"
    }
  }
}

module "hci-vm" {
  count                 = var.download_win_server_image ? 1 : 0
  source                = "Azure/avm-res-azurestackhci-virtualmachineinstance/azurerm"
  version               = "~>0.1"
  depends_on            = [azapi_resource.hci_win_image]
  location              = azurerm_resource_group.rg.location
  custom_location_id    = module.hci_cluster.customlocation.id
  resource_group_name   = azurerm_resource_group.rg.name
  name                  = local.vm_name
  image_id              = one(azapi_resource.hci_win_image).id
  logical_network_id    = module.hci_logicalnetwork.resource_id
  admin_username        = local.vm_admin_username
  admin_password        = var.vm_admin_password
  v_cpu_count           = var.v_cpu_count
  memory_mb             = var.memory_mb
  dynamic_memory        = var.dynamic_memory
  dynamic_memory_max    = var.dynamic_memory_max
  dynamic_memory_min    = var.dynamic_memory_min
  dynamic_memory_buffer = var.dynamic_memory_buffer
  data_disk_params      = var.data_disk_params
  private_ip_address    = var.private_ip_address
  domain_to_join        = var.domain_to_join
  domain_target_ou      = var.domain_target_ou
  domain_join_user_name = var.domain_join_user_name
  domain_join_password  = var.domain_join_password
}
