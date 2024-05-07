# Scale with automations

1. Make sure your are in <yourFeatureBranch> by running `git branch`. If not, `git checkout -b <yourFeatureBranch>`.
2. You can find a spread sheet under `./.azure`. The spread sheet contains all the entries which need customized inputs from you per site.
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