# Automation Account Modules `[Microsoft.Automation/automationAccounts/modules]`

This module deploys an Azure Automation Account Module.

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Automation/automationAccounts/modules` | 2020-01-13-preview |

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `automationAccountName` | string | Name of the parent Automation Account. |
| `name` | string | Name of the Automation Account module. |
| `uri` | string | Module package uri, e.g. https://www.powershellgallery.com/api/v2/package. |

**Optional parameters**
| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `enableDefaultTelemetry` | bool | `True` | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `location` | string | `[resourceGroup().location]` | Location for all resources. |
| `tags` | object | `{object}` | Tags of the Automation Account resource. |
| `version` | string | `'latest'` | Module version or specify latest to get the latest version. |


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

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the deployed module |
| `resourceGroupName` | string | The resource group of the deployed module |
| `resourceId` | string | The resource ID of the deployed module |

## Template references

- [Automationaccounts/Modules](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Automation/2020-01-13-preview/automationAccounts/modules)
