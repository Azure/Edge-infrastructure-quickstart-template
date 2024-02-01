# Untrack Resources

Removing one folder will not remove the resources created by this folder previously.

You have 2 ways to cleanup if you do want to remove the resources.

- Before removing the folder, run `terraform destroy` to destroy the resources created by this Terraform configuration. Then remove this folder.
- Go to Azure portal or use CLI to remove `${siteId}-rg` resource group and remove this folder.