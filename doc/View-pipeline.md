You can view workflow status through actions page
<img src="./img/view_action.png" alt="viewaction" width="800"/>
the left panel show all workflows, you can click to filter by workflows.


- Export Azure resource into config workflow is used in export functionality
- Scale Edge Sites is used in scale
- Site Deployment workflow is a sub workflow, it referenced by terraform apply infra change workflow. The workflow is mainly run terraform related commands like terraform plan, terraform apply.
- Terraform apply infra change workflow is the main CI/CD workflow that deploy your infra change in a stage manner, it will be triggered when every push is made against main branch.
- Terraform plan check workflow is helper workflow that will be triggered every time you made a pull request to main branch, it will generate a terraform plan report based on your pull request change, a example is showed in following picture.

<img src="./img/terraform_plan_result.png" alt="terraform plan result" width="800"/>

