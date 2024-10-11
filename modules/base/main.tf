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
  version = "~>0.1"

  count            = var.country != "" ? 1 : 0
  enable_telemetry = var.enable_telemetry

  location              = azurerm_resource_group.rg.location
  address_resource_name = local.address_resource_name
  country               = var.country
  city                  = var.city
  company_name          = var.company_name
  postal_code           = var.postal_code
  state_or_province     = var.state_or_province
  street_address_1      = var.street_address_1
  street_address_2      = var.street_address_2
  street_address_3      = var.street_address_3
  zip_extended_code     = var.zip_extended_code
  contact_name          = var.contact_name
  email_list            = var.email_list
  mobile                = var.mobile
  phone                 = var.phone
  phone_extension       = var.phone_extension
  resource_group_id     = azurerm_resource_group.rg.id
  site_display_name     = local.site_display_name
  site_resource_name    = local.site_resource_name
}

# Prepare AD
module "hci_ad_provisioner" {
  source  = "Azure/avm-ptn-hci-ad-provisioner/azurerm"
  version = "~>0.1"

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
  version = "~>0.1"

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
  version = "~>0.8"

  depends_on       = [module.hci_server_provisioner, module.hci_ad_provisioner]
  enable_telemetry = var.enable_telemetry

  location             = azurerm_resource_group.rg.location
  name                 = local.cluster_name
  cluster_tags         = var.cluster_tags
  resource_group_id    = azurerm_resource_group.rg.id
  site_id              = var.site_id
  domain_fqdn          = var.domain_fqdn
  adou_path            = local.adou_path
  servers              = var.servers
  custom_location_name = local.custom_location_name
  eu_location          = var.eu_location
  operation_type       = var.operation_type
  configuration_mode   = var.configuration_mode

  # Network settings
  starting_address    = var.starting_address
  ending_address      = var.ending_address
  subnet_mask         = var.subnet_mask
  default_gateway     = var.default_gateway
  dns_servers         = var.dns_servers
  management_adapters = var.management_adapters

  # Intent settings
  intent_name                       = var.intent_name
  rdma_enabled                      = var.rdma_enabled
  override_adapter_property         = var.override_adapter_property
  qos_policy_overrides              = var.qos_policy_overrides
  compute_intent_name               = var.compute_intent_name
  compute_override_adapter_property = var.compute_override_adapter_property
  compute_qos_policy_overrides      = var.compute_qos_policy_overrides
  compute_rdma_enabled              = var.compute_rdma_enabled
  storage_networks                  = var.storage_networks
  storage_adapter_ip_info           = var.storage_adapter_ip_info
  storage_connectivity_switchless   = var.storage_connectivity_switchless
  storage_intent_name               = var.storage_intent_name
  storage_override_adapter_property = var.storage_override_adapter_property
  storage_qos_policy_overrides      = var.storage_qos_policy_overrides
  storage_rdma_enabled              = var.storage_rdma_enabled

  # Witness settings
  witness_path                                = var.witness_path
  witness_type                                = var.witness_type
  random_suffix                               = local.random_suffix
  create_witness_storage_account              = var.create_witness_storage_account
  witness_storage_account_name                = var.witness_storage_account_name == "" ? local.witness_storage_account_name : var.witness_storage_account_name
  witness_storage_account_resource_group_name = var.witness_storage_account_resource_group_name
  cross_tenant_replication_enabled            = var.cross_tenant_replication_enabled
  account_replication_type                    = var.account_replication_type
  allow_nested_items_to_be_public             = var.allow_nested_items_to_be_public
  azure_service_endpoint                      = var.azure_service_endpoint
  min_tls_version                             = var.min_tls_version
  storage_tags                                = var.storage_tags

  # Deployment secrets key vault settings
  use_legacy_key_vault_model                   = var.use_legacy_key_vault_model
  create_key_vault                             = var.create_key_vault
  keyvault_name                                = var.keyvault_name == "" ? local.keyvault_name : var.keyvault_name
  key_vault_location                           = var.key_vault_location
  key_vault_resource_group                     = var.key_vault_resource_group
  keyvault_tags                                = var.keyvault_tags
  keyvault_purge_protection_enabled            = var.keyvault_purge_protection_enabled
  keyvault_soft_delete_retention_days          = var.keyvault_soft_delete_retention_days
  azure_stack_lcm_user_credential_content_type = var.azure_stack_lcm_user_credential_content_type
  azure_stack_lcm_user_credential_tags         = var.azure_stack_lcm_user_credential_tags
  default_arb_application_content_type         = var.default_arb_application_content_type
  default_arb_application_tags                 = var.default_arb_application_tags
  local_admin_credential_content_type          = var.local_admin_credential_content_type
  local_admin_credential_tags                  = var.local_admin_credential_tags
  witness_storage_key_content_type             = var.witness_storage_key_content_type
  witness_storage_key_tags                     = var.witness_storage_key_tags

  # Security settings
  hvci_protection                  = var.hvci_protection
  drtm_protection                  = var.drtm_protection
  drift_control_enforced           = var.drift_control_enforced
  credential_guard_enforced        = var.credential_guard_enforced
  side_channel_mitigation_enforced = var.side_channel_mitigation_enforced
  smb_cluster_encryption           = var.smb_cluster_encryption
  smb_signing_enforced             = var.smb_signing_enforced
  bitlocker_boot_volume            = var.bitlocker_boot_volume
  bitlocker_data_volumes           = var.bitlocker_data_volumes
  wdac_enforced                    = var.wdac_enforced

  # Credentials settings
  deployment_user                = local.deployment_user_name
  deployment_user_password       = var.deployment_user_password
  local_admin_user               = var.local_admin_user
  local_admin_password           = var.local_admin_password
  service_principal_id           = var.service_principal_id
  service_principal_secret       = var.service_principal_secret
  rp_service_principal_object_id = var.rp_service_principal_object_id
}

module "hci_logicalnetwork" {
  source  = "Azure/avm-res-azurestackhci-logicalnetwork/azurerm"
  version = "~>0.4"

  depends_on       = [module.hci_cluster]
  enable_telemetry = var.enable_telemetry

  location             = azurerm_resource_group.rg.location
  resource_group_id    = azurerm_resource_group.rg.id
  custom_location_id   = module.hci_cluster.customlocation.id
  vm_switch_name       = module.hci_cluster.v_switch_name
  name                 = local.logical_network_name
  ip_allocation_method = "Static"
  logical_network_tags = var.logical_network_tags
  starting_address     = var.lnet_starting_address
  ending_address       = var.lnet_ending_address
  dns_servers          = length(var.lnet_dns_servers) == 0 ? var.dns_servers : var.lnet_dns_servers
  default_gateway      = var.lnet_default_gateway == "" ? var.default_gateway : var.lnet_default_gateway
  address_prefix       = var.lnet_address_prefix
  vlan_id              = var.lnet_vlan_id
  route_name           = var.route_name
  subnet_0_name        = var.subnet_0_name
}

module "aks_arc" {
  source  = "Azure/avm-res-hybridcontainerservice-provisionedclusterinstance/azurerm"
  version = "~>0.3"

  depends_on       = [module.hci_cluster, module.hci_logicalnetwork]
  enable_telemetry = var.enable_telemetry

  location                    = azurerm_resource_group.rg.location
  name                        = local.aks_arc_name
  resource_group_id           = azurerm_resource_group.rg.id
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
  arc_server_ids = { for server in var.servers : server.name => "${azurerm_resource_group.rg.id}/providers/Microsoft.HybridCompute/machines/${server.name}" }
}

module "hci_insights" {
  source  = "Azure/avm-ptn-azuremonitorwindowsagent/azurerm"
  version = "~>0.4"

  depends_on       = [module.hci_cluster]
  enable_telemetry = var.enable_telemetry

  count                                   = var.enable_insights ? 1 : 0
  resource_group_name                     = azurerm_resource_group.rg.name
  arc_server_ids                          = local.arc_server_ids
  arc_setting_id                          = module.hci_cluster.arc_settings.id
  data_collection_rule_resource_id        = var.data_collection_rule_resource_id
  create_data_collection_resources        = var.data_collection_rule_resource_id == "" ? true : false
  data_collection_resources_location      = azurerm_resource_group.rg.location
  data_collection_rule_name               = local.data_collection_rule_name
  data_collection_rule_tags               = var.data_collection_rule_tags
  data_collection_rule_destination_id     = var.data_collection_rule_destination_id
  data_collection_endpoint_name           = local.data_collection_endpoint_name
  data_collection_endpoint_tags           = var.data_collection_endpoint_tags
  workspace_name                          = local.workspace_name
  workspace_tags                          = var.workspace_tags
  sku                                     = var.sku
  cmk_for_query_forced                    = var.cmk_for_query_forced
  immediate_data_purge_on_30_days_enabled = var.immediate_data_purge_on_30_days_enabled
  retention_in_days                       = var.retention_in_days
  counter_specifiers                      = var.counter_specifiers
  x_path_queries                          = var.x_path_queries
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
