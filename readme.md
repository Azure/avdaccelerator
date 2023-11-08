# Welcome to the Azure Virtual Desktop (AVD) Landing Zone Accelerator

[![Average time to resolve an issue](http://isitmaintained.com/badge/resolution/azure/avdaccelerator.svg)](http://isitmaintained.com/project/azure/avdaccelerator "Average time to resolve an issue") [![Percentage of issues still open](http://isitmaintained.com/badge/open/azure/avdaccelerator.svg)](http://isitmaintained.com/project/azure/avdaccelerator "Percentage of issues still open")

## Overview

Enterprise-scale is an architectural approach and a reference implementation that enables effective construction and operation of landing zones on Azure, at scale. This approach aligns with the Azure roadmap and the Cloud Adoption Framework for Azure.

Azure Virtual Desktop Landing Zone Accelerator (LZA) represents the strategic design path and target technical state for Azure Virtual Desktop deployment. This solution provides an architectural approach and reference implementation to prepare landing zone subscriptions for a scalable Azure Virtual Desktop deployment. For the architectural guidance, check out [Enterprise-scale for Azure Virtual Desktop in Microsoft Docs](https://docs.microsoft.com/azure/cloud-adoption-framework/scenarios/wvd/enterprise-scale-landing-zone).

The Azure Virtual Desktop Landing Zone Accelerator (LZA) only addresses what gets deployed in the specific Azure Virtual Desktop landing zone subscriptions, highlighted by the red boxes in the [architectural diagram below](#architectural-diagram). It is assumed that an appropriate platform foundation is already setup which may or may not be the official [ALZ platform foundation](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/enterprise-scale/implementation#reference-implementation). This means that policies and governance should already be in place or should be set up after this implementation and are not a part of the scope this program. The policies applied to management groups in the hierarchy above the subscription will trickle down to the Enterprise-scale for Azure Virtual Desktop landing zone subscriptions.

## This Repository

This repository will contain various customer scenarios that can help accelerate the development and deployment of Azure Virtual Desktop that conforms with [Enterprise-Scale for Azure Virtual Desktop best practices and guidelines](https://docs.microsoft.com/azure/cloud-adoption-framework/scenarios/wvd/ready). Each scenario aims to represent common customer experiences with the goal of accelerating the process of developing and deploying conforming Azure Virtual Desktop using IaaC. Each scenario will eventually have an ARM, Bicep, PowerShell and CLI version to choose from.
As of today, we have a first reference implementation scenario that is one of the most common ones used by Enterprise customers and partners and it can be used to deploy an Azure Virtual Desktop workload. We will continue to add new scenarios in future updates.

## Getting Started

## Azure Virtual Desktop - LZA Baseline

[Getting Started](/workload/docs/getting-started-baseline.md) deploying Azure Virtual Desktop (AVD) resources and dependent services for establishing the baseline

- Azure Virtual Desktop resources: workspace, two (2) application groups, scaling plan and a host pool
- [Optional]: new virtual network (VNet) with NSGs, ASG and route tables
- Azure Files with Integration to the identity service
- Key vault
- Session Hosts

| Deployment Type | Link |
|:--|:--|
| Azure portal UI |[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-baseline.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-baseline.json) [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-baseline.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-baseline.json)|
| Command line (Bicep/ARM) | [![Powershell/Azure CLI](./workload/docs/icons/powershell.png)](./workload/bicep/readme.md#avd-accelerator-baseline) |
| Terraform | [![Terraform](./workload/docs/icons/terraform.png)](./workload/terraform/greenfield/readme.md) |

If you are having deployment challenges, refer to the [LZA baseline troubleshooting guide](/workload/docs/baseline-troubleshooting-guide.md) for guidance. For additional support please submit a GitHub issue.

## Azure Virtual Desktop - LZA Optional Deployments

### Brownfield scenarios

The brownfield section contains templates to deploy additional features for Azure Virtual Desktop when existing infrastructure already exists. These templates can be used individually as required. Here is the list of deployment options available:

- [Alerts](./workload/bicep/brownfield/alerts/readme.md)
- [Auto Increase Premium File Share Quota](./workload/bicep/brownfield/autoIncreasePremiumFileShareQuota/readme.md)
- [Scaling Tool](./workload/bicep/brownfield/scalingTool/readme.md)
- [Start VM On Connect](./workload/bicep/brownfield/startVmOnConnect/readme.md)
- [App Attach Tools VM](./workload/bicep/brownfield/appAttachToolsVM/Readme.md)
- [Deep Insights Workbook](./workload/workbooks/deepInsightsWorkbook/readme.md)

### Custom image build

[Getting Started](/workload/docs/getting-started-custom-image-build.md) deploying a custom image based on the latest version of the Azure marketplace image to an Azure Compute Gallery. The following images are offered: 
 - Windows 10 21H2
 - Windows 10 22H2 (Gen 2)
 - Windows 11 21H2 (Gen 2)
 - Windows 11 22H2 (Gen 2)
 - Windows 10 21H2 with O365
 - Windows 10 22H2 with O365 (Gen 2)
 - Windows 11 21H2 with O365 (Gen 2)
 - Windows 11 22H2 with O365 (Gen 2)

You can also select to enable the Trusted Launch or Confidential VM security type feature on the Azure Compute Gallery image definition.

Custom image is optimized using [Virtual Desktop Optimization Tool (VDOT)](https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool) and patched with the latest Windows updates.

| Deployment Type | Link |
|:--|:--|
| Azure portal UI | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-custom-image.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-custom-image.json) [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-custom-image.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-custom-image.json) |
| Command line (Bicep/ARM) | [![Powershell/Azure CLI](./workload/docs/icons/powershell.png)](./workload/bicep/readme.md#optional-custom-image-build-deployment) |
| Terraform | [![Terraform](./workload/docs/icons/terraform.png)](./workload/terraform/customimage) |

## Architectural Diagram

![Azure Virtual Desktop accelerator diagram](./workload/docs/diagrams/avd-accelerator-baseline-architecture.png)

_Download a [Visio file](./workload/docs/diagrams/avd-accelerator-baseline-architecture.vsdx) of this architecture._

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit [https://cla.opensource.microsoft.com](https://cla.opensource.microsoft.com).

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft
trademarks or logos is subject to and must follow
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/legal/intellectualproperty/trademarks).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.

## Reporting issues

Microsoft Support is not yet handling issues for any published tools in this repository. However, we would like to welcome you to open issues using GitHub [issues](https://github.com/Azure/avdaccelerator/issues) to collaborate and improve these tools.
