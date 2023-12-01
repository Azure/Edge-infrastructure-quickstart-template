<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~>3.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~>3.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~>3.0 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_role_assignment.MachineRoleAssign-1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [terraform_data.provisioner](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [azurerm_arc_machine.server](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/arc_machine) | data source |
| [azurerm_resources.arcnodes](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resources) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_localAdminPassword"></a> [localAdminPassword](#input\_localAdminPassword) | The password for the local administrator account. | `string` | n/a | yes |
| <a name="input_localAdminUser"></a> [localAdminUser](#input\_localAdminUser) | The username for the local administrator account. | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the resources will be deployed. | `string` | n/a | yes |
| <a name="input_resourceGroup"></a> [resourceGroup](#input\_resourceGroup) | The name of the resource group. | `string` | n/a | yes |
| <a name="input_serverIP"></a> [serverIP](#input\_serverIP) | The IP address of the server. | `string` | n/a | yes |
| <a name="input_serverName"></a> [serverName](#input\_serverName) | The name of the server. | `string` | n/a | yes |
| <a name="input_servicePrincipalId"></a> [servicePrincipalId](#input\_servicePrincipalId) | The service principal ID for the Azure account. | `string` | n/a | yes |
| <a name="input_servicePrincipalSecret"></a> [servicePrincipalSecret](#input\_servicePrincipalSecret) | The service principal secret for the Azure account. | `string` | n/a | yes |
| <a name="input_subId"></a> [subId](#input\_subId) | The subscription ID for the Azure account. | `string` | n/a | yes |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | The tenant ID for the Azure account. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_server"></a> [server](#output\_server) | The arc server object |
<!-- END_TF_DOCS -->