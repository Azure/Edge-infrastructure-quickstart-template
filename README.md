# Edge Infrastructure QuickStart Template
  
This repository provides a simple and efficient way for users to provision AzureStack HCI clusters in a bunch of locations using Terraform. By forking this repository and modifying the parameters, you can quickly and easily deploy AzureStack HCI to your environment.

## Prerequisites
Check deployment checklist and install AzureStack HCI OS on your servers to be deployed as AzureStack HCI clusters. Complete the step 2 (Download the software) & 3 (Install the OS) in this [doc](https://learn.microsoft.com/en-us/azure-stack/hci/deploy/download-azure-stack-hci-23h2-software). Step 1 (Prepare Active Directory) & 4 (Register with Arc and set up permissions) are covered in the project. Follow the guidance in this repository to start HCI deployments.

## Getting Started  
  
To get started, follow these steps:  
1. Create a repository base on this template.
1. [Setup pipeline](#setup-pipeline).
1. Create a branch from `main`.
1. Rename `dev/sample` to `<your location>`. Edit the variables in the `dev/<your location>/main.tf` commit and push.
1. Create a pull request to `main`. After approval, changes will be applied automatically. After the successful deployment, following resources will be created:
    1. A resource group name `<site>-rg`
    1. A KeyVault named `<site>-kv`: Contains secrets that used for deploy
    1. Arc servers that make up the HCI cluster
    1. A storage account used for HCI cloud witness
    1. An HCI cluster name `<site>-cl`
    1. Arc Resource Bridge named `<site>-cl-arcbridge`
    1. Custom location of ARB named `<site>-customLocation`
    1. Two storage paths named `UserStorage1`, `UserStorage2`
1. Add new sites by copy and paste your first site folder to others. Commit and create a pull request for new sites. After the pull request is merged, new sites will be applied.
  
## Setup Pipeline
1. Setup [OIDC service principle](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure) to allow your repository terraform environment authenticate as the service principle. The detailed steps are described in [Azure documentation](https://learn.microsoft.com/en-us/azure/developer/github/connect-from-azure?tabs=azure-portal%2Cwindows). Here's the steps:
   1. Create `terraform` environment in your GitHub repository. [Creating an environment]([https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#creating-an-environment))
   1. Create a service principal in Microsoft Entra ID [Application and service principal objects in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity-platform/app-objects-and-service-principals?tabs=browser).
   1. Add Federated credential to the service principal. Use `Environment` as entity type and input `terraform` to `Based on selection` input box.
   1. Add a secret and save it to `servicePrincipalSecret` in the repo secrets described in the next step.
   1. Grant the following permissions to the service principle in your subscription:
      - Contributor (to create resource group / KeyVault / HCI cluster...)
      - Key Vault Secrets Officer (to create secret in azure KeyVault)
      - User Access Administrator (to grant role for arc-enabled servers)
1. Setup repository secret following [Managing secrets for your repository and organization for GitHub Codespaces](https://docs.github.com/en/codespaces/managing-codespaces-for-your-organization/managing-secrets-for-your-repository-and-organization-for-github-codespaces):
    - Pipeline secrets:
        * AZURE_CLIENT_ID: The client ID of the service principle in step 1.
        * AZURE_SUBSCRIPTION_ID: The subscription ID of the service principle in step 1.
        * AZURE_TENANT_ID: The tenant ID of the service principle in step 1.
    - HCI secrets:
        * domainAdminUser
        * domainAdminPassword
        * localAdminUser
        * localAdminPassword
        * servicePrincipalId
        * servicePrincipalSecret 
1. Setup Terraform backend:
    1. Create a storage account in your Azure subscription (the same subscription as AZURE_SUBSCRIPTION_ID). Create a container in it.
    1. Open `.azure/backendTemplate.tf` in this repository. Replace `\<ResourceGroupName\>`, `\<StorageAccountName\>`, `\<StorageContainerName\>` to the storage account and container you just created.
    1. Commit `.azure/backendTemplate.tf` and push.
1. Setup git hooks:
 
    Run `git config --local core.hooksPath ./.azure/hooks/`.
    This hook will generate the pipeline definition `deploy-infra.yml` when you commit changes to this repository.
1. Setup GitHub runners.
    - If the remote PowerShell port(5985) of HCI is exposed to the Internet. Open `.github/workflows/site-cd-workflow.yml`. Modify `runs-on` section to
    ```yml
        runs-on: [ubuntu-latest]
        # runs-on: [self-hosted]
    ```
    - If your HCI nodes can be remote managed inside your CorpNet. You can [setup self-host runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners). Runner hosts must setup the following tools.
        1. Install [Git](https://git-scm.com/downloads). Add `Git` to path. Run `git --version` to validate.
        1. Add `<Git installation root>\usr\bin` to path. The default path is `C:\Program Files\Git\usr\bin`. 
        1. Install [Az CLI](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli). Run `az --version` to validate installation.
        1. Follow the first answer in [PowerShell Remoting - stackoverflow](https://stackoverflow.com/questions/18113651/powershell-remoting-policy-does-not-allow-the-delegation-of-user-credentials), finish client side settings to allow remote PowerShell HCI servers from runners.
        1. [Register self-hosted runners](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners). Make sure that the runner process is running as Administrator.

## Add new sites
After the first HCI deployment succeeds, you may want to scale the deployment to more sites. You can simply copy and paste your first site folder. Edit `main.tf` for each newly copied sites to the site specific values. Commit and create a pull request for the changes. Deployment pipeline and backend settings will be set during the commit. Once the pull request is merged into `main` branch, pipeline will be triggered and deploy new sites accordingly. An example could be
```
├───dev
│   └───firstsite
│           main.tf
│           ...
│
├───prod
│   ├───prod1
│   │       main.tf
│   │       ...
│   │
│   ├───prod2
│   │       main.tf
│   │       ...
│   │
│   └───prod3
│           main.tf
│           ...
│
└───qa
    ├───qa1
    │       main.tf
    │       ...
    │
    └───qa2
            main.tf
            ...
```

## Telemetry
Microsoft collects deployment pipeline telemetry. If you do not want to send telemetry, edit `.github/workflows/site-cd-workflow.yml`, remove all steps starts with `Telemetry`.

## Clean Up
Removing one folder will not remove the resources created by this folder previously.

You have 2 ways to cleanup if you do want to remove the resources.
- Before removing the folder, run `terraform destroy` to destroy the resources created by this Terraform configuration. Then remove this folder.
- Go to Azure portal or use CLI to remove `${siteId}-rg` resource group and remove this folder.

# Advanced

## Repo Structure
```
PROJECT_ROOT
│
├───.azure
│   │   backendTemplate.tf              // Backend storage account config file
│   │
│   └───hooks
│           pre-commit                  // Git hook to generate deployment workflow and set backend
│
├───.github
│   └───workflows
│           site-cd-workflow.yml        // Steps to deploy a single site
│
├───dev                                 // The first stage to deploy
│   └───sample
│           backend.tf
│           main.tf                     // Main configuration file for the site
│           provider.tf
│           terraform.tf
│           variables.tf
│
├───modules
│   ├───base                            // Base module of all sites
│   │       main.tf
│   │       variables.tf
│   │
│   ├───hci                             // Module to manage HCI clusters
│   │   │
│   │   └───hciserver
│   │
│   ├───hci-extensions                  // Module to manage HCI extensions
│   │
│   └───hci-vm                          // Module to manage HCI VMs
│
├───prod                                // prod stage sites are deployed after qa stage
│   │
│   └───prod1
│
└───qa                                  // qa stage sites are deployed after dev stage
    │
    └───qa1
```

## Customize The Deployment  
  
You may edit `modules/base` to customize your deployment template for all sites. You may add default values for your sites in `modules/base/variables.tf`. For example, tenant name is likely to be the same for all sites. You can add a default value for `tenant` variable.
```hcl
variable "tenant" {
  type        = string
  description = "The tenant ID for the Azure account."
  default     = "<your tennat ID>"
}
```

## Manual Apply

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
    servicePrincipalId     = "<service principal id created in the first step of setting pipeline>"
    servicePrincipalSecret = "<service principal secret created in the first step of setting pipeline>"
    ```
1. Initialize the Terraform working directory by running `terraform init`.
1. Apply the Terraform configuration and create the resources by running `terraform apply -var-file="sample.tfvars"`.
  
The above commands will provision an AzureStack HCI cluster in your Azure subscription.  

## Parameters

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
| <a name="input_servicePrincipalId"></a> [servicePrincipalId](#input\_servicePrincipalId) | The service principal ID for the Azure account. | `string` | n/a | yes |
| <a name="input_servicePrincipalSecret"></a> [servicePrincipalSecret](#input\_servicePrincipalSecret) | The service principal secret for the Azure account. | `string` | n/a | yes |
| <a name="input_siteId"></a> [siteId](#input\_siteId) | A unique identifier for the site. | `string` | n/a | yes |
| <a name="input_startingAddress"></a> [startingAddress](#input\_startingAddress) | The starting IP address of the IP address range. | `string` | n/a | yes |
| <a name="input_subId"></a> [subId](#input\_subId) | The subscription ID for the Azure account. | `string` | n/a | yes |
| <a name="input_tenant"></a> [tenant](#input\_tenant) | The tenant ID for the Azure account. | `string` | n/a | yes |
| <a name="input_destory_adou"></a> [destory\_adou](#input\_destory\_adou) | whether destroy previous adou | `bool` | `false` | no |
| <a name="input_location"></a> [location](#input\_location) | The Azure region where the resources will be deployed. | `string` | `"eastus"` | no |
| <a name="input_rp_principal_id"></a> [rp\_principal\_id](#input\_rp\_principal\_id) | The principal ID of the resource provider. | `string` | `"f0e0e122-3f80-44ed-95d2-f56e6fdc514c"` | no |
| <a name="input_subnetMask"></a> [subnetMask](#input\_subnetMask) | The subnet mask for the network. | `string` | `"255.255.255.0"` | no |

## License  
  
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.  
  
## Disclaimer  
  
This repository is provided "as-is" without any warranties or support. Use at your own risk. Always test in a non-production environment before deploying to production.  

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
