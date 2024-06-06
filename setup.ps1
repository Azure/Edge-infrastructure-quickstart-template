param (
    [string] $subscriptionId,

    [Parameter(ParameterSetName = 'Name')]
    [string] $servicePrincipalName,

    [Parameter(ParameterSetName = 'Id')]
    [string] $servicePrincipalId,

    [Parameter(ParameterSetName = 'Id')]
    [string] $servicePrincipalSecret = ""
)

$Script:ErrorActionPreference = "Stop"

# Check az and gh cli are installed
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    throw "Azure CLI is not installed. Please install it from https://aka.ms/installazurecli"
}

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw "GitHub CLI is not installed. Please install it from https://cli.github.com"
}

$gitHubRepoNameWithOwner = gh repo view --json nameWithOwner --jq ".nameWithOwner"

# Create "terraform" environment in the GitHub repo if not exists
$envExists = $false
echo "Checking if 'terraform' environment exists in the GitHub repo..."
gh api --method GET -H "Accept: application/vnd.github+json" "repos/$gitHubRepoNameWithOwner/environments/terraform"

if ($LASTEXITCODE -eq 0) {
    echo "Environment 'terraform' exists in the GitHub repo."
    $envExists = $true
}
else {
    echo "Environment 'terraform' does not exist in the GitHub repo."
}

if (-not $envExists) {
    echo "Creating 'terraform' environment in the GitHub repo..."
    gh api --method PUT -H "Accept: application/vnd.github+json" "repos/$gitHubRepoNameWithOwner/environments/terraform"
}

# Create service principal if not exists
$sp = $null

if ($servicePrincipalId) {
    $sp = az ad sp show --id $servicePrincipalId
}
else {
    if ($servicePrincipalName) {
        $sp = az ad sp create-for-rbac --name $servicePrincipalName
    }
}

if (-not $sp) {
    throw "Service principal not found or created."
}
$spid = echo $sp | ConvertFrom-Json | Select-Object -ExpandProperty appId

# Add federated credential for the service principal
echo "Adding federated credential for the service principal..."
$repoNameConverted = "${gitHubRepoNameWithOwner}" -replace "/", "_"
$jsonContent = @"
{
    "name": "${repoNameConverted}_environment_terraform",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:${gitHubRepoNameWithOwner}:environment:terraform",
    "description": "service principal for terraform environment for repo $gitHubRepoNameWithOwner",
    "audiences": [
        "api://AzureADTokenExchange"
    ]
}
"@
Set-Content $jsonContent -Path "$env:TEMP/terraformenv.json"
az ad app federated-credential create --id $spid --parameters "$env:TEMP/terraformenv.json"
$jsonContent = @"
{
    "name": "repo_${repoNameConverted}_pull_request",
    "issuer": "https://token.actions.githubusercontent.com",
    "subject": "repo:${gitHubRepoNameWithOwner}:pull_request",
    "description": "service principal for pull request for repo $gitHubRepoNameWithOwner",
    "audiences": [
        "api://AzureADTokenExchange"
    ]
}
"@
Set-Content $jsonContent -Path "$env:TEMP/pullrequest.json"
az ad app federated-credential create --id $spid --parameters "$env:TEMP/pullrequest.json"

# Assign roles for the service principal
echo "Granting permission Contributor/Key vault secrets officer/user access administrator to the service principal $spid..."
az role assignment create --role "Contributor" --assignee $spid --scope "/subscriptions/$subscriptionId"
az role assignment create --role "Key vault secrets officer" --assignee $spid --scope "/subscriptions/$subscriptionId"
az role assignment create --role "User Access Administrator" --assignee $spid --scope "/subscriptions/$subscriptionId"

if (-not $servicePrincipalSecret) {
    echo "Creating secret for the service principal..."
    $servicePrincipalSecret = (az ad app credential reset --id $spid | ConvertFrom-Json | Select-Object -ExpandProperty "password").Trim('"')
}

$hciRpOid=(az ad sp list --filter "appid eq '1412d89f-b8a8-4111-b4fd-e82905cbd85d'" --query "[0].id").Trim('"')


# Set github repo secrets
echo "Setting GitHub repo secrets..."
gh secret set AZURE_CLIENT_ID -b $spid
gh secret set AZURE_SUBSCRIPTION_ID -b $subscriptionId
gh secret set AZURE_TENANT_ID -b (az account show --query tenantId -o tsv)
gh secret set servicePrincipalId -b $spid
gh secret set servicePrincipalSecret -b $servicePrincipalSecret
gh secret set rpServicePrincipalObjectId -b $hciRpOid

$domainAdminUser = Read-Host "Enter the admin user name of domain controller. (Leave it empty if you prepare AD yourself)"
gh secret set domainAdminUser -b $domainAdminUser
$domainAdminPassword = Read-Host "Enter the admin password of domain controller. (Leave it empty if you prepare AD yourself)"
gh secret set domainAdminPassword -b $domainAdminPassword
$localAdminUser = Read-Host "Enter the local admin user name of HCI hosts."
gh secret set localAdminUser -b $localAdminUser
$localAdminPassword = Read-Host "Enter the local admin password of HCI hosts."
gh secret set localAdminPassword -b $localAdminPassword
$deploymentUserPassword = Read-Host "Enter the password for the deployment user."
gh secret set deploymentUserPassword -b $deploymentUserPassword
