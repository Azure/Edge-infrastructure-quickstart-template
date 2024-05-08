# Use your naming conventions for resources

Edit `modules/base/naming.tf` for your naming conventions. The default naming for resources are

| Resource                               | Naming                       |
| -------------------------------------- | ---------------------------- |
| Resource group                         | `{siteId}-rg`                |
| Witness storage account                | `{siteId}wit`                |
| KeyVault                               | `{siteId}-kv`                |
| cluster                                | `{siteId}-cl`                |
| custom location                        | `{siteId}-customlocation`    |
| Log analytics workspace                | `{siteId}-workspace`         |
| Log analytics data collection endpoint | `{siteId}-dce`               |
| Log analytics data collection rule     | `AzureStackHCI-{siteId}-dcr` |

You may toggle whether to append random suffix for storage account and KeyVault by with `randomSuffix` local variable. If `randomSuffix` is set to true, it can avoid conflicts when storage account and KeyVault soft deletion is enabled. `randomSuffix` is a random integer from 10 to 99. The naming will changed to

| Resource                | Naming                       |
| ----------------------- | ---------------------------- |
| Resource group          | `{siteId}-rg`                |
| Witness storage account | `{siteId}wit{randomSuffix}`  |
| KeyVault                | `{siteId}-kv-{randomSuffix}` |


# Next Step
Return to [Create your first site](./Add-first-Site.md)