# Deployment Scripts `[Microsoft.Resources/deploymentScripts]`

This module deploys a deployment script.

## Navigation

- [Resource types](#Resource-types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Considerations](#Considerations)
- [Template references](#Template-references)

## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Authorization/locks` | 2017-04-01 |
| `Microsoft.Resources/deploymentScripts` | 2020-10-01 |

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | Display name of the script to be run. |

**Optional parameters**
| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `arguments` | string | `''` |  | Command-line arguments to pass to the script. Arguments are separated by spaces. |
| `azCliVersion` | string | `''` |  | Azure CLI module version to be used. |
| `azPowerShellVersion` | string | `'3.0'` |  | Azure PowerShell module version to be used. |
| `cleanupPreference` | string | `'Always'` | `[Always, OnSuccess, OnExpiration]` | The clean up preference when the script execution gets in a terminal state. Specify the preference on when to delete the deployment script resources. The default value is Always, which means the deployment script resources are deleted despite the terminal state (Succeeded, Failed, canceled). |
| `containerGroupName` | string | `''` |  | Container group name, if not specified then the name will get auto-generated. Not specifying a 'containerGroupName' indicates the system to generate a unique name which might end up flagging an Azure Policy as non-compliant. Use 'containerGroupName' when you have an Azure Policy that expects a specific naming convention or when you want to fully control the name. 'containerGroupName' property must be between 1 and 63 characters long, must contain only lowercase letters, numbers, and dashes and it cannot start or end with a dash and consecutive dashes are not allowed. |
| `enableDefaultTelemetry` | bool | `True` |  | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `environmentVariables` | array | `[]` |  | The environment variables to pass over to the script. Must have a 'name' and a 'value' or a 'secretValue' property. |
| `kind` | string | `'AzurePowerShell'` | `[AzurePowerShell, AzureCLI]` | Type of the script. AzurePowerShell, AzureCLI. |
| `location` | string | `[resourceGroup().location]` |  | Location for all resources. |
| `lock` | string | `'NotSpecified'` | `[CanNotDelete, NotSpecified, ReadOnly]` | Specify the type of lock. |
| `primaryScriptUri` | string | `''` |  | Uri for the external script. This is the entry point for the external script. To run an internal script, use the scriptContent instead. |
| `retentionInterval` | string | `'P1D'` |  | Interval for which the service retains the script resource after it reaches a terminal state. Resource will be deleted when this duration expires. Duration is based on ISO 8601 pattern (for example P7D means one week). |
| `runOnce` | bool | `False` |  | When set to false, script will run every time the template is deployed. When set to true, the script will only run once. |
| `scriptContent` | string | `''` |  | Script body. Max length: 32000 characters. To run an external script, use primaryScriptURI instead. |
| `supportingScriptUris` | array | `[]` |  | List of supporting files for the external script (defined in primaryScriptUri). Does not work with internal scripts (code defined in scriptContent). |
| `tags` | object | `{object}` |  | Tags of the resource. |
| `timeout` | string | `'PT1H'` |  | Maximum allowed script execution time specified in ISO 8601 format. Default value is PT1H - 1 hour; 'PT30M' - 30 minutes; 'P5D' - 5 days; 'P1Y' 1 year. |
| `userAssignedIdentities` | object | `{object}` |  | The ID(s) to assign to the resource. |

**Generated parameters**
| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `baseTime` | string | `[utcNow('yyyy-MM-dd-HH-mm-ss')]` | Do not provide a value! This date value is used to make sure the script run every time the template is deployed. |


### Parameter Usage: `tags`

Tag names and tag values can be provided as needed. A tag can be left without a value.

```json
"tags": {
    "value": {
        "Environment": "Non-Prod",
        "Contact": "test.user@testcompany.com",
        "PurchaseOrder": "1234",
        "CostCenter": "7890",
        "ServiceName": "DeploymentValidation",
        "Role": "DeploymentValidation"
    }
}
```

### Parameter Usage: `userAssignedIdentities`

You can specify multiple user assigned identities to a resource by providing additional resource IDs using the following format:

```json
"userAssignedIdentities": {
    "value": {
        "/subscriptions/12345678-1234-1234-1234-123456789012/resourcegroups/validation-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/adp-sxx-az-msi-x-001": {},
        "/subscriptions/12345678-1234-1234-1234-123456789012/resourcegroups/validation-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/adp-sxx-az-msi-x-002": {}
    }
},
```

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the deployment script |
| `resourceGroupName` | string | The resource group the deployment script was deployed into |
| `resourceId` | string | The resource ID of the deployment script |

## Considerations

This module requires a User Assigned Identity (MSI, managed service identity) to exist, and this MSI has to have contributor rights on the subscription - that allows the Deployment Script to create the required Storage Account and the Azure Container Instance.

## Template references

- [Deploymentscripts](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Resources/2020-10-01/deploymentScripts)
- [Locks](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2017-04-01/locks)
