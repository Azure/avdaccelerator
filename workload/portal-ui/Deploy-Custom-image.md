| Portal UI Experience (ARM)                                   |
| ------------------------------------------------------------ |
| [![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Farm%2Fdeploy-custom-image.json/uiFormDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%2Fmain%2Fworkload%2Fportal-ui%2Fportal-ui-custom-image.json) |

# AVD accelerator custom image build deployment walk through

- **Azure core setup** blade
  - **Subscription** - The subscription where the accelerator is going to deploy the resources.
  - **Region** – The desired Azure Region to be used for the deployment
  - **Deployment prefix** – A prefix of maximum 4 characters that will be appended to the names of Resource Groups and Azure resources within the Resource Groups.
- **Image Management** blade
  - **Storage- Use availability zones** - Select "Yes" to distribute storage resources across availability zones (ehen available).
  - **OS- Version** - Select the Image OS SKU to be used as source for the image.
- **Image Azure Image Builder (AIB)** blade
  - **Deployment location** - Select the location where Azure Image Builder will run to create the image.
  - **Create AIB managed identity** - Select "Yes" to create managed identity for Azure Image Builder custom role.
  - **Create AIB role** - Select "Yes" to create an Azure Image Builder custom role.
- **Resource naming** blade
  - **Custom resource naming** - When set "Yes", the user will input names for the resources. When set to "No" the deployment will use the AVD accelerator naming standard. 
- **Resource tagging** blade
  - **Custom resource tags** - When set 'Yes', the information provided will be used to create tags on resources and resource groups.

Take a look at the [Naming Standard and Tagging](./Resource-naming.md) page for further information.

## Other deployment Options
We have these other options available:
- [Command line (BICEP/ARM)](/workload/bicep/README.md)
- [Terraform](/workload/terraform/readme.md)

# Next Steps

- After successful deployment, you can remove the temporary resource group (IT_rg-avd-eus-shared-services_avd_image...) and its resources that was used to provision the custom image.

# Known Issues

Please report issues using the projects [issues](https://github.com/Azure/avdaccelerator/issues) tracker.
