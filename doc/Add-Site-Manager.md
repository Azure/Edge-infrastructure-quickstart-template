
# Enale Arc Site Manager to manage your resources with physical location

Go to `dev/sample/main.tf` and uncomment "Region Site manager parameters". In Arc Site Manager, only country information is required, feel free to remove any other optional parameters you don't need.

```

module "base" {
  ...

  country         = "<country>"
  city            = "<city>"
  companyName     = "<companyName>"
  postalCode      = "<postalCode>"
  stateOrProvince = "<stateOrProvince>"
  streetAddress1  = "<streetAddress1>"
  streetAddress2  = "<streetAddress2>"
  streetAddress3  = "<streetAddress3>"
  zipExtendedCode = "<zipExtendedCode>"
  contactName     = "<contactName>"
  emailList       = ["<emailList>"]
  mobile          = "<mobile>"
  phone           = "<phone>"
  phoneExtension  = "<phoneExtension>"
}

```

Then, you can submit the change and deploy through GitHub actions. After the deployment is finished, you can go to [https://aka.ms/site](https://aka.ms/site) to view your site health status. All the other resources created under the same resource group will be available in the new site.

> [!NOTE]
> We only support enabling Arc Site Manager with resource group scope in this quick-start repository.


## Next Step

[Go back to home page](../README.md)

Learn more:

- About [adding your first site with static templates](./Add-first-Site.md)
- About [your CI/CD pipeline running status](./View-pipeline.md)
- About [troubleshooting](./TroubleShooting.md)
- About [adding new sites with the customized templates](../README.md#scenario-2-convert-your-poc-site-settings-into-iac-code-then-scale-private-preview)
- About [enabling arc extensions for all sites](../README.md#enable-arc-extensions-for-all-sites)