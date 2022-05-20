# Automation Account Schedules `[Microsoft.Automation/automationAccounts/schedules]`

This module deploys an Azure Automation Account Schedule.

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Automation/automationAccounts/schedules` | 2020-01-13-preview |

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `automationAccountName` | string | Name of the parent Automation Account. |
| `name` | string | Name of the Automation Account schedule. |

**Optional parameters**
| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `advancedSchedule` | object | `{object}` |  | The properties of the create Advanced Schedule. |
| `enableDefaultTelemetry` | bool | `True` |  | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `expiryTime` | string | `''` |  | The end time of the schedule. |
| `frequency` | string | `'OneTime'` | `[Day, Hour, Minute, Month, OneTime, Week]` | The frequency of the schedule. |
| `interval` | int | `0` |  | Anything |
| `scheduleDescription` | string | `''` |  | The description of the schedule. |
| `startTime` | string | `''` |  | The start time of the schedule. |
| `timeZone` | string | `''` |  | The time zone of the schedule. |

**Generated parameters**
| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `baseTime` | string | `[utcNow('u')]` | Time used as a basis for e.g. the schedule start date. |


## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the deployed schedule |
| `resourceGroupName` | string | The resource group of the deployed schedule |
| `resourceId` | string | The resource ID of the deployed schedule |

## Template references

- [Automationaccounts/Schedules](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Automation/2020-01-13-preview/automationAccounts/schedules)
