# Getting Started - Baseline Deployment Guide

Welcome to the Baseline Deployment Guide for Azure Virtual Desktop! This guide will help you deploy the Baseline solution by providing deployment instructions and prerequisites.

## Prerequisites

Prior to deploying the Baseline solution, you need to ensure you have met the following prerequisites:

### Azure Environment Setup

- [x]  Deploy an ALZ architecture (recommended but not mandatory) from a template reference implementation available at [Deploying Enterprise-Scale Architecture in your own environment](https://github.com/Azure/Enterprise-Scale#deploying-enterprise-scale-architecture-in-your-own-environment).
- [x]  Configure Microsoft Entra Connect and ensure users are synchronized from AD DS to Microsoft Entra ID, unless session hosts are joining Microsoft Entra ID and FSLogix is not in use.

### Subscription requirements

- [x] Access to the Azure Virtual Desktop Azure subscription with owner permissions.
- [x]  The following resource provider must be registered in the subscription to be used for deployment:
  - Microsoft.DesktopVirtualization
  - Microsoft.Compute (When deploying Zero Trust mathe feature [EncryptionAtHost](https://learn.microsoft.com/azure/virtual-machines/disks-enable-host-based-encryption-portal?tabs=azure-powershell) will need to be registered)
  - Microsoft.Network
  - Microsoft.Storage

### Account and Access requirements

- [x]  The account used for the deployment and the Active Directory Domain Join account cannot have multi-factor authentication (MFA) enabled.
- [x] The account used for joining to the domain must have at minimum these permissions on the specified Organizational Unit (OU). Default OU is "Computers" if none is specified in deployment.
  - Object and all descendant objects:
    - Create Computer Object
  - Descendant Computer Objects:
    - Write All Properties
    - Modify Permissions
    - Change Password
    - Validate Write to DNS hostname
    - Validate Write to Service Principal Name
- [x]  The Domain Controllers used for AD join purposes should be standard writable Domain Controllers, not Read Only Domain Controllers (when using AD DS or Microsoft Entra DS).
- [x]  Ensure you have the appropriate [licenses](https://docs.microsoft.com/azure/virtual-desktop/prerequisites#operating-systems-and-licenses) for proper Azure Virtual Desktop entitlement.

### Networking requirements

- [x]  If the new Azure Virtual Desktop workload will be connected (peered) with a Hub VNet, contributor permissions are required on the referenced Hub VNet.
- [x]  Virtual network subnet used for Azure Virtual Desktop session host deployment, needs to access the following:
  - [list of URLs](https://learn.microsoft.com/azure/virtual-desktop/safe-url-list?tabs=azure#session-host-virtual-machines) session host VMs need to access for Azure Virtual Desktop (During and after deployment).
  - List of URLs required during deployment:
    - <https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/scripts/Set-FSLogixRegKeys.ps1>
    - <https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/scripts/Set-FSLogixRegKeysAAD.ps1>
    - <https://raw.githubusercontent.com/Azure/avdaccelerator/main/workload/scripts/Manual-DSC-Storage-Scripts.ps1>
    - https://github.com/Azure/avdaccelerator/raw/main/workload/scripts/DSCStorageScripts/<version_number>/DSCStorageScripts.zip
    - <https://wvdportalstorageblob.blob.core.windows.net/galleryartifacts/Configuration_09-08-2022.zip>
    - <https://go.microsoft.com/fwlink/?LinkID=627338&clcid=0x409>
    - <https://onegetcdn.azureedge.net/providers/providers.masterList.feed.swidtag>
    - <https://www.powershellgallery.com>
- [x]  If using existing Virtual Networks, disable deny private endpoint network policies. The deployment will fail if deny private endpoint network policies are enabled. See the following article on disabling them: [Disable private endpoint network policy](https://docs.microsoft.com/azure/private-link/disable-private-endpoint-network-policy).

### Private endpoints DNS requirements and considerations

- [x] Private endpoint considerations for Azure Files and Key Vault private endpoints name resolution:
  - Scenario 1:
    - Specs: creating a new Azure Virtual Desktop vNet, using custom DNS servers and existing Azure private DNS Zones.
    - Existing private DNS zones MUST be linked to the vNet where the custom DNS servers are connected, this is needed for the end-to-end setup of FSLogix and MSIX App Attach file shares to be successful. The DNS resolution requests will be sent to the custom DNS servers and its vNet is the one that needs to resolve private endpoint DNS records.
  - Scenario 2:
    - Specs: using private endpoints, creating a new Azure Virtual Desktop vNet and new private DNS zones.
    - Custom DNS servers may NOT be used in the new vNet as this will cause FSLogix and/or MSIX App Attach file shares deployments to fail. This happens because the private DNS zones will be linked to the newly created vNet and only this vNet will be able to resolve the private endpoints DNS records. When using custom DNS servers, existing Private DNS zones link to the vNet wher custom DNS server are connected will need to be used.
  - Scenario 3:
    - Specs: using existing Azure Virtual Desktop vNet, and creating new private DNS zones.
    - Custom DNS servers may NOT be used (unless they are connected to the same vNet used for the Azure Virtual Desktop deployment) in order for FSlogix/MSIX App Attach deployment to be successful, given that the private DNS zone will be linked to the existing vNet and this will be the only network able to resolve private endpoint DNS records. This scenario is only recommended when using Microsoft Entra ID as identity service provider.
  - Scenario 4:
    - Specs: using private endpoints and an existing Azure Virtual Desktop vNet with custom DNS servers configured.
    - Existing private DNS zones MUST be linked to the vNet containing the custom DNS servers for FSLogix and/or MSIX App Attach file shares deployments to be successful, given DNS name resolution requests will go to custom DNS servers and their vNet will need to resolve private endpoints DNS records.
    
  **Important**: for all scenatios that use custom DNS servers, conditional forwarding rules MUST be configured to send to Azure (168.63.129.16) the DNS requests targeting file.core.windows.net and vaultcore.azure.net name spaces.
- [x] Required private DNS zone name spaces:
  - Azure Commercial: privatelink.file.core.windows.net (Azure Files) and privatelink.vaultcore.azure.net (Key Vault).
  - Azure Government: privatelink.file.core.usgovcloudapi.net (Azure Files) and privatelink.vaultcore.usgovcloudapi.net (Key Vault).

### Other requirements

- [x]  If implementing Zero Trust, ensure the prerequisites for encryption at host have been implemented: [Prerequisites](https://learn.microsoft.com/azure/virtual-machines/disks-enable-host-based-encryption-portal?tabs=azure-powershell#prerequisites).
- [x]  If enabling Start VM on Connect or Scaling Plans features, it is required to provide the ObjectID for the enterprise application Azure Virtual Desktop (Name can also be displayed as 'Windows Virtual Desktops'). To get the ObjectID got to Microsoft Entra ID > Enterprise applications, remove all filters and search for 'Virtual Desktops' and copy the ObjectID that is paired with the Application ID: 9cdead84-a844-4324-93f2-b2e6bb768d07.
- [x]  Account used for portal UI deployment, needs to be able to query Microsoft Entra tenant and get the ObjectID of the Azure Virtual Desktop enterprise app, query will be executed by the automation using the user context.
- [x]  If complying with WAF, the Domain Controllers VMs if hosted in Azure should follow High Availability best practices as mentioned in [here](https://learn.microsoft.com/azure/architecture/example-scenario/identity/adds-extend-domain#reliability) and High availability for Entra Domain services can be setup using replica set as mentioned in [here](https://learn.microsoft.com/entra/identity/domain-services/concepts-replica-sets).
- [x]  If customer selects "Compute gallery" as the image source then it is customer's responsibility to ensure the high availability of the images used and keep the number of replicas to a minumum for scaling the deployments, as mentioned in [here](https://learn.microsoft.com/azure/virtual-machines/azure-compute-gallery).

## Planning

This section covers the high-level steps for planning an Azure Virtual Desktop deployment and the decisions that need to be made. The deployment will use the Microsoft provided Bicep/PowerShell/Azure CLI templates from this repository and the customer provided configuration files that contain the system specific information.

This Azure Virtual Desktop accelerator supports deployment into greenfield scenarios (no Azure Virtual Desktop Azure infrastructure components exist) or brownfield scenarios (some Azure Virtual Desktop Azure infrastructure components exist).

## Greenfield deployment

In the Greenfield scenario, there are no existing Azure infrastructure components for Azure Virtual Desktop deployment. The automation framework will create an Azure Virtual Desktop workload in the desired Azure region, create a new VNet or reuse an existing VNet, and configure basic connectivity.

It is important to consider the life cycle of each of these components. If you want to deploy these items individually or via separate executions, then please see the Brownfield Deployment section.

The Azure Virtual Desktop Green Field template provides a complete Azure Virtual Desktop landing zone reference implementation within a single template.

## Brownfield deployment

In the Brownfield scenario, the automation framework will deploy the solution using existing Azure VNet, allowing you to create a new Azure Virtual Desktop workload and utilize and integrate existing Azure resources.

## Deployment Options

The templates and scripts need to be executed from an execution environment, the currently available options are:

| Deployment Type | Link |
|:--|:--|
| Azure portal UI |[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%main%2Fworkload%2Farm%2Fdeploy-baseline.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%main%2Fworkload%2Fportal-ui%2Fportal-ui-baseline.json) [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%main%2Fworkload%2Farm%2Fdeploy-baseline.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%main%2Fworkload%2Fportal-ui%2Fportal-ui-baseline.json)|
| Command line (Bicep/ARM) |[![Powershell/Azure CLI](./icons/powershell.png)](https://github.com/Azure/avdaccelerator/blob/main/workload/bicep/readme.md) |
| Terraform |[![Terraform](./icons/terraform.png)](https://github.com/Azure/avdaccelerator/blob/main/workload/terraform/greenfield/readme.md) |

<!-- ## AVD Landing Zone: Greenfield Deployment

Greenfield deployment of AVD Landing Zone is suitable if you are looking at brand new installation. By using this reference implementation, you can deploy AVD using a suggested configuration from Microsoft. You can add new configuration or modify deployed configuration to meet their very specific requirement.
-->

## What will be deployed

The **Azure Virtual Desktop - Baseline** deploys Azure Virtual Desktop workload resources and necessary resources to allow for feature add-ins (like connectivity and monitoring) as per operational best practices.

It is preferable to have a new subscriptions for each deployment respectively, adhering to the Azure Landing Zone guidance. However, they can also be deployed to existing subscriptions and single subscription if required, see [Resource Organization](https://docs.microsoft.com/azure/cloud-adoption-framework/scenarios/wvd/design-area-resource-organization) for further information.

This [diagram](/workload/docs/diagrams/avd-accelerator-resource-organization-naming.png) is an example of the Azure resources and organization created with this reference implementation. The following input values were used in this example:

- **Azure Virtual Desktop - Baseline deployment**:
  - `avdWorkloadSubsId`: ID for Subscription name: Subscription Azure Virtual Desktop LZ
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

- [Azure Virtual Desktop LZA - Baseline - Deployment](./deploy-baseline.md) if you are ready to deploy an Azure Virtual Desktop workload from the market place, an updated and optimized image previously created by the custom image deployment, or the the Azure market place or from an Azure Compute Gallery.
