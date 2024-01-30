# Advanced
### Edit Stages

You may create new folders to represent a stage. Put new sites under the folder. Then, open `.stages` file to add the stage into your deployment workflow. Commit the changes, the deployment pipeline will change accordingly.

### Use your naming conventions for resources

Edit `modules/base/naming.tf` for your naming conventions. The default naming for resources are

| Resource                               | Naming                       |
| -------------------------------------- | ---------------------------- |
| Resource group                         | `{siteId}-rg`                |
| Witness storage account                | `{siteId}wit`                |
| KeyVault                               | `{siteId}-kv`                |
| cluster                                | `{siteId}-cl`                |
| custom location                        | `{siteId}-customlocation`    |
| Log analytics workspace                | `{siteId}-workspace`         |
| Log analytics data collection endpoint | `{siteId}-dce`               |
| Log analytics data collection rule     | `AzureStackHCI-{siteId}-dcr` |

You may toggle whether to append random suffix for storage account and KeyVault by with `randomSuffix` local variable. If `randomSuffix` is set to true, it can avoid conflicts when storage account and KeyVault soft deletion is enabled. `randomSuffix` is a random integer from 10 to 99. The naming will changed to

| Resource                | Naming                       |
| ----------------------- | ---------------------------- |
| Resource group          | `{siteId}-rg`                |
| Witness storage account | `{siteId}wit{randomSuffix}`  |
| KeyVault                | `{siteId}-kv-{randomSuffix}` |

### Customize The Deployment  
  
You may edit `modules/base` to customize your deployment template for all sites. You may add default values for your sites in `modules/base/variables.tf`. For example, tenant name is likely to be the same for all sites. You can add a default value for `tenant` variable.
```hcl
variable "tenant" {
  type        = string
  description = "The tenant ID for the Azure account."
  default     = "<your tennat ID>"
}
```

### Manual Apply

If you want to deploy locally:

1. Create a repository base on this template.
1. Clone the forked repository to your local machine.  
1. Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) if not already installed.  
1. Make sure you have the following permissions to the subscription you want to deploy HCI clusters.
    - Contributor (to create resource group / KeyVault / HCI cluster...)
    - Key Vault Secrets Officer (to create secret in azure KeyVault)
    - User Access Administrator (to grant role for arc-enabled servers)
1. Edit `.azure/backendTemplate.tf` to use local backend.
    ```hcl
    terraform {
    backend "local" {}
    }
    ```

1. Modify the variables in the `dev/sample/main.tf` file to fit your environment's requirements.
1. Open a PowerShell as administrator, `az login` with your credentials.
1. Go to the site folder `cd dev/sample`.
1. Add `sample.tfvars` to assign values for variables.

    ```hcl
    subscriptionId         = "<your subscription id>"
    localAdminUser         = "<local admin user name>"
    localAdminPassword     = "<local admin password>"
    domainAdminUser        = "<domain admin user name>"
    domainAdminPassword    = "<domain admin user password>"
    deploymentUserName     = "<deployment user name>"
    deploymentUserPassword = "<deployment user password>"
    servicePrincipalId     = "<service principal id created in the first step of setting pipeline>"
    servicePrincipalSecret = "<service principal secret created in the first step of setting pipeline>"
    ```

1. Initialize the Terraform working directory by running `terraform init`.

1. Apply the Terraform configuration and create the resources by running `terraform apply -var-file="sample.tfvars"`.
  
The above commands will provision an AzureStack HCI cluster in your Azure subscription.

### Connect Arc servers by yourself

You can prepare AD and connect Arc servers by yourself according to [doc](https://learn.microsoft.com/en-us/azure-stack/hci/deploy/download-azure-stack-hci-23h2-software) step 1 & 4. After connecting servers, go to `<stage>/<your site>/imports.tf` and uncomment the import block, change the placeholders to your resource group that contains the Arc servers. Open `<stage>/<your site>/main.tf` and change `enableProvisioners = false`.

## Telemetry

Microsoft collects deployment pipeline telemetry. If you do not want to send telemetry, edit `.github/workflows/site-cd-workflow.yml`, remove all steps starts with `Telemetry`.

## Clean Up

Removing one folder will not remove the resources created by this folder previously.

You have 2 ways to cleanup if you do want to remove the resources.

- Before removing the folder, run `terraform destroy` to destroy the resources created by this Terraform configuration. Then remove this folder.
- Go to Azure portal or use CLI to remove `${siteId}-rg` resource group and remove this folder.