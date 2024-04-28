# Getting Started for Internet Accessible Servers
## Prerequisites

Before you get started, here are the steps you need to perform for prerequisites:

- Check deployment checklist and install AzureStack HCI OS on your servers to be deployed as AzureStack HCI clusters
- Complete the step 2 (Download the software) & 3 (Install the OS) in this [doc](https://learn.microsoft.com/en-us/azure-stack/hci/deploy/download-azure-stack-hci-23h2-software).
- **Make sure `Remote management` section is `Enabled`.**
![Remote management](./img/remoteManagement.png)

<mark>Step 1 (Prepare Active Directory) & 4 (Register with Arc and set up permissions) are covered in the project.</mark>

## Setup

1. [Create a repository based on this template](./Create-Repository.md)
2. [Connect GitHub Actions and Azure](./Connect-Azure.md)
3. [Configure Local Git](./Configure-Local-Git.md)
4. [Setup Terraform Backend](./Setup-Terraform-Backend.md)
5. [Use GitHub Hosted Runners](./Use-GitHub-Hosted-Runners.md)

## Add your first site with customized template (private preview)
If you already have HCI resources, you can skip the following and go to [create template based on your own resource and scale with automations (private preview)](./Add-New-Sites-with-automation.md).

## Add your first site with static template


1. Create a branch from `main`.
2. (Optional) This template predefined resource names. You can change them following [Edit Resource Naming Conventions](./Naming-Conventions.md).
3. Rename `dev/sample` to `<your location>`. Edit the variables in the `dev/<your location>/main.tf` commit and push.
4. Create a pull request to `main`. After approval, changes will be applied automatically. After the successful deployment, following resources will be created:
    1. A resource group name `<site>-rg`
    2. A KeyVault named `<site>-kv`: Contains secrets that used for deploy
    3. Arc servers that make up the HCI cluster
    4. A storage account used for HCI cloud witness
    5. An HCI cluster name `<site>-cl`
    6. Arc Resource Bridge named `<site>-cl-arcbridge`
    7. Custom location of ARB named `<site>-customLocation`
    8. Two storage paths named `UserStorage1`, `UserStorage2`
5. After the pull request is merged, new sites will be applied.

If you want to scale more site, you can [add new sites with the static templates](./Add-New-Sites-with-static.md).
## Next Step:
Learn more:
- About [view your CI/CD pipeline running status](./View-pipeline.md)
- About [troubleShoot](./TroubleShooting.md)
- About [add new sites with the static templates](./Add-New-Sites-with-static.md)
- About [add new sites with the customized templates](./Add-New-Sites-with-automation.md)
- About [enable arc extensions for all sites](../README.md#enable-arc-extensions-for-all-sites)