# Naming standard

:page_with_curl: **Note:** The baseline deployment will ask for a "Prefix" which will be included in all the deployed resources.
The naming of resources is hard coded in the templates but can also be modified as required prior to deployment.

## Resource naming for the baseline deployment

### AVD Management plane

| Resource Name | Resource Type | Description |
|:--|:--|:--|
| `rg-avd-{Azure Region}-{Prefix}-service-objects` | Resource Group | Contains related AVD service objects |
| `vdws-{Azure Region}-{Prefix}-{nnn}` | AVD Workspace | |
| `vdpool-{Azure Region}-{Prefix}` | AVD Host pool | |
| `vdag-desktop-{Azure Region}-{Prefix}-{nnn}` | AVD Application group (Desktop) | |
| `vdag-rapp-{Azure Region}-{Prefix}-{nnn}` | AVD Application group (RemoteApp) | |
| `kv-avd-{Azure Region}-{Prefix}-{uniquestring}` | Key vault | |
| `id-avd-fslogix-{AzureRegion}-{Prefix}` | Managed identity | |

### Compute naming

| Resource Name | Resource Type |
|:--|:--|
| `rg-avd-{AzureRegion}-{Prefix}-pool-compute` | Resource Group |
| `avail-avd-{AzureRegion}-{Prefix}-{nnn}` | Availability set |
| `osdisk-{AzureRegion}-avd-{Prefix}-{nnn}` | Disk |
| `nic-{nn}-{VM name}` | Network Interface |
| `vm-avd-{Prefix}-{nn}` | Virtual Machine |

### FSLogix Storage naming

| Resource Name | Resource Type |
|:--|:--|
| `rg-avd-{AzureRegion}-{Prefix}-storage` | Resource Group |
| `stavd-{unique string}` | Storage account |
| `pe-{storage account name}-file` | Private endpoint |
| `nic-{nn}-{private endpoint name}` | Network Interface |
| `vm-fs-dj-{Prefix}` | Virtual Machine |

### Network naming

| Resource Name | Resource Type |
|:--|:--|
| `rg-avd-{Azure Region}-{Prefix}-network` | Resource Group |
| `nsg-avd-{Azure Region}-{Prefix}-{nnn}` | Network Security Group |
| `route-avd-{Azure Region}-{Prefix}-{nnn}` | Route Table |
| `vnet-avd-{Azure Region}-{Prefix}-{nnn}` | Virtual Network |
| `snet-avd-{Azure Region}-{Prefix}-{nnn}` | Virtual Network |

### Resource naming for the custom image deployment

#### AVD custom image naming

| Resource Name | Resource Type |
|:--|:--|
| `rg-{Azure Region}-avd-shared-resources` | Resource Group |
| `gal-avd-{Azure Region}-{nnn}` | Azure compute gallery |
| `avd_image_definition_{Image name}` | Image Template |
| `kv-avd-{Azure Region}-{unique-string}` | Key vault |
| `id-avd-deployscript-{Azure Region}` | Managed Identity |
| `id-avd-imagebuilder-{Azure Region}` | Managed Identity |
| `stavd{unique string}` | Storage account |
| `avd_imagedefinition{image name}` | VM image definition |

### Resource naming example

![Resource organization and naming](./diagrams/avd-accelerator-resource-organization-naming.png)

### Tagging for the baseline deployment

| Tag Name | Tag Value | Description |
|:--|:--|:--|
| Workload name |  |  |
| Workload type | Light,Medium,High,Power |  |
| Data classification | Non-business,Public,General,Confidential,Highly-confidential |  |
| Department |  |  |
| Workload Criticality | Low,Medium,High,Mission-Critical,Custom |  |
| Application name  |  |  |
| Workload SLA  |  |  |
| Operations team  |  |  |
| Owner  |  |  |
| Cost Center  |  |  |
| Environment type  | Dev,Staging,Prod  |  |
| Creation date |  |  |

AVD baseline tagging example:

![Baseline](./diagrams/avd-accelerator-resource-tagging-baseline.png)

### Tagging for the custom image build deployment

| Tag Name | Tag Value | Description |
|:--|:--|:--|
| Image build name |  |  |
| Workload name |  |  |
| Data classification | Non-business,Public,General,Confidential,Highly-confidential |  |
| Department |  |  |
| Workload Criticality | Low,Medium,High,Mission-Critical,Custom |  |
| Application name  |  |  |
| Workload SLA  |  |  |
| Operations team  |  |  |
| Owner  |  |  |
| Cost Center  |  |  |
| Environment type  | Dev,Staging,Prod |  |
| Creation date |  |  |

Custom image tagging example:

![Custom image](./diagrams/avd-accelerator-resource-tagging-custom-image.png)

## Next Steps

Continue with:

1. [Custom image deployment (optional)](./deploy-custom-image.md) to build an updated and optimized image; or
2. [AVD accelerator baseline deployment](./deploy-baseline.md) if you are ready to deploy an AVD workload from the market place, an updated and optimized image previously created by the custom image deployment, or the the Azure market place or from an Azure Compute Gallery
