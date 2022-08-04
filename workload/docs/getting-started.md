# Getting Started

This guide is designed to help you get started with deploying AVD using the provided Bicep template(s) within this repository. Before you deploy, it is recommended to review the template(s) to understand the resources that will be deployed and the associated costs.

This accelerator is to be used as starter kit and you can expand its functionality by developing your own deployments. It is meant for creating a new AVD workload, so it cannot be used to maintain, modify or add resources to an existing or already deployed AVD workload from this accelerator. You can however, destroy the existing workload and use this accelerator to create a new AVD workloads.

## Prerequisites

Prior to deploying, you need to ensure you have met the following prerequisites:

- You have already deployed an ALZ architecture from a template reference implementation available. See [Deploying Enterprise-Scale Architecture in your own environment](https://github.com/Azure/Enterprise-Scale#deploying-enterprise-scale-architecture-in-your-own-environment).
- Access to the AVD Azure subscription(s) with owner permissions.
- Azure AD Connect is already configured and users are already synchronized from AD DS to Azure AD
- The account used for the deployment and the Active Directory Domain Join account cannot have multi-factor authentication (MFA) enabled.
- The Domain Controllers used for AD join purposes should be standard writable Domain Controllers, not Read Only Domain Controllers.
- You have the appropriate [licenses](https://docs.microsoft.com/azure/virtual-desktop/prerequisites#operating-systems-and-licenses) for proper AVD entitlement.
- If the new AVD workload will be connected (peered) with a Hub VNet, contributor permissions are required on the referenced Hub VNet.
- If using existing Virtual Networks, the deployment will fail if Private Endpoint policies are enabled. See the following article on disabling them: [Disable private endpoint network policy](https://docs.microsoft.com/azure/private-link/disable-private-endpoint-network-policy )

### Subscription requirements

- A set of new subscriptions has been created for Azure Virtual Desktop. We recommend two subscriptions, but a single subscription can be specified during deployment.
- The user or service principal must have rights at the tenant root as described here: [EnterpriseScale-Setup](https://github.com/Azure/Enterprise-Scale/blob/main/docs/EnterpriseScale-Setup-azure.md)
- The [Microsoft.DesktopVirtualization](https://docs.microsoft.com/azure/virtual-desktop/create-host-pools-azure-marketplace?tabs=azure-portal#final-requirements) resource provider must be registered in subscription(s) to be used for deployment.
- You will need the ObjectId of the **Windows Virtual Desktop** Enterprise Application (with Application Id **9cdead84-a844-4324-93f2-b2e6bb768d07**). This ObjectId is unique for each tenant and is used to give permissions for the [Start VM on Connect](https://docs.microsoft.com/azure/virtual-desktop/start-virtual-machine-connect) feature.


## Planning

This section covers the high-level steps for planning an AVD deployment and the decisions that need to be made. The deployment will use the Microsoft provided Bicep/PowerShell/Azure CLI templates from this repository and the customer provided configuration files that contain the system specific information.

This AVD accelerator supports deployment into greenfield scenarios (no Azure infrastructure components exist) or brownfield scenarios (some Azure infrastructure components exist).

## Greenfield deployment

In the Greenfield scenario, no Azure infrastructure components for AVD on Azure deployment exist prior to deploying. The automation framework will create an AVD workload in the desired Azure region, create a VNet or reuse an existing VNet and configure basic connectivity.
It is important to consider the life cycle of each of these components. If you want to deploy these items individually or via separate executions, then please see the Brownfield Deployment section.
The AVD Green Field template provides a complete AVD landing zone reference implementation within a single template.

## Brownfield deployment

In the Brownfield scenario, the automation framework will deploy the solution using existing Azure VNet, allowing you to create a new AVD workload and utilize and integrate existing Azure resources.

## Deployment Options

The templates and scripts need to be executed from an execution environment, the currently available are:

|                                      |                           |
|:-------------------------------------|:------------------------: |
|Azure portal UI - Custom Image (Optional)          |[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-baseline.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-baseline.json)      |
|Azure portal UI - AVD Baseline                     |[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-custom-image.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-custom-image.json)   |
|Command line (Bicep/ARM)              |[![Powershell/Azure CLI](./icons/powershell.png)](https://github.com/Azure/avdaccelerator/blob/main/workload/bicep/readme.md)          |
|Terraform                             |[![Terraform](./icons/terraform.png)](https://github.com/Azure/avdaccelerator/blob/main/workload/terraform/readme.md)                  |

<!-- ## AVD Landing Zone: Greenfield Deployment

Greenfield deployment of AVD Landing Zone is suitable if you are looking at brand new installation. By using this reference implementation, you can deploy AVD using a suggested configuration from Microsoft. You can add new configuration or modify deployed configuration to meet their very specific requirement.
-->

## What will be deployed

This reference implementation consists of 2 deployments:

1. **AVD shared resources (optional)**. Creates a new image from the Azure marketplace in an Azure compute gallery, optimized, patched and ready to be used. This deployment is optional and you can customize to extend functionality, like adding additional scripts to further customize your images.
2. **AVD baseline**. AVD workload and necessary resources to allow for feature add-ins, connectivity and monitoring as per operational best practices.

It is preferable to have a new subscriptions for each deployment respectively, adhering to the Azure Landing Zone guidance. However, they can also be deployed to existing subscriptions and single subscription if required, see [Resource Organization](https://docs.microsoft.com/azure/cloud-adoption-framework/scenarios/wvd/design-area-resource-organization) for further information.

This [diagram](/workload/docs/diagrams/avd-accelerator-resource-organization-naming.png) is an example of the Azure resources and organization created with this reference implementation. The following input values were used in this example:

- **AVD baseline deployment**:
	- *avdWorkloadSubsId*: ID for Subscription name: Subscription AVD LZ
	- *deploymentPrefix*: app1
	- *avdManagementPlaneLocation*: East US 2
	- *avdSessionHostLocation*: East US 2
	- *avdUseCustomNaming*: false
	- *Unique string*: a1b2c3 (6 characters string calculated by the deployment)

- **Custom image deployment**:
	- *avdSharedServicesLocation*: East US 2
	- *avdSharedServicesSubId*:  ID for Subscription name: Subscription AVD Shared Services
	- *avdUseCustomNaming*: false
	- *Unique string*: a1b2c3 (6 characters string calculated by the deployment)

## Naming standard

The accelerator has built-in resource naming automation based on [Microsoft Cloud Adoption Framework (CAF) best practices for naming convention](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming?WT.mc_id=Portal-Microsoft_Azure_CreateUIDef),  the [recommended abbreviations for Azure resource types](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations?WT.mc_id=Portal-Microsoft_Azure_CreateUIDef) and [suggested tags](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging#minimum-suggested-tags).

To learn more about the resource naming used in this accelerator take a look at the [Naming Standard and Tagging](./resource-naming.md) page.

## Next Steps

Continue with: 
1. [Custom image deployment (optional)](./deploy-custom-image.md) to build an updated and optimized image or 
2. [AVD accelerator baseline deployment](./deploy-baseline.md) if you are ready to deploy an AVD workload from the market place, an updated and optimized image previously created by the custom image deployment, or the the Azure market place or from an Azure Compute Gallery.
