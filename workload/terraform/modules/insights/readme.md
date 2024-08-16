# Azure Virtual Desktop Insights Initial Setup Terraform Module

The module is to help developers create their own Terraform deployment for Azure Virtual Desktop with Terraform. This module is best used for the 1st time setup of the Azure Virtual Desktop Insights (AVDI) by deploying the following:

* One Log Analytics Workspaces to be used the AVD environment. It is recommended to use a single Log Analytics Workspace for [AVDI](https://learn.microsoft.com/en-us/azure/virtual-desktop/insights)
* Enable data collection in the Log Analytics workspace
  
Note: There are other configuration to complete the setup of AVDI. That code is included in the [avd.tf](https://github.com/Azure/avdaccelerator/blob/main/workload/terraform/greenfield/ADDSscenario/avd.tf) and [host.tf](https://github.com/Azure/avdaccelerator/blob/main/workload/terraform/greenfield/ADDSscenario/host.tf) in the scenario.

Enjoy it by following steps:

1. Copy the insights module files from [avdi modules](../modules/../insights/)  
2. Decide on a  "Prefix" which will be included in all the deployed resources name. Resource Groups and resource names are derived from the Prefix parameter. Pick a unique resource prefix that is 3-4 alphanumeric characters in length without whitespaces
3. Modify the terraform.tfvars.sample with your values and rename to terraform.tfvars to define the desired names, location, and prefix variables
4. Before deploying, confirm that you have logged on to the correct subscription
5. Change directory to the folder that contains the terraform files
6. Run `terraform init` to initialize this directory
7. Run `terraform plan -out plan.out` to view the planned deployment
8. Run `terraform apply plan.out` and confirm the deployment
9. Enjoy it!

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name                                                                      | Version |
|---------------------------------------------------------------------------|---------|
| <a name="terraform"></a> [terraform](https://developer.hashicorp.com/terraform/downloads) | >= 1.3.7  |

## Providers

| Name                                                 | Version |
|------------------------------------------------------|---------|
| <a name="azurerm"></a> [azurerm](https://registry.terraform.io/providers/hashicorp/azurerm/3.44.1) | = 3.44.1  |

## Modules

[avdi modules](../modules/../insights/)

## Resources

| Name                                                                                                       | Type     |
|------------------------------------------------------------------------------------------------------------|----------|
| [azurerm_log_analytics_workspace](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_log_analytics_datasource_windows_event](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_datasource_windows_event) | resource |


## Inputs

| Name                                                            | Description      | Type     | Default | Required |
|-----------------------------------------------------------------|------------------|----------|---------|:--------:|
| <a name="rg_avdi"></a> rg_avdi | monitoring | `string` | n/a     |   yes    |
| <a name="prefix"></a> prefix| Prefix | `string` | n/a     |   yes    |
| <a name="avdLocation"></a> avdLocation| Azure Region | `string` | n/a     |   yes    |

## Outputs

| Name                                                              | Description      |
|-------------------------------------------------------------------|------------------|
| <a name="log_analytics_workspace_id"></a> log_analytics_workspace_id | ID known after creation |
| <a name="log_analytics_workspace_key"></a> log_analytics_workspace_key | Workspace key known after creation |
| <a name="log_analytics_workspace_name"></a> log_analytics_workspace_name | Name |

<!-- END_TF_DOCS -->