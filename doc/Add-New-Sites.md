# Add New Sites

## Scale new sites manually
After the first HCI deployment succeeds, you may want to scale the deployment to more sites. You can simply copy and paste your first site folder. Edit `main.tf` for each newly copied sites to the site specific values. Commit and create a pull request for the changes. Deployment pipeline and backend settings will be set during the commit. Once the pull request is merged into `main` branch, pipeline will be triggered and deploy new sites accordingly. An example could be

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

## Scale by automation (Private Preview)
> [!NOTE]
> * Please sign up our [private preview](./Private-Preview-Signup.md).

You can find spread sheets under `./.azure/scale/` if the modules is generated through export workflow [doc](./Customize-Base-Module.md).

For QuickStart template scaling, you can refer the following to generate a sample spread sheet.

### Generate a sample spread sheet to scale for **QuickStart** template

1. Set global parameters to reduce the number of configurations for one site. [Edit-Global-Parameters](./Edit-Global-Parameters.md)
2. Remove the lines have set default values in the previous step.
3. Run `az-edge-site-scale generate -c ./.azure/scale/base.csv -s ./dev/<sample-site>`

### Scale new sites by filling the spread sheet.
1. Create a new branch from `main`.
2. Copy `./.azure/scale/<module-name>.csv` to `./.azure/scale.csv`.
3. Open the CSV file by Excel. Input new values according to the first line.
4. Commit and push the CSV. The pre-commit hook will add new sites to the deployment workflow automatically.
5. After push. A workflow is triggered to create new site configurations according to the sample site with values input in the spread sheet. Create a pull request to `main`.
6. Check the workflow execution. If all succeed, you can merge the branch.
