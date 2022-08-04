| Portal UI Experience (ARM)                                   |
| ------------------------------------------------------------ |
| [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-baseline.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-baseline.json) |
# AVD accelerator baseline deployment walk through

- **Azure core setup** blade
  - **Subscription** - The subscription where the accelerator is going to deploy the resources.
  - **Region** – The desired Azure Region to be used for the deployment
  - **Deployment prefix** – A prefix of maximum 4 characters that will be appended to the names of Resource Groups and Azure resources within the Resource Groups.
- **Management plane** blade
  - **Deployment location** - The Azure Region where management plane resources (workspace, host pool, application groups) will be deployed. These resources are not available in all locations but are globally replicated and they can share the same location as the session hosts or not.
  - **Host pool type** - This option determines if a personal (aka single session) or pool (aka multi-session ) host pool will be configured.
  - When Pool is selected:
    - **Load balancing method** - Choose either breadth-first or depth-first, based on your usage pattern. Learn more about what each of these options means at [Host pool load-balancing methods](https://docs.microsoft.com/azure/virtual-desktop/host-pool-load-balancing).
    - **Max sessions** - Enter the maximum number of users you want load-balanced to a single session host.
    - **Create remote app group** - Choose if you want to create a RemoteApp application group or not. A Desktop application group will be created by default.
  - When Personal is selected:
    - **Machine assignment** - Select either Automatic or Direct.
  - **Start VM on connect** - Choose if you want the host pool to be configured to allow users starting session hosts on demand.
  - **AVD enterprise application ObjectID** - Enter the AVD enterprise application ObjectID from your Azure AD tenant.
- **Session hosts** blade
  - **Deploy sessions hosts** - You can choose to not deploy session hosts just the AVD service objects.
  - **Use availability zones** - If you select no an Availability set will be created instead and session hosts will be created in the availability set.
  - **Azure Files share SKU** - Select the desired SKU based on the availability required.
  - **FSLogix file share size** Choose the desired size in 100GB increments. Minimum size is 100GB.
  - **VM size** -  Select the SKU size for the session hosts
  - **VM count** - Select the number of session hosts to deploy
  - **OS disk type** - Select the OS Disk SKU type. Premium is recommended.
  - **End to end encryption** - If you want data stored on the session host  encrypted at rest and flow encrypted to the Storage service.
  - **OS image source** - Select a marketplace image or from the Azure Compute Gallery.
  - **OS version or image** - Choose the OS version or desired image from the Azure compute gallery
- **Identity** blade
  - **Domain** - Your Active Directory domain like contoso.com
  - **OU path** - If you want the session hosts to be created in a specific OU in AD, enter the OU path in distinguished format like OU=AVD,DC=contoso,DC=com. If left empty the computer accounts for session hosts will be created in the default Computers OU.
  - **Create OU for FSLogix storage account** - The accelerator will join the storage account for Azure Files Premium FSLogix user profiles to your AD DS domain. If left empty the computer account representing the Azure storage account will be created in the default Computers OU.
  - - **Domain Join credentials** - The credentials to be used for domain join for both session hosts and Azure storage account. See the prerequisites section for further information.
    - **Username**
    - **Password**
  - **Session host local admin credentials** - Enter the credentials for the local administrator account for the session hosts that will be created. **Make sure you document these credentials**.
    - **Username** -
    - **Password** -
- **Network connectivity** blade
  - **New** - Select if you want to create a new VNet to be used for session hosts.
    - **Virtual network** - Enter the IP block in CIDR notation to allocate to the VNet.
    - **VNet address range** - Enter IP block in CIDR notation for the new subnet.
    - **VNet DNS servers** - Enter the DNS servers to be set for the VNet. These DNS server should have proper DNS resolution to your AD DS domain and internet.
  - **Azure Private DNS zone** - Select yes to select an existing private DNS zone for Azure File share and Key vault. Select No if you do not want to use private endpoints.
  - **Existing hub VNet peering**  
    - **Virtual Network** - Select the hub VNet where this new VNet will be peered with.
    - **VNet Gateway on hub** - Select Yes or No if you want to set the use remote gateway option for the VNet peering.
- **Resource naming** blade
  - **Custom Resource Naming** - When set 'Yes', the information provided will be used to name resources. When set to 'No' deployment will use the AVD accelerator naming standard.  
- **Resource tagging** blade
  - **Custom Resource tagging** - When set 'Yes', the information provided will be used to create tags on resources and resource groups.  
- **Review + create** blade

Take a look at the [Naming Standard and Tagging](./Resource-naming.md) page for further information.

## Other deployment Options
We have these other options available:
- [Command line (BICEP/ARM)](/workload/bicep/README.md)
- [Terraform](/workload/terraform/readme.md)

# Next Steps

- After successful deployment, you can remove the temporary virtual machine (*vm-fs-dj-{deployment-prefix}*) and associated OS disk (*osdisk-001-vm-fs-dj-{deployment-prefix}*) and network interface (*nic-001-vm-fs-dj-{deployment-prefix}*) that was used to provision the storage account for FSLogix purposes.
- You should assign specific roles, including AVD-specific roles based on your organization’s policies.
- Preferably enable NSG Flow logs and AVD insights.

# Known Issues

Please report issues using the projects [issues](https://github.com/Azure/avdaccelerator/issues) tracker.
