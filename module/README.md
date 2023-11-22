<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azapi"></a> [azapi](#provider\_azapi) | n/a |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>3.0 |
| <a name="provider_random"></a> [random](#provider\_random) | ~>3.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_servers"></a> [servers](#module\_servers) | ./hciserver | n/a |

## Resources

| Name | Type |
|------|------|
| [azapi_resource.cluster1](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_resource.validatedeploymentsetting](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/resource) | resource |
| [azapi_update_resource.deploymentsetting](https://registry.terraform.io/providers/azure/azapi/latest/docs/resources/update_resource) | resource |
| [azurerm_key_vault.DeploymentKeyVault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_key_vault_secret.AzureStackLCMUserCredential](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.LocalAdminCredential](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.arbDeploymentSpnName](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_key_vault_secret.storageWitnessName](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_secret) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.ServicePrincipalRoleAssign](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.witness](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [random_id.random_id](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [terraform_data.WSManSetting](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.ad_creation_provisioner](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_adouPath"></a> [adouPath](#input\_adouPath) | The Active Directory OU path. | `string` | n/a | yes |
| <a name="input_defaultGateway"></a> [defaultGateway](#input\_defaultGateway) | The default gateway for the network. | `string` | n/a | yes |
| <a name="input_dnsServers"></a> [dnsServers](#input\_dnsServers) | A list of DNS server IP addresses. | `list(string)` | n/a | yes |
| <a name="input_domainAdminPassword"></a> [domainAdminPassword](#input\_domainAdminPassword) | The password for the domain administrator account. | `string` | n/a | yes |
| <a name="input_domainAdminUser"></a> [domainAdminUser](#input\_domainAdminUser) | The username for the domain administrator account. | `string` | n/a | yes |
| <a name="input_domainFqdn"></a> [domainFqdn](#input\_domainFqdn) | The domain FQDN. | `string` | n/a | yes |
| <a name="input_domainName"></a> [domainName](#input\_domainName) | The domain name for the environment. | `string` | n/a | yes |
| <a name="input_domainServerIP"></a> [domainServerIP](#input\_domainServerIP) | The ip of the domain server. | `string` | n/a | yes |
| <a name="input_endingAddress"></a> [endingAddress](#input\_endingAddress) | The ending IP address of the IP address range. | `string` | n/a | yes |
| <a name="input_localAdminPassword"></a> [localAdminPassword](#input\_localAdminPassword) | The password for the local administrator account. | `string` | n/a | yes |
| <a name="input_localAdminUser"></a> [localAdminUser](#input\_localAdminUser) | The username for the local administrator account. | `string` | n/a | yes |
| <a name="input_servers"></a> [servers](#input\_servers) | A list of servers with their names and IPv4 addresses. | <pre>list(object({<br>    name        = string<br>    ipv4Address = string<br>  }))</pre> | n/a | yes |
| <a name="input_servicePricipalId"></a> [servicePricipalId](#input\_servicePricipalId) | The service principal ID for the Azure account. | `string` | n/a | yes |
| <a name="input_servicePricipalSecret"></a> [servicePricipalSecret](#input\_servicePricipalSecret) | The service principal secret for the Azure account. | `string` | n/a | yes |
| <a name="input_siteId"></a> [siteId](#input\_siteId) | A unique identifier for the site. | `string` | n/a | yes |
| <a name="input_startingAddress"></a> [startingAddress](#input\_startingAddress) | The starting IP address of the IP address range. | `string` | n/a | yes |
| <a name="input_subId"></a> [subId](#input\_subId) | The subscription ID for the Azure account. | `string` | n/a | yes |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | The tenant ID for the Azure account. | `string` | n/a | yes |
| <a name="input_destory_adou"></a> [destory\_adou](#input\_destory\_adou) | whether destroy previous adou | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the resources will be deployed. | `string` | `"eastus"` | no |
| <a name="input_rp_principal_id"></a> [rp\_principal\_id](#input\_rp\_principal\_id) | The principal ID of the resource provider. | `string` | `"f0e0e122-3f80-44ed-95d2-f56e6fdc514c"` | no |
| <a name="input_subnetMask"></a> [subnetMask](#input\_subnetMask) | The subnet mask for the network. | `string` | `"255.255.255.0"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->