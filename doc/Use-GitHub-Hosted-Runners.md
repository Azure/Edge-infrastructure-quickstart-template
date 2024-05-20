# Use GitHub hosted Runners

Open `.github/workflows/site-cd-workflow.yml`. Modify `runs-on` section to

```yml
    runs-on: [windows-latest]
    # runs-on: [self-hosted]

```

---
Next step: 

continue on [Add-first-site](./Add-first-Site.md), if you already have arc-connected servers, be aware that the step 2 and step 4 is now required for you.
