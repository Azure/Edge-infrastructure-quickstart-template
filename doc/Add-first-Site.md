# Add First Site

## Add your first site with static template

1. Create a branch from `main` by running `git checkout -b <yourFeatureBranch>`.
2. *(Optional)* This template predefined resource names. You can change them following [Edit Resource Naming Conventions](./Naming-Conventions.md).
> [!NOTE]
> If you connect Arc for servers by your own, the result of resource group's naming convention must be **the same** with the resource group for Arc for servers.

3. Rename `dev/sample` to `dev/<your location>`. Uncomment the sample code and then edit the variables in the `dev/<your location>/main.tf` commit and push.
4. *(Optional)* Skip this step if you haven't provisioned Arc for servers yet.

   If the Arc servers are already provisioned by yourself, go to `dev/<your location>/imports.tf` and uncomment the import block, change the placeholders to your resource group that contains the Arc servers. Open `dev/<your location>/main.tf` and add `enableProvisioners = false` in the module block.

5. Create a pull request to `main`. After approval, changes will be applied automatically. After the successful deployment, following resources will be created:
    1. A resource group name `<site>-rg`
    2. A KeyVault named `<site>-kv`: Contains secrets that used for deploy
    3. Arc servers that make up the HCI cluster
    4. A storage account used for HCI cloud witness
    5. An HCI cluster name `<site>-cl`
    6. Arc Resource Bridge named `<site>-cl-arcbridge`
    7. Custom location of ARB named `<site>-customLocation`
    8. Two storage paths named `UserStorage1`, `UserStorage2`
6. After the pull request is merged, new sites will be applied.

## Next Step

If you want to scale more site, you can [Scale with the automations](./doc/Scale-with-automation.md) or [Go back to home page](../README.md)

Learn more:

- About [your CI/CD pipeline running status](./View-pipeline.md)
- About [troubleshooting](./TroubleShooting.md)
- About [enabling arc extensions for all sites](../README.md#enable-arc-extensions-for-all-sites)
- About [adding new stage](./Customize-Stages.md)