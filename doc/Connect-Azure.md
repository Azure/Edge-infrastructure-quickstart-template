# Connect GitHub Actions and Azure Using interactive Script

## Steps

1. Install Az in your devbox
2. [download](https://github.com/Azure/Edge-infrastructure-quickstart-template/releases/download/v0.0.1/connect_azure_script.ps1) the interactive script
3. Run 
```
git clone https://github.com/<YourRepositoryOwner>/<YourRepositoryName>
cd <YourRepositoryName>
../connect_azure_script.ps1 -subscriptionId <YourSubscription>
```

## Script Walk through
This script is signed script and will do following things
1. Auth with GitHub and az
2. Check if the repository has terraform Git environment, if not, create it.
3. Ask if you want to create a service principal for provisioning resources to Azure from this repository
   1. if Yes(default), script will create a new service principal and setup fedration crendential to allow the repository action access the service principal
   2. if No, you need to provide the client id of the existing service principal, the script will not set the fedration crendential for you
4. The script will help to set repository secret, it will ask you to provide some values like local admin user name of HCI hosts.

---
Next Step: [Configure Local Git](./Configure-Local-Git.md)