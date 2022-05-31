# Network Watchers Connection Monitors `[Microsoft.Network/networkWatchers/connectionMonitors]`

This template deploys Connection Monitors.

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Network/networkWatchers/connectionMonitors` | 2021-05-01 |

## Parameters

**Optional parameters**
| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `enableDefaultTelemetry` | bool | `True` | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `endpoints` | array | `[]` | List of connection monitor endpoints. |
| `location` | string | `[resourceGroup().location]` | Location for all resources. |
| `name` | string |  | Name of the resource. |
| `networkWatcherName` | string | `[format('NetworkWatcher_{0}', resourceGroup().location)]` | Name of the network watcher resource. Must be in the resource group where the Flow log will be created and same region as the NSG |
| `tags` | object | `{object}` | Tags of the resource. |
| `testConfigurations` | array | `[]` | List of connection monitor test configurations. |
| `testGroups` | array | `[]` | List of connection monitor test groups. |
| `workspaceResourceId` | string | `''` | Specify the Log Analytics Workspace Resource ID |


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
| `name` | string | The name of the deployed connection monitor |
| `resourceGroupName` | string | The resource group the connection monitor was deployed into |
| `resourceId` | string | The resource ID of the deployed connection monitor |

## Template references

- [Networkwatchers/Connectionmonitors](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-05-01/networkWatchers/connectionMonitors)
