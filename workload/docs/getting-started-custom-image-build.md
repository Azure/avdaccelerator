# Getting Started - Custom Image Build Deployment

Welcome to the Custom Image Build Deployment guide! This guide will walk you through the process of deploying a custom image build solution for your Azure Virtual Desktop environment. By following these steps, you'll be able to create and deploy optimized and customized images for use with Azure Virtual Desktop. 

## Prerequisites

Before you begin the deployment process, please ensure that you have met the following prerequisites:

- <b>Subscription Requirements </b>: 
  - Access to the Azure Virtual Desktop shared services Azure subscription with owner permissions.
  - The Microsoft.VirtualMachineImages resource provider must be registered in the subscription to be used for deployment.
- <b>ALZ Architecture Deployment</b>: It is recommended (though not mandatory) to have already deployed an ALZ architecture using the template reference implementation available. You can find more information on deploying the ALZ architecture in your own environment at [Deploying Enterprise-Scale Architecture in your own environment](https://github.com/Azure/Enterprise-Scale)
- <b>Disable Private Endpoint Network Policies</b>: If you are using an existing virtual network,ensure that the private endpoint or private link services network policies are disabled. The deployment process will fail if these policies are enabled. You can find instructions on how to disable these policies in the following articles: [Disable private endpoint network policy](https://docs.microsoft.com/azure/private-link/disable-private-endpoint-network-policy) and [Disable network policies for Private Link](https://learn.microsoft.com/azure/private-link/disable-private-link-service-network-policy).
- <b>URL Access for Virtual Network Subnet</b>: The virtual network subnet used for deployment needs access to the following URLs:
  - https://raw.githubusercontent.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/main/Windows_VDOT.ps1
  - https://github.com/The-Virtual-Desktop-Team/Virtual-Desktop-Optimization-Tool/archive/refs/heads/main.zip


## Planning

This section covers the high-level steps for planning a Custom Image Build deployment and the decisions that need to be made. The deployment will use the Microsoft provided Bicep/PowerShell/Azure CLI templates from this repository and the customer provided configuration files that contain the system specific information.

This solution supports deployment into greenfield scenarios (no Azure Virtual Desktop Azure infrastructure components exist) or brownfield scenarios (some Azure Virtual Desktop Azure infrastructure components exist).

### Greenfield deployment

In the Greenfield scenario, there are no existing Azure infrastructure components. The automation framework will create the Custom Image Build solution in the desired Azure region. When a build is executed on the image template, all the required resources for the deployment and communication of the build VM will be provisioned. If you have security requirements that do not allow the deployment of public IP addresses, use the Brownfield deployment option instead.

### Brownfield deployment

In the Brownfield scenario, the automation framework will deploy the solution using an existing virtual network. Other existing resources may exist as well, like a log analytics workspace. For customers that cannot deploy public IP addresses, when an existing virtual network is specified, AIB relies on the Private Link service to download "[customizers](https://learn.microsoft.com/azure/virtual-machines/linux/image-builder-json?tabs=json%2Cazure-powershell#properties-customize)" to your build VM.  This allows tighter security controls to be enforced in your environment without breaking the build process.

## Deployment Options

The templates and scripts need to be executed from an execution environment. Here are the available options:

| Deployment Type | Link |
|:--|:--|
| Azure portal UI | [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%main%2Fworkload%2Farm%2Fdeploy-custom-image.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%main%2Fworkload%2Fportal-ui%2Fportal-ui-custom-image.json) [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%main%2Fworkload%2Farm%2Fdeploy-custom-image.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%main%2Fworkload%2Fportal-ui%2Fportal-ui-custom-image.json) |
| Command line (Bicep/ARM) | [![Powershell/Azure CLI](./icons/powershell.png)](https://github.com/Azure/avdaccelerator/blob/main/workload/bicep/readme.md) |
| Terraform | [![Terraform](./icons/terraform.png)](https://github.com/Azure/avdaccelerator/blob/main/workload/terraform/customimage) |

## What will be deployed

The **Custom Image Build** creates a new image from the Azure marketplace in an Azure compute gallery, optimized, patched and ready to be used. This deployment is optional and you can customize to extend functionality, like adding additional scripts to further customize your images.

It is preferable to have a new subscription, adhering to the Azure Landing Zone guidance. However, the solution can also be deployed to an existing subscription. See [Resource Organization](https://docs.microsoft.com/azure/cloud-adoption-framework/scenarios/wvd/design-area-resource-organization) for further information.

To get an overview of the Azure resources and organization created with this reference implementation, take a look at this [diagram](/workload/docs/diagrams/avd-accelerator-resource-organization-naming.png). The diagram illustrates an example using the following input values:

- **Custom image deployment**:
  - `deploymentLocation`: East US 2
  - `sharedServicesSubId`:  ID for Subscription name: Subscription Azure Virtual Desktop Shared Services
  - `customNaming`: false

## Naming standard

The accelerator incorporates built-in resource naming automation based on then [Microsoft Cloud Adoption Framework (CAF) best practices for naming convention](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming?WT.mc_id=Portal-Microsoft_Azure_CreateUIDef),  the [recommended abbreviations for Azure resource types](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations?WT.mc_id=Portal-Microsoft_Azure_CreateUIDef) and [suggested tags](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging#minimum-suggested-tags).

To learn more about the resource naming conventions used in this accelerator, refer to the [Naming Standard and Tagging](./resource-naming.md) page.

## Next Steps

- [Azure Virtual Desktop LZA - Custom image build - Deployment](./deploy-custom-image.md) to build an updated image for your Azure Virtual Desktop session hosts.
