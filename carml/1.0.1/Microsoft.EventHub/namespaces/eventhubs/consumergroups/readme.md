# EventHub Namespace EventHubs Consumer Group `[Microsoft.EventHub/namespaces/eventhubs/consumergroups]`

This module deploys an EventHub Namespace EventHubs Consumer Group

## Navigation

- [Resource Types](#Resource-Types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource Types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.EventHub/namespaces/eventhubs/consumergroups` | 2021-06-01-preview |

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `eventHubName` | string | The name of the event hub namespace event hub |
| `name` | string | The name of the consumer group |
| `namespaceName` | string | The name of the event hub namespace |

**Optional parameters**
| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `enableDefaultTelemetry` | bool | `True` | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `userMetadata` | string | `''` | User Metadata is a placeholder to store user-defined string data with maximum length 1024. e.g. it can be used to store descriptive data, such as list of teams and their contact information also user-defined configuration settings can be stored. |


## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the consumer group. |
| `resourceGroupName` | string | The name of the resource group the consumer group was created in. |
| `resourceId` | string | The resource ID of the consumer group. |

## Template references

- [Namespaces/Eventhubs/Consumergroups](https://docs.microsoft.com/en-us/azure/templates/Microsoft.EventHub/2021-06-01-preview/namespaces/eventhubs/consumergroups)
