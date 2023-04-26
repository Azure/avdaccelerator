# AVD LZA Baseline Deployment Walk Through

| Portal UI Experience (ARM) |
| ------------------------------------------------------------ |
| [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-baseline.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-baseline.json) [![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-baseline.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-baseline.json)|

- **Basics** blade
  - **Subscription** - The subscription where the accelerator is going to deploy the resources.
  - **Region** – The desired Azure Region to be used for the deployment.
  - **Deployment prefix** – A prefix of maximum 4 characters that will be appended to the names of Resource Groups and Azure resources within the Resource Groups.
- **Identity provider** blade
  - **Identity Service Provider** - Identity service provider (AD DS, AAD DS, AAD) that already exists and will be used for Azure Virtual Desktop.
    - Azure Active Directory (AAD).
    - Active Directory (AD DS).
    - Azure AD Domain Services (AAD DS).
  - **AVD users' role assignment** - These identities will be granted access to AVD application groups (role "Desktop Virtualization User").
    - Identity type - Select the type of identities that will be entered in the 'Identities ObjectIDs' field.
    - Identities ObjectIDs - Comma separated list of identities (ObjectIDs) to be granted access to AVD published items and to create sessions on VMs and single sign-on (SSO) when using AAD as identity provider.
    - Note: when using AAD as identity service provider, an additional role (virtual machine user login) will be granted to compute resource group during deployment.
  - **When selecting AD DS or AAD DS:**
    - Domain - Your Active Directory domain like contoso.com
    - Domain join credentials The Username and password with rights to join computers to the domain.
  - **When selecting ADD:**
    - Enroll VM with Intune: select to enroll session hosts on tenant Intune (Yes) or not (No).
  - **Session host local admin credentials** The Username and password to set for local administrator.
- **Management plane** blade
  - **Deployment location** - The Azure Region where management plane resources (workspace, host pool, application groups) will be deployed. These resources are not available in all locations but are globally replicated and they can share the same location as the session hosts or not.
  - **Host pool type** - This option determines if a personal (aka single session) or pool (aka multi-session ) host pool will be configured.
  - When Pooled is selected:
    - **Load balancing algorithm** - Choose either breadth-first or depth-first, based on your usage pattern. Learn more about what each of these options means at [Host pool load-balancing methods](https://docs.microsoft.com/azure/virtual-desktop/host-pool-load-balancing).
    - **Max session limit** - Enter the maximum number of users you want load-balanced to a single session host.
    - **Create remote app group** - Choose if you want to create a RemoteApp application group or not. A Desktop application group will be created by default.
    - **Scaling plan** - Choose if you want to create a scaling plan or not. An AVD scaling plan will be created and host pools assigned to it.
  - When Personal is selected:
    - **Machine assignment** - Select either Automatic or Direct.
    - **Start VM on connect** - Choose if you want the host pool to be configured to allow users starting session hosts on demand.
- **Session hosts** blade
  - **Deploy sessions hosts** - You can choose to not deploy session hosts just the AVD service objects.
  - **Session host region** - Provide the region to where you want to deploy the session hosts. This defaults to the Management Plane region but can be changed.
  - **Session hosts OU path (Optional)** - Provide OU where to locate session hosts, if not provided session hosts will be placed on the default (computers) OU. If left empty the computer account will be created in the default Computers OU. Example: OU=avd,DC=contoso,DC=com.
  - **Use availability zones** - If you select no an Availability set will be created instead and session hosts will be created in the availability set. If you select yes the accelerator  will distribute compute and storage resources across availability zones.
  - **VM size** -  Select the SKU size for the session hosts.
  - **VM count** - Select the number of session hosts to deploy.
  - **OS disk type** - Select the OS Disk SKU type. Premium is recommended.
  - **End to end encryption** - If you want data stored on the session host  encrypted at rest and flow encrypted to the Storage service.
  - **OS image source** - Select a marketplace image or an image from Azure Compute Gallery (Custom image build deployment will create images in compute gallery).
  - **OS version or image** - Choose the OS version or desired image from the Azure compute gallery.
- **Storage** blade
  - **Use FSLogix profile management**: Deploys FSLogix containers and session host setup for user's profiles.
  - **FSLogix Azure Files share Performance** - Select the desired performance.
  - **FSLogix file share size** Choose the desired size in 100GB increments. Minimum size is 100GB.
  - **Use MSIX App Attach**: Deploys MSIX App Attach container for MSIX app packages.
  - **MSIX App Attach Azure Files share Performance** - Select the desired performance.
  - **MSIX App Attach file share size** Choose the desired size in 100GB increments. Minimum size is 100GB.
- **Network connectivity** blade
  - **Virtual Network** - Select if creating "New"" or use "Existing" virtual network.
    - **New** - Select if you want to create a new VNet to be used for AVD.
      - **vNet address range** - Enter the IP block in CIDR notation to allocate to the VNet.
      - **AVD subnet address prefix** - Enter IP block in CIDR notation for the new AVD subnet.
      - **Private endpoint subnet address prefix** - Enter IP block in CIDR notation for the new private endpoint subnet.
      - **Custom DNS servers** - Enter the custom DNS servers IPs to be set on the VNet. These DNS server should have proper DNS resolution to your AD DS domain, internet and Azure private DNS zones for private endpoint resolution.
    - **Existing** - Select if using existing virtual networks for the AVD deployment.
      - **AVD virtual network** - Select virtual network to be used for AVD deployment.
      - **AVD subnet** - Select virtual network subnet to be used for session hosts deployment.
      - **Private endpoint virtual network** - Select virtual network to be used for private endpoint deployment.
      - **Private endpoint subnet** - Select virtual network subnet to be used for private endpoint deployment.
  - **Use private endpoints (Key vault and Azure files)** - Select yes to create private endpoints for key vault and Azure file services, when selecting no public endpoints of the services will be used.
  - **Existing Azure private DNS zone** - Select yes to use an existing private DNS zone for Azure Files and Key vault. Select No if you do not want to use private endpoints (Private DNS for Azure files is required for FSLogix deployment to configure properly).
  - **Existing hub VNet peering**
    - **Virtual Network** - Select the hub VNet where this new VNet will be peered with.
    - **VNet Gateway on hub** - Select Yes or No if you want to set the use remote gateway option for the VNet peering.
- **Monitoring** blade
  - **Deploy monitoring** - When set 'Yes', all required diagnostic configurations will be applied to all AVD resources, also events and performance stats will be pushed from session hosts to a log analytics workspace.
    - **Log analytics workspace** - select if creating a new workspace or if using and existing one.
    - **Deploy monitoring policies (subscription level)** - when set to 'Yes', custom policies and policy sets will be created and assigned to the subscription to enforce deployIfNotExist rules to future AVD resources.
- **Resource naming** blade
  - **Custom Resource Naming** - When set 'Yes', the information provided will be used to name resources. When set to 'No' deployment will use the AVD accelerator naming standard.
- **Resource tagging** blade
  - **Custom Resource tagging** - When set 'Yes', the information provided will be used to create tags on resources and resource groups When set to 'No' deployment will use the AVD accelerator naming standard.
- **Review + create** blade

Take a look at the [Naming Standard and Tagging](./resource-naming.md) page for further information.

## Redeployment Considerations

We redeploying the baseline automation with the same deployment prefix value, clean up of previously created resource groups or at least their contained resources will need to be removed before the new deployment is executed, this will prevent the duplication of resources (key vaults and storage accounts) and conflicts of IP range overlap when creating the AVD virtual network.

## Other Deployment Options

We have these other options available:

| Deployment Type | Link |
|:--|:--|
| Command line (Bicep/ARM) |[![Powershell/Azure CLI](./icons/powershell.png)](https://github.com/Azure/avdaccelerator/blob/main/workload/bicep/readme.md) |
| Terraform |[![Terraform](./icons/terraform.png)](https://github.com/Azure/avdaccelerator/blob/main/workload/terraform/readme.md) |

## Next Steps

- After successful deployment, you can remove the following temporary resources used only during deployment: 
    - virtual machine (`vm-mgmt-{deployment-prefix}`) and associated OS disk (`vm-mgmt-{deployment-prefix}-disk-os-01`) and network interface (`nic-001-vm-mgmt-{deployment-prefix}`) that was used to provision the storage account for FSLogix purposes.
    - Deployment scripts used to introduce wait times: Management-VM-Wait-{timestamp}, Managed-Identity-Wait-{timestamp}, Antimalware-Extension-Wait-{timestamp}, Session-Hosts-Wait-{timestamp}, SH-Moniroting-Wait-{timestamp}.
- You should assign specific roles, including AVD-specific roles based on your organization’s policies.
- Preferably enable NSG Flow logs and AVD insights.

## Known Issues

Please report issues using the projects [issues](https://github.com/Azure/avdaccelerator/issues) tracker.
