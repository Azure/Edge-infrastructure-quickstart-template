# Edge infrastructure quickstart template Project
  
This repository provides a simple and efficient way for customers to provision AzureStackHCI 23H2 using Terraform. By forking this repository and modifying the parameters, you can quickly and easily deploy AzureStackHCI 23H2 to your environment.  

## Prerequisites 
Follow the step2(Install OS) of this [official doc](https://learn.microsoft.com/en-us/azure-stack/hci/deploy/deployment-tool-active-directory)

## Getting Started  
  
To get started, follow these steps:  
  
1. Fork this repository to your GitHub account.  
2. Clone the forked repository to your local machine.  
3. Install [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) if not already installed.  
4. Configure your Azure account credentials by following the [Azure Provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli).  
5. Modify the variables in the `sample/main.tf` file or to fit your environment's requirements.  
  
## Usage  
  
After setting up the repository, navigate to sample folder that containing the Terraform configuration files and perform the following steps:  

0. Open a powershell as administrator, az login with the account that has proper permission.
    - the permission contains [TODO]
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
└───Module               //module used to provision hci cluster
│   │   main.tf          // deploy resource group and hci cluster
│   │   predeploy.tf     // deploy key vault/ witness storage account and assign role
|   |   validate.tf      //deploymentsetting that used to validate cluster creation parameters
|   |   deploy.tf        // deploymentsetting that used to deploy cluster, it depend on validatedeployemntsetting
│   │   ...
│   └───hciserver        // module used to onboard arc machine
│       │   connect.ps1  // script used to onboard arc
│       │   main.tf      // terraform code used to get arc machine arm resource
│       │   ...
│   
└───store0               // store folder, you can copy the folder to do manual scale
    │   main.tf          // the main file that customer need to change
    │   ...
```
The steps to provision a HCI cluster is
1. Prepare Active Directory(prerequisites)
2. Install OS to all nodes (prerequisites)
3. onboard all nodes to arc machine (done by this repo, hciserver folder)
4. create a HCI cluster and deploymentsetting (done by this repo, module folder)

this repo is utilize the cloud deployment method that build by AzureStackHCI team.

## Customizing the Deployment  
  
You can modify the module for your needs.
  
## Cleaning Up  
  
To destroy the resources created by this Terraform configuration, run `terraform destroy` in the directory containing the configuration files.  
  
  
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
