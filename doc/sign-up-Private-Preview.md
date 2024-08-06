# Sign up Private Preview

* Review and accept the [Terms](./Infrastructure-as-Code-Automation-Use-Terms.pdf).
* Please fill in this [form](https://github.com/Azure/Edge-infrastructure-quickstart-template/issues/new?assignees=xwen11&labels=customers+onboarding&projects=&template=preview-sign-up-form.md&title=%5BOnboarding%5D) to sign up for Private Preview. We will send a private preview SAS token to you.
* After you get the SAS tokens, following the steps below:
    1. Download the binaries to run locally
        * Windows: Run `./private_preview.ps1`
        * Linux: Run `./private_preview.sh`

    2. Verify your downloads
        * Run `./az-edge-module-export -v` & `./az-edge-site-scale -v`.
            <details><summary><b> Sample output </b></summary>
            <code>
                
                2024/04/29 10:37:54 telemetry.go:110: InstallationId: ***, SessionId: ***

                az-edge-module-export version main(20240426.2)
            </code>
            </details>


## next step
[Go back to home page](../README.md)