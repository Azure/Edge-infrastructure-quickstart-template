$stages=@("Dev","QA","Prod")
$dependentMap=@("","Dev-placeholder","QA-placeholder,Dev-placeholder")

	$stackTemplate=@'
    {{.StackName}}-site:
        uses: ./.github/workflows/site-cd-workflow.yml
        with:
            working-directory: {{.Stage}}/{{.StackName}}
        secrets: inherit
        needs: [{{.DependentStageList}}]

'@
	$stageTemplate=@'
    {{.Stage}}-placeholder:
        name: {{.Stage}}
        needs: [{{.StackList}}]
        runs-on: ubuntu-latest
        steps:
         - run: echo "running {{.Stage}} stage"

'@
    $workflow=@'
name: Terraform apply infra change

on:
  push:
    branches: ["main"]

jobs:

'@
for($count=0;$count -lt $stage.Count;$count++){
    $stage=$stages[$count]
    $iacgroups=(Get-ChildItem -Directory -Path ".\\$stage" -Name).Split()
    if($iacgroups.Count -eq 0){
        continue
    }
    $stacklist=@()
    foreach ($iacgroup in $iacgroups) {
        $stacklist += "$iacgroup-site"
    }
    $stagejob=($stageTemplate -replace '{{.Stage}}',$stage -replace '{{.StackList}}',($stacklist -join ","))
    echo $stagejob
    $workflow +=$stagejob
    $dependentStageList = $dependentMap[$count]
    foreach ($iacgroup in $iacgroups) {
        $stackjob=($stackTemplate -replace '{{.StackName}}', $iacgroup -replace '{{.Stage}}', $stage -replace '{{.DependentStageList}}',$dependentStageList)
        echo $stackjob
        $workflow +=$stackjob
    }
}
# create a workflow file
$workflowfile=".\.github\workflows\deploy-infra.yml"
if(test-path $workflowfile){
    remove-item $workflowfile
}
$workflow | out-file $workflowfile

