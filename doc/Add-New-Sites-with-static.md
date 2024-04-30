# Add New Sites with the static templates

## Step 1: Confirm and update the global configurations

In the base modules, we have prefilled the global configurations' values. Please double check the default values. If you would like to update them, follow the guidance [Edit-Global-Parameters](./Edit-Global-Parameters.md) to make the change.

## Step 2: Setting up the scaling configurations through the automations

1. Create a new branch from `main` by running `git checkout -b <yourFeatureBranch>`
2. Run `./az-edge-site-scale generate -c ./.azure/scale.csv -s ./dev/<yourSiteName>` to get the scaling csv file. You can find a spread sheet under `./.azure`. The spread sheet contains all the entries which need customized inputs from you per site.
3. Open the scale.csv file by Excel. Input new values according to the first line.
4. Commit `git commit -m <commit message>`and then push the CSV `git push -u origin <yourFeatureBranch>` to the remote feature branch. The pre-commit hook will add new sites to the deployment workflow automatically.
5. After pushing to the remote branch, new scaling configurations in Terraform format will be automatically generated through our automation workflow. Create a pull request to `main`. You can view the workflow execution in action panel.
<img src="./img/view_scale_workflow_in_action_panel.png" width="800" />

6. After the workflow execution finished, you can check the files changed by the automation workflow. If all jobs complete successfully, you can merge the branch to `main`.
<img src="./img/view_commit_for_scale.png" width="600" />

## Next Step

[Go back to home page](../README.md)

Learn more:

* About [view your CI/CD pipeline running status](./View-pipeline.md)
* About [troubleShoot](./TroubleShooting.md)
* About [enable arc extensions for all sites](../README.md#enable-arc-extensions-for-all-sites)