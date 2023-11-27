# Edge infrastructure quickstart template Project
  
This repository provides a simple and efficient way for customers to provision AzureStackHCI 23H2 using Terraform. By forking this repository and modifying the parameters, you can quickly and easily deploy AzureStackHCI 23H2 to your environment.  

## Prerequisites 
Follow the step2(Install OS) of this [official doc](https://learn.microsoft.com/en-us/azure-stack/hci/deploy/deployment-tool-active-directory)

## Getting Started  
  
To get started, follow these steps:  
1. Create a repository base on this template.
2. [Setup CICD](https://github.com/Azure/Edge-infrastructure-quickstart-template/tree/main#setup-cicd).
3. Modify the variables Modify the variables in the `Dev/sample/main.tf` file and commit.

If you don't want CICD:
1. Create a repository base on this template.
2. Clone the forked repository to your local machine.  
3. Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) if not already installed.  
4. Configure your Azure account credentials by following the [Azure Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli).  
5. Modify the variables in the `Dev/sample/main.tf` file or to fit your environment's requirements.  
  
## Setup CICD
1. Setup [OIDC service principle](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure) to allow your repository terraform environment can access the service principle , the principle will be run terraform apply in pipeline. the service principle need to grant following roles:
    1. Contributor(to create resource group/keyvault/HCIcluster...)
    1. Key Vault Secrets Officer(to create secret in azure keyvault)
    1. User Access Administrator(to grant role for arc-enabled server)
4. If the remote powershell port(5985)node of HCI is accessible from the Internet or you want to skip prepare AD and onboard arc-server part, you don't need this, otherwise you need to [setup self-host runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners) for your repo, the self host runner need able to access 5985 port of your ad server and hci nodes.
2. Setup repository secret:
    * domainAdminUser
    * domainAdminPassword
    * localAdminUser
    * localAdminPassword
    * servicePricipalId
    * servicePricipalSecret 
    * AZURE_CLIENT_ID: The client ID of the service principle in step 1.
    * AZURE_SUBSCRIPTION_ID: The subscription ID of the service principle in step 1.
    * AZURE_TENANT_ID: The tenant ID of the service principle in step 1.
3. Setup terraform storage account backend in .azure/backendTemplate.tf file, using a exist storage account of Azure_Subscription_ID, change following:
    * ResourceGroupName
    * StorageAccountName
    * StorageContainerName
5. Prepare git hooks, using the command to setup github hooks, every time you commit, it recreate the github action for you.
 
`Git config --local core.hooksPath ./.azure/hooks/`

after setup, everytime you push cotents to main branch, it will automatically trigger infrasture update workflow. If your hci nodes can't accessible from the Internet, you need to register yout accessible machine as [self-host runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners)


## Usage - manual apply
  
After setting up the repository, navigate to sample folder that containing the Terraform configuration files and perform the following steps:  

0. Open a powershell as administrator, az login with the account that has proper permission over the subscription.
    - the permission contains Key Vault Administrator and Owner.
    - you can also use service principal, refer to the [Authenticating using a Service Principal with a Client Secret](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret).
1. Initialize the Terraform working directory by running `terraform init`.  
2. Plan and review the resources to be created by running `terraform plan`.  
3. Apply the Terraform configuration and create the resources by running `terraform apply`.  
  
The above commands will provision AzureStackHCI 23H2 in your Azure environment.  

## Output after terraform apply
1. A resource group name [SiteID]-rg
2. A HCI cluster name [SiteID]-cl
3. A Resource Bridge named [SIteID]-cl-arcbridge
4. A Custom location named [SiteID]-customLocation
5. arc servers that make up the HCI cluster
4. A KeyVault named [SiteID]-kv: Contains secrets that used for deploy
5. A storage account used for witness
6. 2 storage accounts used for HCI storage path

## Scale
if you want to provision multiple HCI, you need to create a folder and copy the the 3 tf file from store0, modify these variables in main.tf. and then run these terraform steps in the new folder. 
Our infrasture as code automation service will help to automate these steps:)

## Technical detail of this repository
```
project
│   README.md
└───Module                   // folders that contain terraform module
|   └───Base                 // the base module of customer, customer can change the module manually 
|   └───hci                  // the microsoft maintained module, used to create a hci cluster
│       │   main.tf          // deploy resource group and hci cluster
│       │   predeploy.tf     // deploy key vault/ witness storage account and assign role
|       |   validate.tf      // deploymentsetting that used to validate cluster creation parameters
|       |   deploy.tf        // deploymentsetting that used to deploy cluster, it depend on validatedeployemntsetting
│       │   ...
│       └───hciserver        // module used to onboard arc machine
│           │   connect.ps1  // script used to onboard arc
│           │   main.tf      // terraform code used to get arc machine arm resource
│           │   ...
│   
└───Dev                      // dev stage folder, contains store folders, all store in this folders will be in Dev stage
    └───sample               // sample store
        │   main.tf          // the main file that customer need to change
        │   ...
└───QA                       // QA stage folder, contains store folders, all store in this folders will be in QA stage
└───Prod                     // prod stage folder, contains store folders, all store in this folders will be in Prod stage
```

The stage in the repo has following running sequence
```
Dev -> QA(after all store in Dev run successfully) -> Prod(after all store in QA run successfully)
```
The steps to provision a HCI cluster is

1. Install OS to all nodes (prerequisites)
2. Prepare Active Directory(done by this repo, hciserver folder)
3. onboard all nodes to arc machine (done by this repo, hciserver folder)
4. create a HCI cluster and deploymentsetting (done by this repo, module folder)

this repo is utilize the cloud deployment method that build by AzureStackHCI team.

## Customizing the Deployment  
  
You can modify the module for your needs.
  
## Cleaning Up  
  
To destroy the resources created by this Terraform configuration, run `terraform destroy` in the directory containing the configuration files.  

To remove git hooks
`git config --unset core.hookspath`
  
  
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
