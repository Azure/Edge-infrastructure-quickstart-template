# Edge Infrastructure QuickStart Template (Preview)

## Introduction

This repository offers a simple solution with static infrastructure templates to set up your multiple edge locations, designed for ease of use. Scale effortlessly to multiple sites with a comprehensive stage-by-stage management pipeline.

By using this template, you can get 1) a scalable and extendible repository structure following the best practice, 2) organized variables with the recommended values to boost your initial setup, and 3) a customizable CD pipeline with automations.

> [!NOTE]
> This repository is designed for setting up IaC for a site composed of specific resources (AKS Arc, HCI23H2, Arc extensions). Setting up Terraform code for individual resource is not covered in the supported scenarios. (However, feel free to use this repository as a starting point to explore).  

<details>

<summary><b>Repo Structure</b></summary>

<img src="doc/img/repoStructure.png" alt="repoStructure" width="800"/>

```PROJECT_ROOT
│
├───.azure
│   │   backendTemplate.tf              // Backend storage account config file
│   │
│   └───hooks
│           pre-commit                  // Git hook to generate deployment workflow and set backend
│
├───.github
│   └───workflows
│           site-cd-workflow.yml        // Set up CD pipeline
|           terraform-plan.yml
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
│   │
│   ├───hci-extensions                  // Module to manage HCI extensions                                                                     
│   ├───hci-provisioners                // Module to connect servers to Arc
│   │───aks-arc                         // Module to manage AKS Arc clusters
│   └───hci-vm                          // Module to manage HCI VMs
│   └───site-manager                    // Module to manage site-manager
│
├───prod                                // prod stage sites are deployed after qa stage
│   │
│   └───prod1
│
└───qa                                  // qa stage sites are deployed after dev stage
    │
    └───qa1
```

Base module contains the global variables across all sites. Each stage and each site folder contains the local variables specific to the stage/site. Local settings can override the global settings.

</details>

<details>

<summary><b>Variables Structure</b></summary>

| Variable Type           | Description                                                                                                     | Example             | Where to set value                                                                                       | Override Priority |
| ----------------------- | --------------------------------------------------------------------------------------------------------------- | ------------------- | -------------------------------------------------------------------------------------------------------- | :---------------: |
| Global Variables        | The values of the global variables typically are consistent across the whole fleet but specific for one product | `domainFqdn` in HCI | Set in `modules/base/<product>.hci.global.tf`. Add default value for variables.                          |        low        |
| Site specific variables | The values of these variables are unique in each site                                                           | `siteId`            | These variables must be set in the site `main.tf` file under each site folder                            |       high        |
| Pass through variables  | The values of these variables are inherited from GitHub secrets                                                 | `subscriptionId`    | `modules/base/<product>.hci.misc.tf`                                                                     |                   |
| Reference variables     | These variables are shared by 2 or more products                                                                | `location`          | Its definition can be found in `variables.<product>.*.tf` if its link is `ref/<product>/<variable_name>` |                   |

</details>

## Supported edge resources**

- [Azure Stack HCI, version 23H2](https://learn.microsoft.com/en-us/azure-stack/hci/whats-new)
- [Azure Stack HCI extensions](https://learn.microsoft.com/en-us/azure-stack/hci/manage/arc-extension-management?tabs=azureportal)
- [Azure Kubernetes Service (AKS) enabled by Azure Arc](https://learn.microsoft.com/en-us/azure/aks/hybrid/)
- [Arc Site Manager](https://review.learn.microsoft.com/en-us/azure/azure-arc/site-manager/overview?branch=release-preview-site-manager)

## Getting started

Getting started tutorials help you to configure a GitHub repository to create your first site.

This repository implements AD preparation and Arc connection. If you want to take advantage of this you may refer:

- If your servers are exposed to Corpnet only: [Getting-Started-Corpnet](./doc/Getting-Started-Corpnet.md)
- If your servers are exposed to Internet: [Getting-Started-Internet](./doc/Getting-Started-Internet.md)

Otherwise, you need to finish AD preparation and connect servers to Arc by yourself for all sites. Then, HCI and AKS provisioning can follow [Getting-Started-Self-Connect](./doc/Getting-Started-Self-Connect.md)

## Scale more sites

This repository will help you set up the scaling configuration code quickly and get ready for scaling the fleet. You have the two options: setting up the scaling configurations by yourself or you can use our automation pipeline to accelerate the repository set up along with custom settings. It's recommended to understand how the repository is structured so that you can have better understanding on the changes you made.

### User workflow diagram

<img src="doc/img/IaCGithubAction.png" alt="IaCGithubAction"/>

### Option 1: Set up the scaling configurations with the static templates

This option will create one resource group containing 1 HCI cluster, 1 AKS Arc cluster and the optional monitoring Arc extenion and Arc site manager for each site.

If you are ready to scale the above settings to the multiple sites, please go to [Add New Sites with the static templates](./doc/Add-New-Sites-with-static.md).
If you would like to change the global parameters for all sites in the future. Go to [Edit Global Parameters](./doc/Edit-Global-Parameters.md).

### Option 2: Set up the scaling configurations with the customized templates (Private Preview)

This feature is currently in Private Preview. Please contact arcIaCSupport@microsoft.com to signup for Private Preview and get the access. We will send you two SAS tokens to download the Automation binaries.

This option will customize the base module for scaling settings, E.g., add more AKS clusters, customize your HCI cluster settings automatically, please go to [Add-New-Sites-with-automation](./doc/Add-New-Sites-with-automation.md) for the details.

## Enable Arc extensions for all sites

Any change merged into `main` branch will trigger the update pipeline. If the change fails in early stages, the deployment will be blocked so that this failure will not affect the production sites.

Following tutorials help you to turn on opt-in features:

- [Add HCI Insights](./doc/Add-HCI-Insights.md)
- [Add New Sites with Arc Site Manager](./doc/Add-Site-Manager.md)

## Advanced topics

- [Customize Stages](./doc/Customize-Stages.md)
- [Disable Telemetry](./doc/Disable-Telemetry.md)
- [Untrack Resources from The Repository](./doc/Untrack-Resources.md)
- [View your CI/CD pipeline running status](./doc/View-pipeline.md)
- [TroubleShoot](./doc/TroubleShooting.md)

## Ask for support

[Open issue](https://github.com/Azure/Edge-infrastructure-quickstart-template/issues/new) or contact arcIaCSupport@microsoft.com for any issue or support

## License  
  
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.  
  
## Disclaimer  

'Preview Terms'. This repository (the "Preview") is subject to the [Supplemental Terms of Use for Microsoft Azure Previews](https://azure.microsoft.com/en-us/support/legal/preview-supplemental-terms/). Unless otherwise noted, Customer should not use the Preview to process Personal Data or other Data that is subject to legal or regulatory compliance requirements.

'Confidentiality'.The Preview and any associated materials or documentation are confidential information and subject to obligations in your Non-Disclosure Agreement with Microsoft.

This repository is provided "as-is" without any warranties or support. Use at your own risk. Always test in a non-production environment before deploying to production.  

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit [Microsoft opensource](https://cla.opensource.microsoft.com).

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
