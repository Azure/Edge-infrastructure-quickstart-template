# Use GitHub hosted Runners

Open `.github/workflows/site-cd-workflow.yml`. Modify `runs-on` section to

```yml
    runs-on: [windows-latest]
    # runs-on: [self-hosted]

```
