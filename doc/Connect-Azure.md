# Connect GitHub Actions and Azure

## Setup [OIDC service principle](https://docs.github.com/en/actions/deployment/security-hardening-your-deployments/configuring-openid-connect-in-azure)

Create `terraform` environment in your GitHub repository

<img src="img/CreateRepoEnv.png" alt="createRepoEnv" width="800"/>

Go to [Microsoft Entra Admin Center](https://entra.microsoft.com/#home) to create a service principal. Click **Applications** in the menu bar and then click **App Registrations** to list all the available service principals. Create a new one for IaC

<img src="img/SP1.png" alt="SP1" width="800"/>

Add **Federated credential** to the service principal.

<img src="img/IaCCredentials.png" alt="IaCCredential" width="800"/>

Select `Environment` as entity type and input `terraform` to `Based on selection` input box

<img src="img/CreateCredentials.png" alt="CreateCredential" width="800"/>

Add a **secret** into the service principal, then, save it to `servicePrincipalSecret`. We will need it in your IaC repository.

<img src="img/AddSecretes.png" alt="AddSecretes" width="800"/>

## Grant permissions for the service principal

Grant the following permissions

- Contributor (to create resource group / KeyVault / HCI cluster...)
- Key Vault Secrets Officer (to create secret in Azure KeyVault)
- User Access Administrator (to grant role for Arc-enabled servers)

Go back to your Azure subscription page in Azure portal, select **IAM** -> **Add Role Assignment**, then grant the permissions as follows

<img src="img/roleAssignment1.png" alt="assignRole1" width="800"/>

<img src="img/assignRole2.png" alt="assignRole2" width="800"/>

<img src="img/SelectMembers.png" alt="assignRole3" width="800"/>

## Setup GitHub repo secrets

Go to your GitHub repository, click repository **Settings** , then go to **Secrets and variables**, select **Actions** to create **New repository secret**

Set up the following secrets：

1. Pipeline secrets:

    - AZURE_CLIENT_ID: The client ID of the service principle in step 1.
    - AZURE_SUBSCRIPTION_ID: The subscription ID of the service principle in step 1.
    - AZURE_TENANT_ID: The tenant ID of the service principle in step 1.

2. HCI secrets:

    - domainAdminUser: create a new user name
    - domainAdminPassword: create new password
    - localAdminUser: username when you login to the local host
    - localAdminPassword: password you use to login into the local host
    - deploymentUserName
    - deploymentUserPassword
    - servicePrincipalId
    - servicePrincipalSecret

<img src="img/repoSecrets.png" alt="RepoSecrets" width="800"/>
