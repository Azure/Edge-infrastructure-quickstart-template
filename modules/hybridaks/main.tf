resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azapi_resource" "connectedCluster" {
  type       = "Microsoft.Kubernetes/connectedClusters@2023-11-01-preview"
  depends_on = [azapi_resource.logicalNetwork, data.azapi_resource.logicalNetwork]
  name       = var.hybridAksName
  parent_id  = var.resourceGroup.id

  body = jsonencode({
    kind = "ProvisionedCluster"
    identity = {
      type = "SystemAssigned"
    }
    location = var.resourceGroup.location
    properties = {
      aadProfile = {
        adminGroupObjectIDs = var.rbacAdminGroupObjectId
        enableAzureRBAC     = var.enableAzureRBAC
        tenantID            = var.azureRBACTenantId

      }
      agentPublicKeyCertificate = "" //agentPublicKeyCertificate input must be empty for Connected Cluster of Kind: Provisioned Cluster
    }
  })

}


resource "azapi_resource" "provisionedClusterInstance" {
  type       = "Microsoft.HybridContainerService/provisionedClusterInstances@2023-11-15-preview" //2024-01-01"
  depends_on = [azapi_resource.connectedCluster]
  parent_id  = azapi_resource.connectedCluster.id
  name       = "default"
  body = jsonencode({
    extendedLocation = {
      name = var.customLocationId
      type = "CustomLocation"
    }
    properties = {
      agentPoolProfiles = [
        {
          count = var.workerCount
          enableAutoScaling = false
        },
      ]
      cloudProviderProfile = {
        infraNetworkProfile = {
          vnetSubnetIds = [
            local.logicalNetworkId,
          ]
        }
      } //"controlPlaneEndpoint": {"hostIP": "192.168.1.150"}
      controlPlane = {
        count = var.controlPlaneCount
        controlPlaneEndpoint = {
          hostIP = var.controlPlaneIp
        }
      }
      kubernetesVersion = var.kubernetesVersion
      linuxProfile = {
        ssh = {
          publicKeys = [
            {
              keyData = tls_private_key.example.public_key_openssh
            },
          ]
        }
      }
      networkProfile = {
        networkPolicy = "calico"
        loadBalancerProfile = {
          // acctest0002 network only supports a LoadBalancer count of 0
        }
      }
      storageProfile = {
        smbCsiDriver = {
          enabled = true
        }
        nfsCsiDriver = {
          enabled = true
        }
      }
      clusterVMAccessProfile = {}
      licenseProfile         = { azureHybridBenefit = "False" }
    }
  })
  schema_validation_enabled = false
  ignore_casing             = false
  ignore_missing_property   = false
}
