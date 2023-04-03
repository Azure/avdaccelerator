# Getting Started - Custom Image Build deployment

## Prerequisites

Prior to deploying the Custom Image Build solution, you need to ensure you have met the following prerequisites:

- It is recommended to have already deployed an ALZ architecture (not mandatory) from a template reference implementation available. See [Deploying Enterprise-Scale Architecture in your own environment](https://github.com/Azure/
- If using an existing virtual network, the deployment will fail if the private endpoint or private link services network policies are enabled. See the following article on disabling them: [Disable private endpoint network policy](https://docs.microsoft.com/azure/private-link/disable-private-endpoint-network-policy) and [Disable network policies for Private Link](https://learn.microsoft.com/azure/private-link/disable-private-link-service-network-policy).
- Virtual network subnet used for deployment, needs access to the following URLs:
  - https://raw.githubusercontent.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/main/Windows_VDOT.ps1
  - https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/archive/refs/heads/main.zip

### Subscription requirements

- Access to the AVD shared services Azure subscription with owner permissions.
- The [Microsoft.VirtualMachineImages](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-providers-and-types#register-resource-provider) resource provider must be registered in the subscription to be used for deployment.


## Planning

This section covers the high-level steps for planning a Custom Image Build deployment and the decisions that need to be made. The deployment will use the Microsoft provided Bicep/PowerShell/Azure CLI templates from this repository and the customer provided configuration files that contain the system specific information.

This solution supports deployment into greenfield scenarios (no AVD Azure infrastructure components exist) or brownfield scenarios (some AVD Azure infrastructure components exist).

### Greenfield deployment

In the Greenfield scenario, no Azure infrastructure components exist prior to deployment. The automation framework will create the Custom Image Build solution in the desired Azure region. When a build is executed on the image template, all the required resources will be deployed to support the deployment and communication of the build VM. If you have security requirements that do not allow the deployment of public IP addresses, use the Brownfield deployment option instead.

### Brownfield deployment

In the Brownfield scenario, the automation framework will deploy the solution using an existing virtual network. Other existing resources may exist as well, like a log analytics workspace. For customers that cannot deploy public IP addresses, when an existing virtual network is specified, AIB relies on the Private Link service to download "[customizers](https://learn.microsoft.com/azure/virtual-machines/linux/image-builder-json?tabs=json%2Cazure-powershell#properties-customize)" to your build VM.  This allows tighter security controls to be enforced in your environment without breaking the build process.

## Deployment Options

The templates and scripts need to be executed from an execution environment. Here are the available options:

| Deployment Type | Link |
|:--|:--|
| Azure portal UI | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-custom-image.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-custom-image.json) [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-custom-image.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-custom-image.json) |
| Command line (Bicep/ARM) | [![Powershell/Azure CLI](./icons/powershell.png)](https://github.com/Azure/avdaccelerator/blob/main/workload/bicep/readme.md) |
| Terraform | [![Terraform](./icons/terraform.png)](https://github.com/Azure/avdaccelerator/blob/main/workload/terraform/customimage) |

## What will be deployed

The **Custom Image Build** creates a new image from the Azure marketplace in an Azure compute gallery, optimized, patched and ready to be used. This deployment is optional and you can customize to extend functionality, like adding additional scripts to further customize your images.

It is preferable to have a new subscription, adhering to the Azure Landing Zone guidance. However, the solution can also be deployed to an existing subscription. See [Resource Organization](https://docs.microsoft.com/azure/cloud-adoption-framework/scenarios/wvd/design-area-resource-organization) for further information.

This [diagram](/workload/docs/diagrams/avd-accelerator-resource-organization-naming.png) is an example of the Azure resources and organization created with this reference implementation. The following input values were used in this example:

- **Custom image deployment**:
  - `deploymentLocation`: East US 2
  - `sharedServicesSubId`:  ID for Subscription name: Subscription AVD Shared Services
  - `customNaming`: false

## Naming standard

The accelerator has built-in resource naming automation based on [Microsoft Cloud Adoption Framework (CAF) best practices for naming convention](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming?WT.mc_id=Portal-Microsoft_Azure_CreateUIDef),  the [recommended abbreviations for Azure resource types](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations?WT.mc_id=Portal-Microsoft_Azure_CreateUIDef) and [suggested tags](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging#minimum-suggested-tags).

To learn more about the resource naming used in this accelerator take a look at the [Naming Standard and Tagging](./resource-naming.md) page.

## Next Steps

- [Custom image deployment](./deploy-custom-image.md) to build an updated image for your AVD session hosts.
