locals {
  resource_group_name           = "${var.site_id}-rg"
  site_resource_name            = length(var.site_id) < 4 ? "${var.site_id}-site" : "${var.site_id}"
  site_display_name             = var.site_id
  address_resource_name         = "${var.site_id}-address"
  deployment_user_name          = "${var.site_id}deploy"
  witness_storage_account_name  = "${lower(var.site_id)}wit"
  keyvault_name                 = "${var.site_id}-kv"
  adou_path                     = "OU=${var.site_id},${var.adou_suffix}"
  cluster_name                  = "${var.site_id}-cl"
  custom_location_name          = "${var.site_id}-customlocation"
  workspace_name                = "${var.site_id}-workspace"
  data_collection_endpoint_name = "${var.site_id}-dce"
  data_collection_rule_name     = "AzureStackHCI-${var.site_id}-dcr"
  logical_network_name          = "${var.site_id}-logicalnetwork"
  aks_arc_name                  = "${var.site_id}-aksArc"
  vm_name                       = "${var.site_id}-vm"
  vm_admin_username             = "${var.site_id}admin"
  domain_join_user_name         = "${var.site_id}vmuser"
  random_suffix                 = true
}
