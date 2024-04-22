# Manual Apply

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
    deploymentUserPassword = "<deployment user password>"
    servicePrincipalId     = "<service principal id created in the first step of setting pipeline>"
    servicePrincipalSecret = "<service principal secret created in the first step of setting pipeline>"
    ```

1. Initialize the Terraform working directory by running `terraform init`.

1. Apply the Terraform configuration and create the resources by running `terraform apply -var-file="sample.tfvars"`.
  
The above commands will provision an AzureStack HCI cluster in your Azure subscription.
