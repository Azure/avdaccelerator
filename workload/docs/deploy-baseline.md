# AVD accelerator baseline deployment walk through

| Portal UI Experience (ARM) |
| ------------------------------------------------------------ |
| [![Deploy To Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-baseline.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-baseline.json) |

- **Azure core setup** blade
  - **Subscription** - The subscription where the accelerator is going to deploy the resources
  - **Region** – The desired Azure Region to be used for the deployment
  - **Deployment prefix** – A prefix of maximum 4 characters that will be appended to the names of Resource Groups and Azure resources within the Resource Groups
- **Identity provider** blade
  - **Identity Service Provider** - Identity service provider (AD DS or AAD DS) that already exists and will be used for Azure Virtual Desktop
    - Active Directory (AD DS)
    - Azure AD Domain Services (AAD DS)
  - **Domain** - Your Active Directory domain like contoso.com
  - **Domain join credentials** The Username and password with rights to join computers to the domain
  - **Session host local admin credentials** The Username and password to set for local administrator
- **Management plane** blade
  - **Deployment location** - The Azure Region where management plane resources (workspace, host pool, application groups) will be deployed. These resources are not available in all locations but are globally replicated and they can share the same location as the session hosts or not
  - **Host pool type** - This option determines if a personal (aka single session) or pool (aka multi-session ) host pool will be configured
  - When Pooled is selected:
    - **Load balancing algorithm** - Choose either breadth-first or depth-first, based on your usage pattern. Learn more about what each of these options means at [Host pool load-balancing methods](https://docs.microsoft.com/azure/virtual-desktop/host-pool-load-balancing)
    - **Max session limit** - Enter the maximum number of users you want load-balanced to a single session host
    - **Create remote app group** - Choose if you want to create a RemoteApp application group or not. A Desktop application group will be created by default.
    - **Scaling plan** - Choose if you want to create a scaling plan or not. An AVD scaling plan will be created and host pools assigned to it
  - When Personal is selected:
    - **Machine assignment** - Select either Automatic or Direct
    - **Start VM on connect** - Choose if you want the host pool to be configured to allow users starting session hosts on demand
    - **Create start VM on connect role** - Choose if you want to create start VM on connect custom role
  - **AVD enterprise application ObjectID** - Provide the ObjectID of the enterprise application Azure Virtual Desktop (ApplicationID:  9cdead84-a844-4324-93f2-b2e6bb768d07
- **Session hosts** blade
  - **Deploy sessions hosts** - You can choose to not deploy session hosts just the AVD service objects
  - **Session hosts OU path (Optional)** - Provide OU where to locate session hosts, if not provided session hosts will be placed on the default (computers) OU. If left empty the computer account will be created in the default Computers OU. Example: OU=avd,DC=contoso,DC=com
  - **Use availability zones** - If you select no an Availability set will be created instead and session hosts will be created in the availability set. If you select yes the accelerator  will distribute compute and storage resources across availability zones
  - **Use FSLogix profile management**: Deploys FSLogix containers and session host setup for user's profiles
  - **Create OU for FSLogix storage account** - It is recommended to create a new AD Organizational Unit (OU) in AD and disable password expiration policy on computer accounts or service logon accounts accordingly. If yes, it will create a new OU, if no, you will need to provide the desired name for the OU
  - **Azure Files share SKU** - Select the desired SKU based on the availability required
  - **FSLogix file share size** Choose the desired size in 100GB increments. Minimum size is 100GB
  - **VM size** -  Select the SKU size for the session hosts
  - **VM count** - Select the number of session hosts to deploy
  - **OS disk type** - Select the OS Disk SKU type. Premium is recommended
  - **End to end encryption** - If you want data stored on the session host  encrypted at rest and flow encrypted to the Storage service
  - **OS image source** - Select a marketplace image or from the Azure Compute Gallery
  - **OS version or image** - Choose the OS version or desired image from the Azure compute gallery
- **Network connectivity** blade
  - **New** - Select if you want to create a new VNet to be used for session hosts
    - **Virtual network** - Enter the IP block in CIDR notation to allocate to the VNet
    - **VNet address range** - Enter IP block in CIDR notation for the new subnet
    - **VNet DNS servers** - Enter the DNS servers to be set for the VNet. These DNS server should have proper DNS resolution to your AD DS domain and internet
  - **Azure Private DNS zone** - Select yes to select an existing private DNS zone for Azure File share and Key vault. Select No if you do not want to use private endpoints
  - **Existing hub VNet peering**
    - **Virtual Network** - Select the hub VNet where this new VNet will be peered with
    - **VNet Gateway on hub** - Select Yes or No if you want to set the use remote gateway option for the VNet peering
- **Resource naming** blade
  - **Custom Resource Naming** - When set 'Yes', the information provided will be used to name resources. When set to 'No' deployment will use the AVD accelerator naming standard
- **Resource tagging** blade
  - **Custom Resource tagging** - When set 'Yes', the information provided will be used to create tags on resources and resource groups. When set to 'No' deployment will use the AVD accelerator naming standard
- **Review + create** blade

Take a look at the [Naming Standard and Tagging](./resource-naming.md) page for further information.

## Other deployment Options

| We have these other options available: | |
|:-----------------------------------------|:---:|
| Command line (Bicep/ARM) |[![Powershell/Azure CLI](./icons/powershell.png)](https://github.com/Azure/avdaccelerator/blob/main/workload/bicep/readme.md) |
| Terraform |[![Terraform](./icons/terraform.png)](https://github.com/Azure/avdaccelerator/blob/main/workload/terraform/readme.md) |

## Next Steps

- After successful deployment, you can remove the temporary virtual machine (`vm-fs-dj-{deployment-prefix}`) and associated OS disk (`osdisk-001-vm-fs-dj-{deployment-prefix}`) and network interface (`nic-001-vm-fs-dj-{deployment-prefix}`) that was used to provision the storage account for FSLogix purposes.
- You should assign specific roles, including AVD-specific roles based on your organization’s policies.
- Preferably enable NSG Flow logs and AVD insights.

## Known Issues

Please report issues using the projects [issues](https://github.com/Azure/avdaccelerator/issues) tracker.
