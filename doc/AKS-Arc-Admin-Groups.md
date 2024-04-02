# AKS Arc Admin Groups

## Find the groups you are a member of

Go to [Microsoft Entra admin center](https://entra.microsoft.com/#home). Select Users -> All users. Search by your name.

Click Groups under Manage. The groups that you are a member of is listed. Choose one group as the admin group. Copy the `Object Id` to `variables.aks-arc.global.tf`. Uncomment the line to set default value.

```
variable "rbacAdminGroupObjectIds" {
  description = "The object id of the Azure AD group that will be assigned the 'cluster-admin' role in the Kubernetes cluster."
  type        = list(string)
  # Add your default admin groups here. Refer to the documentation under doc/AKS-Arc-Admin-Groups.md for more information.
  default     = ["<your-admin-group-object-id>"]
}
```
