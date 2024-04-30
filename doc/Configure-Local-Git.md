# Configure Local Git

## Clone the Repository

Run `git clone <your repo url>`.

## Setup Git Hooks

Go to your local repository. `cd <your repo name>`.

Run `git config --local core.hooksPath ./.azure/hooks/`.
This hook will generate the pipeline definition `deploy-infra.yml` when you commit changes to this repository.


---
Next Step: [Setup Terraform Backend](./Setup-Terraform-Backend.md)
