resource "azurerm_log_analytics_workspace" "workspace" {
  resource_group_name = var.resourceGroup.name
  location            = var.resourceGroup.location
  name                = "${var.siteId}-workspace"
}

resource "azurerm_monitor_data_collection_endpoint" "dce" {
  resource_group_name           = var.resourceGroup.name
  location                      = var.resourceGroup.location
  name                          = "${var.siteId}-dce"
  public_network_access_enabled = true
}

resource "azurerm_monitor_data_collection_rule" "dcr" {
  data_collection_endpoint_id = azurerm_monitor_data_collection_endpoint.dce.id
  location                    = var.resourceGroup.location
  name                        = "AzureStackHCI-${var.siteId}-dcr"
  resource_group_name         = var.resourceGroup.name
  data_flow {
    destinations       = ["${var.siteId}-workspace"]
    streams            = ["Microsoft-Perf"]
    built_in_transform = null
    transform_kql      = null
    output_stream      = null
  }
  data_flow {
    destinations       = ["2-90d1-e814dab6067e"]
    streams            = ["Microsoft-Event"]
    built_in_transform = null
    output_stream      = null
    transform_kql      = null
  }
  data_sources {
    performance_counter {
      counter_specifiers = [
        "\\Memory\\Available Bytes",
        "\\Network Interface(*)\\Bytes Total/sec",
        "\\Processor(_Total)\\% Processor Time",
        "\\RDMA Activity(*)\\RDMA Inbound Bytes/sec",
        "\\RDMA Activity(*)\\RDMA Outbound Bytes/sec"
      ]
      name                          = "perfCounterDataSource"
      sampling_frequency_in_seconds = 10
      streams                       = ["Microsoft-Perf"]
    }
    windows_event_log {
      name    = "eventLogsDataSource"
      streams = ["Microsoft-Event"]
      x_path_queries = [
        "Microsoft-Windows-SDDC-Management/Operational!*[System[(EventID=3000 or EventID=3001 or EventID=3002 or EventID=3003 or EventID=3004)]]",
        "microsoft-windows-health/operational!*"
      ]
    }
  }
  destinations {
    log_analytics {
      name                  = "${var.siteId}-workspace"
      workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
    }
    log_analytics {
      name                  = "2-90d1-e814dab6067e"
      workspace_resource_id = azurerm_log_analytics_workspace.workspace.id
    }
  }
}

resource "azapi_resource" "monitor_agent" {
  type      = "Microsoft.AzureStackHCI/clusters/ArcSettings/Extensions@2023-08-01"
  parent_id = var.arcSettingId
  name      = "AzureMonitorWindowsAgent"
  body = jsonencode({
    properties = {
      extensionParameters = {
        enableAutomaticUpgrade = true
        publisher              = "Microsoft.Azure.Monitor"
        type                   = "AzureMonitorWindowsAgent"
        settings               = {}
        protectedSettings      = {}
      }
    }
  })

  ignore_missing_property = true
}

resource "azurerm_monitor_data_collection_rule_association" "association" {
  for_each                    = toset(var.serverNames)
  data_collection_endpoint_id = null
  data_collection_rule_id     = azurerm_monitor_data_collection_rule.dcr.id
  description                 = null
  name = "DCRA_${md5(
    "${var.resourceGroup.id}/providers/Microsoft.HybridCompute/machines/${each.value}/${azurerm_monitor_data_collection_rule.dcr.id}"
  )}"
  target_resource_id = "${var.resourceGroup.id}/providers/Microsoft.HybridCompute/machines/${each.value}"
}
