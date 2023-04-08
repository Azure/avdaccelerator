# EventHub `[Microsoft.EventHub/namespaces/eventhubs]`

This module deploys an Event Hub.

## Navigation

- [Resource types](#Resource-types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Authorization/locks` | 2017-04-01 |
| `Microsoft.Authorization/roleAssignments` | 2021-04-01-preview |
| `Microsoft.EventHub/namespaces/eventhubs` | 2021-06-01-preview |
| `Microsoft.EventHub/namespaces/eventhubs/authorizationRules` | 2021-06-01-preview |
| `Microsoft.EventHub/namespaces/eventhubs/consumergroups` | 2021-06-01-preview |

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `name` | string | The name of the event hub |
| `namespaceName` | string | The name of the event hub namespace |

**Optional parameters**
| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `authorizationRules` | _[authorizationRules](authorizationRules/readme.md)_ array | `[System.Collections.Hashtable]` |  | Authorization Rules for the event hub |
| `captureDescriptionDestinationArchiveNameFormat` | string | `'{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}'` |  | Blob naming convention for archive, e.g. {Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}. Here all the parameters (Namespace,EventHub .. etc) are mandatory irrespective of order |
| `captureDescriptionDestinationBlobContainer` | string | `''` |  | Blob container Name |
| `captureDescriptionDestinationName` | string | `'EventHubArchive.AzureBlockBlob'` |  | Name for capture destination |
| `captureDescriptionDestinationStorageAccountResourceId` | string | `''` |  | Resource ID of the storage account to be used to create the blobs |
| `captureDescriptionEnabled` | bool | `False` |  | A value that indicates whether capture description is enabled. |
| `captureDescriptionEncoding` | string | `'Avro'` | `[Avro, AvroDeflate]` | Enumerates the possible values for the encoding format of capture description. Note: "AvroDeflate" will be deprecated in New API Version |
| `captureDescriptionIntervalInSeconds` | int | `300` |  | The time window allows you to set the frequency with which the capture to Azure Blobs will happen |
| `captureDescriptionSizeLimitInBytes` | int | `314572800` |  | The size window defines the amount of data built up in your Event Hub before an capture operation |
| `captureDescriptionSkipEmptyArchives` | bool | `False` |  | A value that indicates whether to Skip Empty Archives |
| `consumerGroups` | _[consumerGroups](consumerGroups/readme.md)_ array | `[System.Collections.Hashtable]` |  | The consumer groups to create in this event hub instance |
| `enableDefaultTelemetry` | bool | `True` |  | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `lock` | string | `'NotSpecified'` | `[CanNotDelete, NotSpecified, ReadOnly]` | Specify the type of lock. |
| `messageRetentionInDays` | int | `1` |  | Number of days to retain the events for this Event Hub, value should be 1 to 7 days |
| `partitionCount` | int | `2` |  | Number of partitions created for the Event Hub, allowed values are from 1 to 32 partitions. |
| `roleAssignments` | array | `[]` |  | Array of role assignment objects that contain the 'roleDefinitionIdOrName' and 'principalId' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11' |
| `status` | string | `'Active'` | `[Active, Creating, Deleting, Disabled, ReceiveDisabled, Renaming, Restoring, SendDisabled, Unknown]` | Enumerates the possible values for the status of the Event Hub. |


### Parameter Usage: `roleAssignments`

Create a role assignment for the given resource. If you want to assign a service principal / managed identity that is created in the same deployment, make sure to also specify the `'principalType'` parameter and set it to `'ServicePrincipal'`. This will ensure the role assignment waits for the principal's propagation in Azure.

```json
"roleAssignments": {
    "value": [
        {
            "roleDefinitionIdOrName": "Reader",
            "description": "Reader Role Assignment",
            "principalIds": [
                "12345678-1234-1234-1234-123456789012", // object 1
                "78945612-1234-1234-1234-123456789012" // object 2
            ]
        },
        {
            "roleDefinitionIdOrName": "/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11",
            "principalIds": [
                "12345678-1234-1234-1234-123456789012" // object 1
            ],
            "principalType": "ServicePrincipal"
        }
    ]
}
```

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `eventHubId` | string | The resource ID of the event hub. |
| `name` | string | The name of the event hub. |
| `resourceGroupName` | string | The resource group the event hub was deployed into. |
| `resourceId` | string | The authentication rule resource ID of the event hub. |

## Template references

- [Locks](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2017-04-01/locks)
- [Namespaces/Eventhubs](https://docs.microsoft.com/en-us/azure/templates/Microsoft.EventHub/2021-06-01-preview/namespaces/eventhubs)
- [Namespaces/Eventhubs/Authorizationrules](https://docs.microsoft.com/en-us/azure/templates/Microsoft.EventHub/2021-06-01-preview/namespaces/eventhubs/authorizationRules)
- [Namespaces/Eventhubs/Consumergroups](https://docs.microsoft.com/en-us/azure/templates/Microsoft.EventHub/2021-06-01-preview/namespaces/eventhubs/consumergroups)
- [Roleassignments](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/roleAssignments)
