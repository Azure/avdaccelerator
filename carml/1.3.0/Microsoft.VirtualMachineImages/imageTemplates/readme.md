# Image Templates `[Microsoft.VirtualMachineImages/imageTemplates]`

This module deploys an image template that can be consumed by the Azure Image Builder (AIB) service.

## Navigation

- [Resource types](#Resource-types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Cross-referenced modules](#Cross-referenced-modules)
- [Deployment examples](#Deployment-examples)

## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Authorization/locks` | [2020-05-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2020-05-01/locks) |
| `Microsoft.Authorization/roleAssignments` | [2022-04-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments) |
| `Microsoft.VirtualMachineImages/imageTemplates` | [2020-02-14](https://docs.microsoft.com/en-us/azure/templates/Microsoft.VirtualMachineImages/2020-02-14/imageTemplates) |

## Parameters

**Required parameters**

| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `customizationSteps` | array | Customization steps to be run when building the VM image. |
| `imageSource` | object | Image source definition in object format. |
| `name` | string | Name prefix of the Image Template to be built by the Azure Image Builder service. |
| `userMsiName` | string | Name of the User Assigned Identity to be used to deploy Image Templates in Azure Image Builder. |

**Optional parameters**

| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `buildTimeoutInMinutes` | int | `0` |  | Image build timeout in minutes. Allowed values: 0-960. 0 means the default 240 minutes. |
| `enableDefaultTelemetry` | bool | `True` |  | Enable telemetry via a Globally Unique Identifier (GUID). |
| `imageReplicationRegions` | array | `[]` |  | List of the regions the image produced by this solution should be stored in the Shared Image Gallery. When left empty, the deployment's location will be taken as a default value. |
| `location` | string | `[resourceGroup().location]` |  | Location for all resources. |
| `lock` | string | `''` | `['', CanNotDelete, ReadOnly]` | Specify the type of lock. |
| `managedImageName` | string | `''` |  | Name of the managed image that will be created in the AIB resourcegroup. |
| `osDiskSizeGB` | int | `128` |  | Specifies the size of OS disk. |
| `roleAssignments` | array | `[]` |  | Array of role assignment objects that contain the 'roleDefinitionIdOrName' and 'principalId' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'. |
| `sigImageDefinitionId` | string | `''` |  | Resource ID of Shared Image Gallery to distribute image to, e.g.: /subscriptions/<subscriptionID>/resourceGroups/<SIG resourcegroup>/providers/Microsoft.Compute/galleries/<SIG name>/images/<image definition>. |
| `subnetId` | string | `''` |  | Resource ID of an already existing subnet, e.g. '/subscriptions/<subscriptionId>/resourceGroups/<resourceGroupName>/providers/Microsoft.Network/virtualNetworks/<vnetName>/subnets/<subnetName>'. If no value is provided, a new VNET will be created in the target Resource Group. |
| `tags` | object | `{object}` |  | Tags of the resource. |
| `unManagedImageName` | string | `''` |  | Name of the unmanaged image that will be created in the AIB resourcegroup. |
| `userMsiResourceGroup` | string | `[resourceGroup().name]` |  | Resource group of the user assigned identity. |
| `vmSize` | string | `'Standard_D2s_v3'` |  | Specifies the size for the VM. |

**Generated parameters**

| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `baseTime` | string | `[utcNow('yyyy-MM-dd-HH-mm-ss')]` | Do not provide a value! This date value is used to generate a unique image template name. |


### Parameter Usage: `imageSource`

Tag names and tag values can be provided as needed. A tag can be left without a value.

#### Platform Image

<details>

<summary>Parameter JSON format</summary>

```json
"source": {
    "type": "PlatformImage",
    "publisher": "MicrosoftWindowsDesktop",
    "offer": "Windows-10",
    "sku": "19h2-evd",
    "version": "latest"
}
```

</details>

<details>

<summary>Bicep format</summary>

```bicep
source: {
    type: 'PlatformImage'
    publisher: 'MicrosoftWindowsDesktop'
    offer: 'Windows-10'
    sku: '19h2-evd'
    version: 'latest'
}
```

</details>
<p>

#### Managed Image

<details>

<summary>Parameter JSON format</summary>

```json
"source": {
    "type": "ManagedImage",
    "imageId": "/subscriptions/<subscriptionId>/resourceGroups/{destinationResourceGroupName}/providers/Microsoft.Compute/images/<imageName>"
}
```

</details>

<details>

<summary>Bicep format</summary>

```bicep
source: {
    type: 'ManagedImage'
    imageId: '/subscriptions/<subscriptionId>/resourceGroups/{destinationResourceGroupName}/providers/Microsoft.Compute/images/<imageName>'
}
```

</details>
<p>

#### Shared Image

<details>

<summary>Parameter JSON format</summary>

```json
"source": {
    "type": "SharedImageVersion",
    "imageVersionID": "/subscriptions/<subscriptionId>/resourceGroups/<resourceGroup>/providers/Microsoft.Compute/galleries/<sharedImageGalleryName>/images/<imageDefinitionName/versions/<imageVersion>"
}
```

</details>

<details>

<summary>Bicep format</summary>

```bicep
source: {
    type: 'SharedImageVersion'
    imageVersionID: '/subscriptions/<subscriptionId>/resourceGroups/<resourceGroup>/providers/Microsoft.Compute/galleries/<sharedImageGalleryName>/images/<imageDefinitionName/versions/<imageVersion>'
}
```

</details>
<p>

### Parameter Usage: `tags`

Tag names and tag values can be provided as needed. A tag can be left without a value.

<details>

<summary>Parameter JSON format</summary>

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

</details>

<details>

<summary>Bicep format</summary>

```bicep
tags: {
    Environment: 'Non-Prod'
    Contact: 'test.user@testcompany.com'
    PurchaseOrder: '1234'
    CostCenter: '7890'
    ServiceName: 'DeploymentValidation'
    Role: 'DeploymentValidation'
}
```

</details>
<p>

### Parameter Usage: `roleAssignments`

Create a role assignment for the given resource. If you want to assign a service principal / managed identity that is created in the same deployment, make sure to also specify the `'principalType'` parameter and set it to `'ServicePrincipal'`. This will ensure the role assignment waits for the principal's propagation in Azure.

<details>

<summary>Parameter JSON format</summary>

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

</details>

<details>

<summary>Bicep format</summary>

```bicep
roleAssignments: [
    {
        roleDefinitionIdOrName: 'Reader'
        description: 'Reader Role Assignment'
        principalIds: [
            '12345678-1234-1234-1234-123456789012' // object 1
            '78945612-1234-1234-1234-123456789012' // object 2
        ]
    }
    {
        roleDefinitionIdOrName: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'
        principalIds: [
            '12345678-1234-1234-1234-123456789012' // object 1
        ]
        principalType: 'ServicePrincipal'
    }
]
```

</details>
<p>

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The full name of the deployed image template. |
| `namePrefix` | string | The prefix of the image template name provided as input. |
| `resourceGroupName` | string | The resource group the image template was deployed into. |
| `resourceId` | string | The resource ID of the image template. |
| `runThisCommand` | string | The command to run in order to trigger the image build. |

## Cross-referenced modules

_None_

## Deployment examples

The following module usage examples are retrieved from the content of the files hosted in the module's `.test` folder.
   >**Note**: The name of each example is based on the name of the file from which it is taken.

   >**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

<h3>Example 1: Common</h3>

<details>

<summary>via Bicep module</summary>

```bicep
module imageTemplates './Microsoft.VirtualMachineImages/imageTemplates/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-test-vmicom'
  params: {
    // Required parameters
    customizationSteps: [
      {
        restartTimeout: '30m'
        type: 'WindowsRestart'
      }
    ]
    imageSource: {
      offer: 'Windows-10'
      publisher: 'MicrosoftWindowsDesktop'
      sku: '19h2-evd'
      type: 'PlatformImage'
      version: 'latest'
    }
    name: '<<namePrefix>>vmicom001'
    userMsiName: '<userMsiName>'
    // Non-required parameters
    buildTimeoutInMinutes: 0
    enableDefaultTelemetry: '<enableDefaultTelemetry>'
    imageReplicationRegions: []
    lock: 'CanNotDelete'
    managedImageName: '<<namePrefix>>-mi-vmicom-001'
    osDiskSizeGB: 127
    roleAssignments: [
      {
        principalIds: [
          '<managedIdentityPrincipalId>'
        ]
        principalType: 'ServicePrincipal'
        roleDefinitionIdOrName: 'Reader'
      }
    ]
    sigImageDefinitionId: '<sigImageDefinitionId>'
    subnetId: ''
    unManagedImageName: '<<namePrefix>>-umi-vmicom-001'
    userMsiResourceGroup: '<userMsiResourceGroup>'
    vmSize: 'Standard_D2s_v3'
  }
}
```

</details>
<p>

<details>

<summary>via JSON Parameter file</summary>

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    // Required parameters
    "customizationSteps": {
      "value": [
        {
          "restartTimeout": "30m",
          "type": "WindowsRestart"
        }
      ]
    },
    "imageSource": {
      "value": {
        "offer": "Windows-10",
        "publisher": "MicrosoftWindowsDesktop",
        "sku": "19h2-evd",
        "type": "PlatformImage",
        "version": "latest"
      }
    },
    "name": {
      "value": "<<namePrefix>>vmicom001"
    },
    "userMsiName": {
      "value": "<userMsiName>"
    },
    // Non-required parameters
    "buildTimeoutInMinutes": {
      "value": 0
    },
    "enableDefaultTelemetry": {
      "value": "<enableDefaultTelemetry>"
    },
    "imageReplicationRegions": {
      "value": []
    },
    "lock": {
      "value": "CanNotDelete"
    },
    "managedImageName": {
      "value": "<<namePrefix>>-mi-vmicom-001"
    },
    "osDiskSizeGB": {
      "value": 127
    },
    "roleAssignments": {
      "value": [
        {
          "principalIds": [
            "<managedIdentityPrincipalId>"
          ],
          "principalType": "ServicePrincipal",
          "roleDefinitionIdOrName": "Reader"
        }
      ]
    },
    "sigImageDefinitionId": {
      "value": "<sigImageDefinitionId>"
    },
    "subnetId": {
      "value": ""
    },
    "unManagedImageName": {
      "value": "<<namePrefix>>-umi-vmicom-001"
    },
    "userMsiResourceGroup": {
      "value": "<userMsiResourceGroup>"
    },
    "vmSize": {
      "value": "Standard_D2s_v3"
    }
  }
}
```

</details>
<p>
