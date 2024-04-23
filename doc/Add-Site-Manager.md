
# Create a site with Arc Site Manager Terraform Module

Go to `dev/sample/main.tf` and uncomment "Region Site manager parameters". In Arc Site Manager, only country information is required, if you would like to define any optional parameters. Feel free to add them into the module block.

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

# Replicate to more sites

If you would like to replicate the above settings to more site instances, you can simply copy and paste your first site folder. Edit `main.tf` for each newly copied sites to the site specific values. Commit and create a pull request for the changes. Deployment pipeline and backend settings will be set during the commit. Once the pull request is merged into `main` branch, pipeline will be triggered and deploy new sites accordingly. The below is a sample structure.

```

├───dev
│   └───firstsite
│           main.tf
│           ...
│
├───prod
│   ├───prod1
│   │       main.tf
│   │       ...
│   │
│   ├───prod2
│   │       main.tf
│   │       ...
│   │
│   └───prod3
│           main.tf
│           ...
│
└───qa
    ├───qa1
    │       main.tf
    │       ...
    │
    └───qa2
            main.tf
            ...

```
