# Use GitHub hosted Runners

Open `.github/workflows/site-cd-workflow.yml`. Modify `runs-on` section to

```yml
    runs-on: [windows-latest]
    # runs-on: [self-hosted]

```

---
Next step: 

if you already have arc connected server, continue on [Getting Started for Self Connected Servers](./Getting-Started-Self-Connect.md).

else, continue on [Getting-Started](./Getting-Started.md#add-your-first-site).