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