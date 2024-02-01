# Edge Infrastructure QuickStart Template

This repository offers a simple solution for the initial setup of your edge site, designed for ease of use. Scale effortlessly to multiple sites with a comprehensive stage-by-stage management pipeline.

## Supported edge resources** (By March 2024)

- [Azure Stack HCI, version 23H2](https://learn.microsoft.com/en-us/azure-stack/hci/whats-new)
- [Azure Stack HCI extensions](https://learn.microsoft.com/en-us/azure-stack/hci/manage/arc-extension-management?tabs=azureportal)
- [Azure Kubernetes Service (AKS) enabled by Azure Arc](https://learn.microsoft.com/en-us/azure/aks/hybrid/)

## Getting started

Getting started tutorials help you to configure a Github repository to create your first site.

This repository implements AD preparation and Arc connection. If you want to take advantage of this you may refer:
  - If your servers are exposed to Corpnet only: [Getting-Started-Corpnet](./doc/Getting-Started-Corpnet.md)
  - If your servers are exposed to Internet: [Getting-Started-Internet](./doc/Getting-Started-Internet.md)

Otherwise, you need to finish AD preparation and connect servers to Arc by yourself for all sites. Then, HCI and AKS provisioning can follow [Getting-Started-Self-Connect](./doc/Getting-Started-Self-Connect.md)

## Next Steps

- [Concepts](./doc/Concepts.md)
- [Add New Sites](./doc/Add-New-Sites.md)
- [Edit Global Parameters](./doc/Edit-Global-Parameters.md)
- [Customize Stages](./doc/Edit-Stages.md)
- [Edit Resource Naming Conventions](./doc/Naming-Conventions.md)
- [Manual Apply without Github Action](./doc/Manual-Apply.md)
- [Disable Telemetry](./doc/Disable-Telemetry.md)
- [Untrack Resources from The Repository](./doc/Untrack-Resources.md)

## License  
  
This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for more information.  
  
## Disclaimer  
  
This repository is provided "as-is" without any warranties or support. Use at your own risk. Always test in a non-production environment before deploying to production.  

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
