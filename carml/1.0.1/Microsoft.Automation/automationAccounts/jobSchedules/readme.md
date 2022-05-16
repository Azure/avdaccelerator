# Automation Account Job Schedules `[Microsoft.Automation/automationAccounts/jobSchedules]`

This module deploys an Azure Automation Account Job Schedule.

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Automation/automationAccounts/jobSchedules` | 2020-01-13-preview |

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `automationAccountName` | string | Name of the parent Automation Account. |
| `runbookName` | string | The runbook property associated with the entity. |
| `scheduleName` | string | The schedule property associated with the entity. |

**Optional parameters**
| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `enableDefaultTelemetry` | bool | `True` | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `name` | string | `[newGuid()]` | Name of the Automation Account job schedule. Must be a GUID. If not provided, a new GUID is generated. |
| `parameters` | object | `{object}` | List of job properties. |
| `runOn` | string | `''` | The hybrid worker group that the scheduled job should run on. |


## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the deployed job schedule |
| `resourceGroupName` | string | The resource group of the deployed job schedule |
| `resourceId` | string | The resource ID of the deployed job schedule |

## Template references

- [Automationaccounts/Jobschedules](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Automation/2020-01-13-preview/automationAccounts/jobSchedules)
