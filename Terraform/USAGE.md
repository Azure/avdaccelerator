# Usage

<!--- BEGIN_TF_DOCS --->
## Requirements

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_SIG"></a> [SIG](#module\_SIG) | ./modules/SIG | n/a |
| <a name="module_avd"></a> [avd](#module\_avd) | ./modules/avd | n/a |
| <a name="module_log-analytics"></a> [log-analytics](#module\_log-analytics) | ./modules/log-analytics | n/a |
| <a name="module_storage"></a> [storage](#module\_storage) | ./modules/storage | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aad_group_name"></a> [aad\_group\_name](#input\_aad\_group\_name) | Azure Active Directory Group for AVD users | `string` | n/a | yes |
| <a name="input_ad_rg"></a> [ad\_rg](#input\_ad\_rg) | The resource group for AD VM | `string` | n/a | yes |
| <a name="input_ad_vnet"></a> [ad\_vnet](#input\_ad\_vnet) | Name of domain controller vnet | `string` | n/a | yes |
| <a name="input_avd_users"></a> [avd\_users](#input\_avd\_users) | AVD users | `list` | `[]` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | Custom DNS configuration | `list(string)` | n/a | yes |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | Name of the domain to join | `string` | n/a | yes |
| <a name="input_domain_password"></a> [domain\_password](#input\_domain\_password) | Password of the user to authenticate with the domain | `string` | n/a | yes |
| <a name="input_domain_user_upn"></a> [domain\_user\_upn](#input\_domain\_user\_upn) | Username for domain join (do not include domain name as this is appended) | `string` | n/a | yes |
| <a name="input_host_pool"></a> [host\_pool](#input\_host\_pool) | Name of the Azure Virtual Desktop host pool | `string` | `"AVD-TF-HP"` | no |
| <a name="input_local_admin_password"></a> [local\_admin\_password](#input\_local\_admin\_password) | local admin password | `any` | n/a | yes |
| <a name="input_local_admin_username"></a> [local\_admin\_username](#input\_local\_admin\_username) | local admin username | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | The Azure Region in which all resources in this example should be created. | `string` | n/a | yes |
| <a name="input_ou_path"></a> [ou\_path](#input\_ou\_path) | n/a | `string` | `""` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix of the name of the AVD machine(s) | `string` | n/a | yes |
| <a name="input_rdsh_count"></a> [rdsh\_count](#input\_rdsh\_count) | Number of AVD machines to deploy | `number` | `3` | no |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | Name of the Resource group in which to deploy these resources | `string` | `"AVD-TF"` | no |
| <a name="input_signame"></a> [signame](#input\_signame) | The Azure Compute Gallery name | `any` | n/a | yes |
| <a name="input_subnet_range"></a> [subnet\_range](#input\_subnet\_range) | Address range for session host subnet | `list(string)` | n/a | yes |
| <a name="input_vm_size"></a> [vm\_size](#input\_vm\_size) | Size of the machine to deploy | `string` | `"Standard_DS2_v2"` | no |
| <a name="input_vnet_range"></a> [vnet\_range](#input\_vnet\_range) | Address range for deployment VNet | `list(string)` | n/a | yes |
| <a name="input_workspace"></a> [workspace](#input\_workspace) | Name of the Azure Virtual Desktop workspace | `string` | `"AVD TF Workspace"` | no |

## Outputs

No outputs.

<!--- END_TF_DOCS --->

