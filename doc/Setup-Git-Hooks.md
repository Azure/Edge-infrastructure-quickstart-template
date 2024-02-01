# Setup git hooks

Run `git config --local core.hooksPath ./.azure/hooks/`.
This hook will generate the pipeline definition `deploy-infra.yml` when you commit changes to this repository.