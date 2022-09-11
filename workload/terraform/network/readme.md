## AVD-Network

Azure Virtual Desktop resources and dependent services for establishing the Azure Virtual Desktop spoke network.

- Azure Virtual Desktop resources:
  - Network Security group
  - New VNet and subnet
  - Peering to the hub virtual network
  - Baseline NSG
  - DNS zones for private endpoints
  - Route table

## Files

The Azure Virtual Desktop Network Terraform files are all written as individual files each having a specific function. Variables have been created in all files for consistency, all changes to defaults are to be changed from the terraform.tfvars.sample file. The structure is as follows:
| file Name                  | Description                                                  |
| ---------------------------| ------------------------------------------------------------ |
| data.tf                    | This file has data lookup |
| output.tf                  | This will contains the outputs post deployment |
| rg.tf                      | Creates the resource groups |
| routetable.tf              | Creates a routetable |
| locals.tf                  | This file is for locals |
| main.tf                    | This file contains the provider |
| nsg.tf                     | Creates the network security group with required URLs |
| dns_zones.tf               | Creates DNS zones for file and keyvault |
| variables.tf               | Variables have been created in all files for various properties and names |
| networking.tf              | Creates the AVD spoke virtual network, subnet and peering to the hub network |
| terraform.tfvars.sample    | This file contains the values for the variables change per your requirements |

Validated on provider versions:
hashicorp/random v3.3.2
hashicorp/azuread v2.26.1
hashicorp/azurerm v3.81.0

## Deployment Steps

1. Modify the `terraform.tfvars` file to define the desired names, location, networking, and other variables
2. Before deploying, confirm the correct subscription
3. Change directory to the Terraform folder
4. Run `terraform init` to initialize this directory
5. Run `terraform plan` to view the planned deployment
5. Run `terraform apply` to confirm the deployment

## Confirming Deployment

