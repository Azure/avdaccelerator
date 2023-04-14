# Operationalinsights Workspaces Datasources `[Microsoft.OperationalInsights/workspaces/dataSources]`

This template deploys a data source for a Log Analytics workspace.

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.OperationalInsights/workspaces/dataSources` | 2020-08-01 |

## Parameters

**Required parameters**
| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `kind` | string | `'AzureActivityLog'` | `[AzureActivityLog, WindowsEvent, WindowsPerformanceCounter, IISLogs, LinuxSyslog, LinuxSyslogCollection, LinuxPerformanceObject, LinuxPerformanceCollection]` | The kind of the DataSource. |
| `logAnalyticsWorkspaceName` | string |  |  | Name of the Log Analytics workspace |
| `name` | string |  |  | Name of the solution |

**Optional parameters**
| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `counterName` | string | `''` | Counter name to configure when kind is WindowsPerformanceCounter. |
| `enableDefaultTelemetry` | bool | `True` | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `eventLogName` | string | `''` | Windows event log name to configure when kind is WindowsEvent. |
| `eventTypes` | array | `[]` | Windows event types to configure when kind is WindowsEvent. |
| `instanceName` | string | `'*'` | Name of the instance to configure when kind is WindowsPerformanceCounter or LinuxPerformanceObject. |
| `intervalSeconds` | int | `60` | Interval in seconds to configure when kind is WindowsPerformanceCounter or LinuxPerformanceObject. |
| `linkedResourceId` | string | `''` | Resource ID of the resource to be linked. |
| `objectName` | string | `''` | Name of the object to configure when kind is WindowsPerformanceCounter or LinuxPerformanceObject. |
| `performanceCounters` | array | `[]` | List of counters to configure when the kind is LinuxPerformanceObject. |
| `state` | string | `''` | State to configure when kind is IISLogs or LinuxSyslogCollection or LinuxPerformanceCollection. |
| `syslogName` | string | `''` | System log to configure when kind is LinuxSyslog. |
| `syslogSeverities` | array | `[]` | Severities to configure when kind is LinuxSyslog. |
| `tags` | object | `{object}` | Tags to configure in the resource. |


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
| `name` | string | The name of the deployed data source |
| `resourceGroupName` | string | The resource group where the data source is deployed |
| `resourceId` | string | The resource ID of the deployed data source |

## Template references

- [Workspaces/Datasources](https://docs.microsoft.com/en-us/azure/templates/Microsoft.OperationalInsights/2020-08-01/workspaces/dataSources)
