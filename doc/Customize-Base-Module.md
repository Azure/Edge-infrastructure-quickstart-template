# Customize Base Module

## Create a base module from an existing Azure resource group (Private Preview)
> [!NOTE]
> * Please sign up our [private preview](./Private-Preview-Signup.md).
> * Supported resources types are same as QuickStart template.
> * Ensure that resources under the resource group belong to **one** site.

1. Create a branch from `main` branch.
2. Add a new file `.azure/export.json`. Do not use `base` as the name of the module. It may carry the original contents in your exported module.
    ```json
    [
        {
            "resourceGroup": "/subscriptions/<your-subscription-id>/resourceGroups/<sample-resource-group>",
            "baseModulePath": "./modules/<name-of-the-module>",
            "groupPath": "./dev/<sample-site>"
        }
    ]
    ```
3. Commit and push `.azure/export.json`. A GitHub workflow will be triggered automatically. Create a pull request to `main`.
4. After workflow execution, check the generated code.
   - If the workflow runs successfully, the generated code is identical to Azure resources. Please merge the branch ASAP. If there are changes happened after export, the changes will be reverted.
   - If the workflow run fails, you can check `./dev/<sample-site>/export-diff` to see what are the changes.

## Ask for support
