# Automation Account Runbooks `[Microsoft.Automation/automationAccounts/runbooks]`

This module deploys an Azure Automation Account Runbook.

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Automation/automationAccounts/runbooks` | 2019-06-01 |

## Parameters

**Required parameters**
| Parameter Name | Type | Allowed Values | Description |
| :-- | :-- | :-- | :-- |
| `automationAccountName` | string |  | Name of the parent Automation Account. |
| `name` | string |  | Name of the Automation Account runbook. |
| `runbookType` | string | `[Graph, GraphPowerShell, GraphPowerShellWorkflow, PowerShell, PowerShellWorkflow]` | The type of the runbook. |

**Optional parameters**
| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `enableDefaultTelemetry` | bool | `True` | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `location` | string | `[resourceGroup().location]` | Location for all resources. |
| `runbookDescription` | string | `''` | The description of the runbook. |
| `sasTokenValidityLength` | string | `'PT8H'` | SAS token validity length. Usage: 'PT8H' - valid for 8 hours; 'P5D' - valid for 5 days; 'P1Y' - valid for 1 year. When not provided, the SAS token will be valid for 8 hours. |
| `scriptStorageAccountId` | string | `''` | ID of the runbook storage account. |
| `tags` | object | `{object}` | Tags of the Automation Account resource. |
| `uri` | string | `''` | The uri of the runbook content. |
| `version` | string | `''` | The version of the runbook content. |

**Generated parameters**
| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `baseTime` | string | `[utcNow('u')]` | Time used as a basis for e.g. the schedule start date. |


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
| `name` | string | The name of the deployed runbook |
| `resourceGroupName` | string | The resource group of the deployed runbook |
| `resourceId` | string | The resource ID of the deployed runbook |

## Template references

- [Automationaccounts/Runbooks](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Automation/2019-06-01/automationAccounts/runbooks)
