# SQL Managed Instance Database Backup Long-Term Retention Policy `[Microsoft.Sql/managedInstances/databases/backupLongTermRetentionPolicies]`

This module deploys a backup long-term retention policies for SQL Managed Instance databases

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Sql/managedInstances/databases/backupLongTermRetentionPolicies` | 2021-02-01-preview |

## Parameters

| Parameter Name | Type | Default Value | Possible Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `cuaId` | string |  |  | Optional. Customer Usage Attribution ID (GUID). This GUID must be previously registered |
| `databaseName` | string |  |  | Required. The name of the managed instance database |
| `managedInstanceName` | string |  |  | Required. Name of the managed instance. |
| `monthlyRetention` | string | `P1Y` |  | Optional. The monthly retention policy for an LTR backup in an ISO 8601 format. |
| `name` | string |  |  | Required. The name of the Long Term Retention backup policy. For example "default". |
| `weeklyRetention` | string | `P1M` |  | Optional. The weekly retention policy for an LTR backup in an ISO 8601 format. |
| `weekOfYear` | int | `5` |  | Optional. The week of year to take the yearly backup in an ISO 8601 format. |
| `yearlyRetention` | string | `P5Y` |  | Optional. The yearly retention policy for an LTR backup in an ISO 8601 format. |

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the deployed database backup long-term retention policy |
| `resourceGroupName` | string | The resource group of the deployed database backup long-term retention policy |
| `resourceId` | string | The resource ID of the deployed database backup long-term retention policy |

## Template references

- [Managedinstances/Databases/Backuplongtermretentionpolicies](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Sql/2021-02-01-preview/managedInstances/databases/backupLongTermRetentionPolicies)
