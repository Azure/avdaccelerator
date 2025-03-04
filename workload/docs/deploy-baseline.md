# Azure Virtual Desktop LZA - Baseline - Deployment walk through

| Portal UI Experience (ARM) |
| ------------------------------------------------------------ |
| [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%main%2Fworkload%2Farm%2Fdeploy-baseline.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-baseline.json) [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/?feature.deployapiver=2022-12-01#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-baseline.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-baseline.json) [![Deploy to Azure China](https://aka.ms/deploytoazurechinabutton)](https://portal.azure.cn/?feature.deployapiver=2022-12-01#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-baseline.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-baseline.json)|

- **Basics** blade
  - **Subscription** - The subscription where the accelerator is going to deploy the resources.
  - **Region** – The desired Azure Region to be used for the deployment. Management Plane and Session Host Locations will be selected separately. 
  - **Prefix** – A prefix of maximum 4 characters that will be appended to the names of Resource Groups and Azure resources within the Resource Groups.
  - **Environment** – Deployment Environment type (Development/Test/Production), will be used for naming and tagging purposes.
- **Identity provider** blade
  - **Domain to join**
    - **Identity Service Provider** - Identity service provider (AD DS, Entra DS, Microsoft Entra ID) that already exists and will be used for Azure Virtual Desktop.
      - Microsoft Entra ID.
      - Active Directory (AD DS).
      - Microsoft Entra Domain Services.
      - **Intune enrollment** - If Intune is configured in your Microsoft Entra ID tenant, you can choose to have the VM automatically enrolled during the deployment by selecting this box.
      - **Domain name** - The full qualified domain name of the on-premises domain where the hybrid identities originated from. This requirement also applies to Entra ID + FSLogix deployments, because identities need to be hybrid for storage authenctication to be supported.
      - **Domain GUID** - GUID for the on-premises domain controller.
    - **Azure Virtual Desktop access assignment** - These identities will be granted access to Azure Virtual Desktop application groups (role "Desktop Virtualization User").
    - Groups - select from the drop down the groups to be granted access to Azure Virtual Desktop published items and to create sessions on VMs and single sign-on (SSO) when using Microsoft Entra ID as the identity provider.
    - Note: when using Microsoft Entra ID as the identity service provider, an additional role (virtual machine user login) will be granted to compute resource group during deployment.
  - **When selecting AD DS or Microsoft Entra DS:**
    - Domain join credentials: The Username and password with rights to join computers to the domain.
  - **When selecting Microsoft Entra ID:**
    - Enroll VM with Intune: Check the box to enroll session hosts on the tenant’s Intune.
  - **Session host local admin credentials** The Username and password to set for local administrator.
  - **Microsoft Defender for Cloud Solutions**:
    - This section enables advanced security monitoring for resources deployed within your Azure Virtual Desktop setup. Below are the Defender solutions available:
      - **Deploy Microsoft Defender for Cloud**: Deploys a policy for enabling overall security monitoring for the platform and resources deployed as part of Azure Virtual Desktop.
      - **Enable Microsoft Defender for Servers**: Deploys a policy for providing enhanced protection for session host virtual machines (VMs), including real-time threat detection, vulnerability assessment, and automated response.
      - **Enable Microsoft Defender for Storage**: Deploys a policy for protecting Azure Storage resources (e.g., FSLogix file shares) against malicious threats and unauthorized access attempts.
      - **Enable Microsoft Defender for Key Vault**: Deploys a policy to monitor Azure Key Vault access and prevent misuse or unauthorized activity.
      - **Enable Microsoft Defender for Azure Resource Manager**: Deploys a policy for ensuring the integrity of management operations on Azure resources by monitoring for suspicious activity or privilege escalations.
    - **Recommendation**:
      - Enable relevant Defender solutions for better security posture in production environments. For cost estimation, refer to the [Azure Pricing Calculator](https://azure.microsoft.com/en-us/pricing/calculator/).
- **Management plane** blade
  - **Deployment location** - The Azure Region where management plane resources (workspace, host pool, application groups) will be deployed. These resources are not available in all locations but are globally replicated and they can share the same location as the session hosts or not.
  - **Host pool type** - This option determines if a personal (aka single session) or pool (aka multi-session ) host pool will be configured.
  - When Pooled is selected:
    - **Load balancing algorithm** - Choose either breadth-first or depth-first, based on your usage pattern. Learn more about what each of these options means at [Host pool load-balancing methods](https://docs.microsoft.com/azure/virtual-desktop/host-pool-load-balancing).
    - **Max session limit** - Enter the maximum number of users you want load-balanced to a single session host.
    - **Create remote app group** - Choose if you want to create a RemoteApp application group or not. A Desktop application group will be created by default.
    - **Scaling plan** - Choose if you want to create a scaling plan or not. An Azure Virtual Desktop scaling plan will be created and host pools assigned to it.
  - When Personal is selected:
    - **Machine assignment** - Select either Automatic or Direct.
    - **Start VM on connect** - Choose if you want the host pool to be configured to allow users starting session hosts on demand.
- **Session hosts** blade
  - **Deploy sessions hosts** - You can choose to not deploy session hosts just the Azure Virtual Desktop service objects.
  - **Session host region** - Provide the region to where you want to deploy the session hosts. This defaults to the Management Plane region but can be changed.
  - **Session hosts OU path (Optional)** - Provide OU where to locate session hosts, if not provided session hosts will be placed on the default (computers) OU. If left empty the computer account will be created in the default Computers OU. Example: OU=avd,DC=contoso,DC=com.
  - **Availability zones** - If you uncheck the checkbox, VMs will be deployed regionally. If you select the checkbox the accelerator  will distribute compute and storage resources across availability zones.
  - **VM size** -  Select the SKU size for the session hosts.
  - **VM count** - Select the number of session hosts to deploy.
  - **OS disk type** - Select the OS Disk SKU type. Premium is recommended for performance and a higher SLA.
  - **Zero trust disk configuration** - Check the box to enable the zero trust configuration on the session host disks to ensure all the disks are encrypted, the OS and data disks are protected with double encryption with a customer managed key, and network access is disabled.
  - **Enable Antimalware extension** -  Enables Azure VM antimalware extension on session hosts
  - **Enable accelerated networking** - Check the box to ensure the network traffic on the session hosts is offloaded to the network interface to enhance performance. This feature is free and available as long a supported VM SKU and [OS](https://learn.microsoft.com/en-us/azure/virtual-network/accelerated-networking-overview?tabs=redhat#supported-operating-systems) is chosen. To check whether a VM size supports Accelerated Networking, see [Sizes for virtual machines in Azure](https://learn.microsoft.com/en-us/azure/virtual-machines/sizes). This feature is recommended as it will decrease CPU utilization for networking (offloading to NIC) and increase network performance/throughput to Azure VMs and Services, like Azure Files.
  - **OS image source** - Select a marketplace image or an image from Azure Compute Gallery (Custom image build deployment will create images in compute gallery).
  - **OS version or image** - Choose the OS version or desired image from the Azure compute gallery.
- **Storage** blade
  - **General Settings**:
    - **Custom OU Path (Optional)**: specify an OU path to create domain storage objects.
    - **Zone redundant storage**: Select to replicate storage across availability zones or only use local redundancy.
  - **FSLogix profile management**: Deploys FSLogix containers and session host setup for user's profiles.
  - **FSLogix Azure Files share Performance** - Select the desired performance.
  - **FSLogix file share size** Choose the desired size in 100GB increments. Minimum size is 100GB.
  - **App Attach**: Deploys App Attach container for App Attach app packages.
  - **App Attach Azure Files share Performance** - Select the desired performance.
  - **App Attach file share size** Choose the desired size in 100GB increments. Minimum size is 100GB.
- **Network connectivity** blade
  - **Virtual Network** - Select if creating "New"" or use "Existing" virtual network.
    - **New** - Select if you want to create a new VNet to be used for Azure Virtual Desktop.
      - **vNet address range** - Enter the IP block in CIDR notation to allocate to the VNet.
      - **Azure Virtual Desktop subnet address prefix** - Enter IP block in CIDR notation for the new Azure Virtual Desktop subnet.
      - **Private endpoint subnet address prefix** - Enter IP block in CIDR notation for the new private endpoint subnet.
      - **Custom DNS servers** - Enter the custom DNS servers IPs to be set on the VNet. These DNS server should have proper DNS resolution to your AD DS domain, internet and Azure private DNS zones for private endpoint resolution.
    - **Existing** - Select if using existing virtual networks for the Azure Virtual Desktop deployment.
      - **Azure Virtual Desktop virtual network** - Select virtual network to be used for Azure Virtual Desktop deployment.
      - **Azure Virtual Desktop subnet** - Select virtual network subnet to be used for session hosts deployment.
      - **Private endpoint virtual network** - Select virtual network to be used for private endpoint deployment.
      - **Private endpoint subnet** - Select virtual network subnet to be used for private endpoint deployment.
  - **Private endpoints (Key vault and Azure files)** - Select the checkbox to create private endpoints for key vault and Azure file services, when selecting no public endpoints of the services will be used.
  - **Existing Azure private DNS zone** - Select the checkbox to use an existing private DNS zone for Azure Files and Key vault (Private DNS for Azure files is required for FSLogix deployment to configure properly).
  - **Existing hub VNet peering**
    - **Virtual Network** - Select the hub VNet where this new VNet will be peered with.
    - **VNet Gateway on hub** - Select the checkbox to set the use remote gateway option for the VNet peering.
- **Monitoring** blade
  - **Deploy monitoring** - select checkbox to deploy all required diagnostic configurations all Azure Virtual Desktop resources, also events and performance stats will be pushed from session hosts to a log analytics workspace.
    - **Log analytics workspace** - select if creating a new workspace or if using and existing one.
    - **Deploy monitoring policies (subscription level)** - select the checkbox to deploy custom policies and policy sets will be created and assigned to the subscription to enforce deployIfNotExist rules to future Azure Virtual Desktop resources.
- **Resource naming** blade
  - **Custom Resource Naming** - select the checkbox to provide the names that will be used to name resources. When the checkbox is not selected deployment will use the Azure Virtual Desktop accelerator naming standard.
- **Resource tagging** blade
  - **Custom Resource tagging** - select the checkbox to provide information to be use to create tags on resources and resource groups.
- **Review + create** blade

Take a look at the [Naming Standard and Tagging](./resource-naming.md) page for further information.

## Post Deployment Considerations

- When using Microsoft Entra ID as identity provider and deploying FSLogix storage, it is required to grant admin consent to the storage account service principal (your-storage-account-name.file.core.windows.net) created during deployment, additional information can be found in the
[Grant admin consent to the new service principal](https://learn.microsoft.com/azure/storage/files/storage-files-identity-auth-hybrid-identities-enable?tabs=azure-portal#grant-admin-consent-to-the-new-service-principal) guide.

## Redeployment Considerations

When redeploying the baseline automation with the same deployment prefix value, clean up of previously created resource groups or at least their contained resources will need to be removed before the new deployment is executed, this will prevent the duplication of resources (key vaults and storage accounts) and conflicts of IP range overlap when creating the Azure Virtual Desktop virtual network.

## Other Deployment Options

We have these other options available:

| Deployment Type | Link |
|:--|:--|
| Azure portal UI |[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-baseline.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-baseline.json) [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-baseline.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-baseline.json) [![Deploy to Azure China](https://aka.ms/deploytoazurechinabutton)](https://portal.azure.cn/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-baseline.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-baseline.json)|
| Command line (Bicep/ARM) | [![Powershell/Azure CLI](./icons/powershell.png)](../bicep/readme.md#avd-accelerator-baseline) |
| Terraform | [![Terraform](./icons/terraform.png)](../terraform/greenfield/readme.md) |

## Next Steps

- After successful deployment, you can remove the following temporary resources used only during deployment:
  - Management virtual machine (`vmmgmt{deploymentPrefix}{DeploymentEnvironment-d/t/p}{AzureRegionAcronym}`) and its associated OS disk and network interface.
- You should assign specific roles, including [Azure Virtual Desktop - Specific roles](https://learn.microsoft.com/en-us/azure/virtual-desktop/rbac) based on your organization’s policies.
- Preferably enable NSG Flow logs and Traffic Analytics.

## Known Issues

Please report issues using the project's [issues](https://github.com/Azure/avdaccelerator/issues) tracker.
