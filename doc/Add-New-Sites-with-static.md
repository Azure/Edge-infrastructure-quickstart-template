# Add New Sites with the static templates

## Step 1: Prerequisites

1. Add `EXPORT_SAS` and `SCALE_SAS` to your GitHub repo secrets correspondingly.
2. Download the binaries to run locally
3. Open `https://aka.ms/az-edge-module-export-linux-amd64?<EXPORT_SAS>` to download `az-edge-module-export-linux-amd64`. Rename to `az-edge-module-export` and add to PATH.
4. Open `https://aka.ms/az-edge-site-scale-linux-amd64?<SCALE_SAS>` to download `az-edge-site-scale-linux-amd64`. Rename to `az-edge-site-scale` and add to PATH.

## Step 2: Confirm and update the global configurations

In the base modules, we have prefilled the global configurations' values. Please double check the default values. If you would like to update them, follow the guidance [Edit-Global-Parameters](./Edit-Global-Parameters.md) to make the change.

## Step 3: Setting up the scaling configurations through the automations

1. Create a new branch from `main` by running `git checkout -b <yourFeatureBranch>`
2. Run `az-edge-site-scale generate -c ./.azure/scale.csv -s ./dev/<yourSiteName>` to get the scaling csv file. You can find a spread sheet under `./.azure`. The spread sheet contains all the entries which need customized inputs from you per site.
4. Open the scale.csv file by Excel. Input new values according to the first line.
5. Commit `git commit -m <commit message>`and then push the CSV `git push -u origin <yourFeatureBranch>` to the remote feature branch. The pre-commit hook will add new sites to the deployment workflow automatically.
6. After pushing to the remote branch, new scaling configurations in Terraform format will be automatically generated through our automation workflow. Create a pull request to `main`.
[TODO: add snapshot to view the changed file]
7. Check the workflow execution. If all jobs complete successfully, you can merge the branch to `main`.
[TODO: add snapshot to check workflow execution]

## Next Step:
Learn more:
- About [view your CI/CD pipeline running status](./View-pipeline.md)
- About [troubleShoot](./TroubleShooting.md)
- About [enable arc extensions for all sites](../README.md#enable-arc-extensions-for-all-sites)