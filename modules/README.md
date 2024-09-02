This folder contains serveral quick start template,

## Inventory

| Folder Name | Description | Type | Detail Link | Version |
|------|-------------|------|---------|:--------:|
| hci-aks-quick-module | This Terraform module serves as a quickstart template for deploying an HCI cluster and a hybrid AKS cluster. | HCI + AKS | [Link](https://github.com/Infrastructure-as-code-Automation/HCIAKS-quickstart-template-terraform/blob/main/README.md) |0.0.3|

### NOTE: This module follows the semantic versioning and versions prior to 1.0.0 should be consider pre-release versions.
Major version Zero (0.y.z) is for initial development. Anything MAY change at any time. A module SHOULD NOT be considered stable till at least it is major version one (1.0.0) or greater. Changes will always be via new versions being published and no changes will be made to existing published versions. For more details please go to <https://semver.org/>

## How to update the submodule


After cloning the repository, run the following commands to initialize and configure the submodules:

```sh
# Initialize and update submodules
git submodule update --init --recursive

# Navigate to the submodule directory
cd modules/hci-aks-quick-module

# Fetch the tags from the remote repository
git fetch --tags

# Checkout the specific tag
git checkout tags/<tag>

# Configure sparse checkout to only include the modules/base directory
git sparse-checkout init --cone
git sparse-checkout set modules/base

# Move the contents of modules/base to the root of the submodule directory
mv modules/base/* .
rm -rf modules/base

# Navigate back to the main repository
cd ../../