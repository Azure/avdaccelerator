# Getting Started - Baseline deployment

## Prerequisites

Prior to deploying the Baseline solution, you need to ensure you have met the following prerequisites:

- It is recommended to have already deployed an ALZ architecture (not mandatory) from a template reference implementation available. See [Deploying Enterprise-Scale Architecture in your own environment](https://github.com/Azure/Enterprise-Scale#deploying-enterprise-scale-architecture-in-your-own-environment).
- Azure AD Connect is already configured and users are already synchronized from AD DS to Azure AD, unless session hosts are being join to Azure AD and FSLogix is not in use.
- The account used for the deployment and the Active Directory Domain Join account cannot have multi-factor authentication (MFA) enabled.
- The Domain Controllers used for AD join purposes should be standard writable Domain Controllers, not Read Only Domain Controllers (when using AD DS or AAD DS).
- You have the appropriate [licenses](https://docs.microsoft.com/azure/virtual-desktop/prerequisites#operating-systems-and-licenses) for proper AVD entitlement.
- If the new AVD workload will be connected (peered) with a Hub VNet, contributor permissions are required on the referenced Hub VNet.
- If using existing Virtual Networks, the deployment will fail if deny private endpoint network policies is enabled. See the following article on disabling them: [Disable private endpoint network policy](https://docs.microsoft.com/azure/private-link/disable-private-endpoint-network-policy).
- Private DNS zones for Azure files and keyvault private endpoints name resolution. The private DNS zones will need to be linked to the AVD subnet when not using custom DNS servers, or to the vNet where the custom DNS servers are connected where they are configured on the AVD vNet.
  - Azure Commercial: privatelink.file.core.windows.net (Azure Files) and privatelink.vaultcore.azure.net (Key Vault).
  - Azure Government: privatelink.file.core.usgovcloudapi.net (Azure Files) and privatelink.vaultcore.usgovcloudapi.net (Key Vault).
- When enabling Start VM on Connect or Scaling Plans features, it is required to provide the ObjectID for the enterprise application Azure Virtual Desktop (Name can also be displayed as 'Windows Virtual Desktops'). To get the ObjectID got to Azure AD > Enterprise applications, remove all filters and search for 'Virtual Desktops' and copy the OjectID that is paired with the Application ID: 9cdead84-a844-4324-93f2-b2e6bb768d07.
- ObjectId of the **Windows Virtual Desktop** Enterprise Application (with Application Id **9cdead84-a844-4324-93f2-b2e6bb768d07**). This ObjectId is unique for each tenant and is used to give permissions for the [Start VM on Connect](https://docs.microsoft.com/azure/virtual-desktop/start-virtual-machine-connect) feature.
- Account used for portal UI deployment, needs to be able to query Azure AD tenant and get the ObjectID of the Azure Virtual Desktop enterprise app, query will be executed by the automation using the user context.
- Virtual network subnet used for AVD session host deployment, needs to access the following:
  - [list of URLs](https://learn.microsoft.com/azure/virtual-desktop/safe-url-list?tabs=azure#session-host-virtual-machines) session host VMs need to access for Azure Virtual Desktop (During and after deployment).
  - List of URLs required during deployment:
    - <https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/scripts/Set-FSLogixRegKeys.ps1>
    - <https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/scripts/Manual-DSC-Storage-Scripts.ps1>
    - <https://github.com/Azure/avdaccelerator/raw/main/workload/scripts/DSCStorageScripts.zip>
    - <https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip>

### Subscription requirements

- Access to the AVD Azure subscription with owner permissions.
- The [Microsoft.DesktopVirtualization](https://docs.microsoft.com/azure/virtual-desktop/create-host-pools-azure-marketplace?tabs=azure-portal#final-requirements) resource provider must be registered in the subscription to be used for deployment.

## Planning

This section covers the high-level steps for planning an AVD deployment and the decisions that need to be made. The deployment will use the Microsoft provided Bicep/PowerShell/Azure CLI templates from this repository and the customer provided configuration files that contain the system specific information.

This AVD accelerator supports deployment into greenfield scenarios (no AVD Azure infrastructure components exist) or brownfield scenarios (some AVD Azure infrastructure components exist).

## Greenfield deployment

In the Greenfield scenario, no Azure infrastructure components for AVD on Azure deployment exist prior to deploying. The automation framework will create an AVD workload in the desired Azure region, create a VNet or reuse an existing VNet and configure basic connectivity.
It is important to consider the life cycle of each of these components. If you want to deploy these items individually or via separate executions, then please see the Brownfield Deployment section.
The AVD Green Field template provides a complete AVD landing zone reference implementation within a single template.

## Brownfield deployment

In the Brownfield scenario, the automation framework will deploy the solution using existing Azure VNet, allowing you to create a new AVD workload and utilize and integrate existing Azure resources.

## Deployment Options

The templates and scripts need to be executed from an execution environment, the currently available options are:

| Deployment Type | Link |
|:--|:--|
| Azure portal UI |[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-baseline.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-baseline.json) [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-baseline.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-baseline.json)|
| Command line (Bicep/ARM) |[![Powershell/Azure CLI](./icons/powershell.png)](https://github.com/Azure/avdaccelerator/blob/main/workload/bicep/readme.md) |
| Terraform |[![Terraform](./icons/terraform.png)](https://github.com/Azure/avdaccelerator/blob/main/workload/terraform/greenfield/readme.md) |

<!-- ## AVD Landing Zone: Greenfield Deployment

Greenfield deployment of AVD Landing Zone is suitable if you are looking at brand new installation. By using this reference implementation, you can deploy AVD using a suggested configuration from Microsoft. You can add new configuration or modify deployed configuration to meet their very specific requirement.
-->

## What will be deployed

The **AVD baseline** deploys AVD workload resources and necessary resources to allow for feature add-ins (like connectivity and monitoring) as per operational best practices.

It is preferable to have a new subscriptions for each deployment respectively, adhering to the Azure Landing Zone guidance. However, they can also be deployed to existing subscriptions and single subscription if required, see [Resource Organization](https://docs.microsoft.com/azure/cloud-adoption-framework/scenarios/wvd/design-area-resource-organization) for further information.

This [diagram](/workload/docs/diagrams/avd-accelerator-resource-organization-naming.png) is an example of the Azure resources and organization created with this reference implementation. The following input values were used in this example:

- **AVD baseline deployment**:
  - `avdWorkloadSubsId`: ID for Subscription name: Subscription AVD LZ
  - `deploymentPrefix`: app1
  - `avdManagementPlaneLocation`: East US 2
  - `avdSessionHostLocation`: East US 2
  - `avdUseCustomNaming`: false
  - `Unique string`: a1b2c3 (6 characters string calculated by the deployment)

For baseline deployment cost estimate, see [here](./cost-estimate.md).

## Naming standard

The accelerator has built-in resource naming automation based on [Microsoft Cloud Adoption Framework (CAF) best practices for naming convention](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming?WT.mc_id=Portal-Microsoft_Azure_CreateUIDef),  the [recommended abbreviations for Azure resource types](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations?WT.mc_id=Portal-Microsoft_Azure_CreateUIDef) and [suggested tags](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging#minimum-suggested-tags).

To learn more about the resource naming used in this accelerator take a look at the [Naming Standard and Tagging](./resource-naming.md) page.

## Next Steps

Continue with:

- [AVD accelerator baseline deployment](./deploy-baseline.md) if you are ready to deploy an AVD workload from the market place, an updated and optimized image previously created by the custom image deployment, or the the Azure market place or from an Azure Compute Gallery.
