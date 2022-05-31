# Shared Image Definition `[Microsoft.Compute/galleries/images]`

This module deploys an Image Definition in a Shared Image Gallery.

## Navigation

- [Resource types](#Resource-types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Template references](#Template-references)

## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Authorization/roleAssignments` | 2021-04-01-preview |
| `Microsoft.Compute/galleries/images` | 2020-09-30 |

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `galleryName` | string | Name of the Azure Shared Image Gallery |
| `name` | string | Name of the image definition. |

**Optional parameters**
| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `enableDefaultTelemetry` | bool | `True` |  | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `endOfLife` | string | `''` |  | The end of life date of the gallery Image Definition. This property can be used for decommissioning purposes. This property is updatable. Allowed format: 2020-01-10T23:00:00.000Z |
| `eula` | string | `''` |  | The Eula agreement for the gallery Image Definition. Has to be a valid URL. |
| `excludedDiskTypes` | array | `[]` |  | List of the excluded disk types. E.g. Standard_LRS |
| `hyperVGeneration` | string | `'V1'` | `[V1, V2]` | The hypervisor generation of the Virtual Machine. Applicable to OS disks only. - V1 or V2 |
| `imageDefinitionDescription` | string | `''` |  | The description of this gallery Image Definition resource. This property is updatable. |
| `location` | string | `[resourceGroup().location]` |  | Location for all resources. |
| `maxRecommendedMemory` | int | `16` |  | The maximum amount of RAM in GB recommended for this image. |
| `maxRecommendedvCPUs` | int | `4` |  | The maximum number of the CPU cores recommended for this image. |
| `minRecommendedMemory` | int | `4` |  | The minimum amount of RAM in GB recommended for this image. |
| `minRecommendedvCPUs` | int | `1` |  | The minimum number of the CPU cores recommended for this image. |
| `offer` | string | `'WindowsServer'` |  | The name of the gallery Image Definition offer. |
| `osState` | string | `'Generalized'` | `[Generalized, Specialized]` | This property allows the user to specify whether the virtual machines created under this image are 'Generalized' or 'Specialized'. |
| `osType` | string | `'Windows'` | `[Windows, Linux]` | OS type of the image to be created. |
| `planName` | string | `''` |  | The plan ID. |
| `planPublisherName` | string | `''` |  | The publisher ID. |
| `privacyStatementUri` | string | `''` |  | The privacy statement uri. Has to be a valid URL. |
| `productName` | string | `''` |  | The product ID. |
| `publisher` | string | `'MicrosoftWindowsServer'` |  | The name of the gallery Image Definition publisher. |
| `releaseNoteUri` | string | `''` |  | The release note uri. Has to be a valid URL. |
| `roleAssignments` | array | `[]` |  | Array of role assignment objects that contain the 'roleDefinitionIdOrName' and 'principalId' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11' |
| `sku` | string | `'2019-Datacenter'` |  | The name of the gallery Image Definition SKU. |
| `tags` | object | `{object}` |  | Tags for all resources. |


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
| `name` | string | The name of the image |
| `resourceGroupName` | string | The resource group the image was deployed into |
| `resourceId` | string | The resource ID of the image |

## Template references

- [Galleries/Images](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Compute/2020-09-30/galleries/images)
- [Roleassignments](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/roleAssignments)
