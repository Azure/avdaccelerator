# Microsoft Entra ID Hybrid Lab
## Creates an AD VM with Entra ID Connect installed
## Quick Start

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#blade/Microsoft_Azure_CreateUIDef/CustomDeploymentBlade/uri/https%3A%2F%2Fraw.githubusercontent.com%2FAzure%2Favdaccelerator%main%2Fworkload%2Fworkshop%2FAAD-Hybrid-Lab%2Fdeploy.json)

## Details

* Deploys the following infrastructure:
 * Virtual Network
  * 1 subnet
  * 1 Network Security Groups
    * AD - permits AD traffic, RDP incoming to network; limits DMZ access
  * Public IP Address
  * AD VM
	* DSC installs AD
    * Test users are created
    * Azure Active Directory Connect is installed and available to configure.

## Notes
* The NSG is defined for reference, but is isn't production-ready as holes are also opened for RDP, and public IPs are allocated
* One VM size is specified for all VMs


## NOTICE/WARNING
* This template is explicitly designed for a lab/classroom environment. A few compromises were made, especially with regards to credential passing to DSC, that WILL result in clear text passwords being left behind in the DSC package folders, Azure log folders, and system event logs on the resulting VMs. 
 
 
## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.microsoft.com.

When you submit a pull request, a CLA-bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., label, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.
