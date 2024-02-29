# Getting Started for CorpNet Accessible Servers

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
5. [Setup Self Hosted Runners](./Setup-Self-Hosted-Runners.md)

## Add your first site

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
5. Add new sites by copy and paste your first site folder to others. Commit and create a pull request for new sites. After the pull request is merged, new sites will be applied.
