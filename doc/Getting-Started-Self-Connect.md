# Getting Started for Self Connected Servers
## Prerequisites

Finish 1-4 steps in [Azure Stack HCI, version 23H2 deployment](https://learn.microsoft.com/en-us/azure-stack/hci/deploy/deployment-introduction). This repository is an alternative way to deploy HCI. This repository can also provision more products like AKS on HCI.

## Setup

1. [Create a repository based on this template](./Create-Repository.md)
2. [Connect GitHub Actions and Azure](./Connect-Azure.md)
3. [Configure Local Git](./Configure-Local-Git.md)
4. [Setup Terraform Backend](./Setup-Terraform-Backend.md)
5. [Use GitHub Hosted Runners](./Use-GitHub-Hosted-Runners.md)

## Add your first site

1. Create a branch from `main`.
2. (**Important**) This template predefined resource names. You need to change them following [Edit Resource Naming Conventions](./Naming-Conventions.md). Especially the resource group name must be same as the resource group when you connect servers to Azure Arc.
3. Rename `dev/sample` to `<your location>`. Edit the variables in the `dev/<your location>/main.tf` commit and push.
4. Go to `dev/<your location>/imports.tf` and uncomment the import block, change the placeholders to your resource group that contains the Arc servers. Open `dev/<your location>/main.tf` and add `enableProvisioners = false` in the module block.
5. Create a pull request to `main`. After approval, changes will be applied automatically. After the successful deployment, following resources will be created:
    1. A resource group name `<site>-rg`
    2. A KeyVault named `<site>-kv`: Contains secrets that used for deploy
    3. Arc servers that make up the HCI cluster
    4. A storage account used for HCI cloud witness
    5. An HCI cluster name `<site>-cl`
    6. Arc Resource Bridge named `<site>-cl-arcbridge`
    7. Custom location of ARB named `<site>-customLocation`
    8. Two storage paths named `UserStorage1`, `UserStorage2`
6. Add new sites by copy and paste your first site folder to others. Commit and create a pull request for new sites. After the pull request is merged, new sites will be applied.
