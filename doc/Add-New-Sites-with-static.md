# Add New Sites with the static templates

## Step 1: Confirm and update the global configurations

In the base modules, we have prefilled the global configurations' values. Please double check the default values. If you would like to update them, follow the guidance [Edit-Global-Parameters](./Edit-Global-Parameters.md) to make the change.

## Step 2: Setting up the scaling configurations through the automations

1. Run `az-edge-site-scale generate -c ./.azure/scale/base.csv -s ./dev/<sample-site>` to get the scaling csv file. You can find a spread sheet under `./.azure/scale/`. The spread sheet contains all the entries which need customized inputs from you per site.
2. Create a new branch from `main` by running `git checkout -b <yourFeatureBranch>`
3. Copy `./.azure/scale/<module-name>.csv` to `./.azure/scale.csv`.
4. Open the CSV file by Excel. Input new values according to the first line.
5. Commit `git commit -m <commit message>`and then push the CSV `git push -u origin <yourFeatureBranch>` to the remote feature branch. The pre-commit hook will add new sites to the deployment workflow automatically.
6. After pushing to the remote branch, new scaling configurations in Terraform format will be automatically generated through our automation workflow. Create a pull request to `main`.
7. Check the workflow execution. If all jobs complete successfully, you can merge the branch to `main`.
