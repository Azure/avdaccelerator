# Storage Accounts `[Microsoft.Storage/storageAccounts]`

This module is used to deploy a storage account, with the ability to deploy 1 or more blob containers, file shares, tables and queues. Optional ACLs can be configured on the storage account and optional RBAC can be assigned on the storage account and on each child resource.

## Navigation

- [Resource types](#Resource-types)
- [Parameters](#Parameters)
- [Outputs](#Outputs)
- [Considerations](#Considerations)
- [Cross-referenced modules](#Cross-referenced-modules)
- [Deployment examples](#Deployment-examples)

## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.Authorization/locks` | [2017-04-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2017-04-01/locks) |
| `Microsoft.Authorization/roleAssignments` | [2022-04-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments) |
| `Microsoft.Insights/diagnosticSettings` | [2021-05-01-preview](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings) |
| `Microsoft.Network/privateEndpoints` | [2021-08-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-08-01/privateEndpoints) |
| `Microsoft.Network/privateEndpoints/privateDnsZoneGroups` | [2021-08-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Network/2021-08-01/privateEndpoints/privateDnsZoneGroups) |
| `Microsoft.Storage/storageAccounts` | [2021-09-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2021-09-01/storageAccounts) |
| `Microsoft.Storage/storageAccounts/blobServices` | [2021-09-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2021-09-01/storageAccounts/blobServices) |
| `Microsoft.Storage/storageAccounts/blobServices/containers` | [2021-09-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2021-09-01/storageAccounts/blobServices/containers) |
| `Microsoft.Storage/storageAccounts/blobServices/containers/immutabilityPolicies` | [2021-09-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2021-09-01/storageAccounts/blobServices/containers/immutabilityPolicies) |
| `Microsoft.Storage/storageAccounts/fileServices` | [2021-09-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2021-09-01/storageAccounts/fileServices) |
| `Microsoft.Storage/storageAccounts/fileServices/shares` | [2021-09-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2021-09-01/storageAccounts/fileServices/shares) |
| `Microsoft.Storage/storageAccounts/managementPolicies` | [2021-09-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2021-09-01/storageAccounts/managementPolicies) |
| `Microsoft.Storage/storageAccounts/queueServices` | [2021-09-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2021-09-01/storageAccounts/queueServices) |
| `Microsoft.Storage/storageAccounts/queueServices/queues` | [2021-09-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2021-09-01/storageAccounts/queueServices/queues) |
| `Microsoft.Storage/storageAccounts/tableServices` | [2021-09-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2021-09-01/storageAccounts/tableServices) |
| `Microsoft.Storage/storageAccounts/tableServices/tables` | [2021-09-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Storage/2021-09-01/storageAccounts/tableServices/tables) |

## Parameters

**Conditional parameters**
| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `cMKUserAssignedIdentityResourceId` | string | `''` | User assigned identity to use when fetching the customer managed key. Required if 'cMKKeyName' is not empty. |

**Optional parameters**
| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `allowBlobPublicAccess` | bool | `False` |  | Indicates whether public access is enabled for all blobs or containers in the storage account. For security reasons, it is recommended to set it to false. |
| `azureFilesIdentityBasedAuthentication` | object | `{object}` |  | Provides the identity based authentication settings for Azure Files. |
| `blobServices` | _[blobServices](blobServices/readme.md)_ object | `{object}` |  | Blob service and containers to deploy. |
| `cMKKeyName` | string | `''` |  | The name of the customer managed key to use for encryption. Cannot be deployed together with the parameter 'systemAssignedIdentity' enabled. |
| `cMKKeyVaultResourceId` | string | `''` |  | The resource ID of a key vault to reference a customer managed key for encryption from. |
| `cMKKeyVersion` | string | `''` |  | The version of the customer managed key to reference for encryption. If not provided, latest is used. |
| `diagnosticEventHubAuthorizationRuleId` | string | `''` |  | Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to. |
| `diagnosticEventHubName` | string | `''` |  | Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. |
| `diagnosticLogsRetentionInDays` | int | `365` |  | Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely. |
| `diagnosticMetricsToEnable` | array | `[Transaction]` | `[Transaction]` | The name of metrics that will be streamed. |
| `diagnosticSettingsName` | string | `[format('{0}-diagnosticSettings', parameters('name'))]` |  | The name of the diagnostic setting, if deployed. |
| `diagnosticStorageAccountId` | string | `''` |  | Resource ID of the diagnostic storage account. |
| `diagnosticWorkspaceId` | string | `''` |  | Resource ID of the diagnostic log analytics workspace. |
| `enableDefaultTelemetry` | bool | `True` |  | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `enableHierarchicalNamespace` | bool | `False` |  | If true, enables Hierarchical Namespace for the storage account. |
| `fileServices` | _[fileServices](fileServices/readme.md)_ object | `{object}` |  | File service and shares to deploy. |
| `location` | string | `[resourceGroup().location]` |  | Location for all resources. |
| `lock` | string | `''` | `['', CanNotDelete, ReadOnly]` | Specify the type of lock. |
| `managementPolicyRules` | array | `[]` |  | The Storage Account ManagementPolicies Rules. |
| `minimumTlsVersion` | string | `'TLS1_2'` | `[TLS1_0, TLS1_1, TLS1_2]` | Set the minimum TLS version on request to storage. |
| `name` | string | `''` |  | Name of the Storage Account. Autogenerated with a unique string if not provided. |
| `networkAcls` | object | `{object}` |  | Networks ACLs, this value contains IPs to whitelist and/or Subnet information. For security reasons, it is recommended to set the DefaultAction Deny. |
| `privateEndpoints` | array | `[]` |  | Configuration details for private endpoints. For security reasons, it is recommended to use private endpoints whenever possible. |
| `publicNetworkAccess` | string | `''` | `['', Disabled, Enabled]` | Whether or not public network access is allowed for this resource. For security reasons it should be disabled. If not specified, it will be disabled by default if private endpoints are set and networkAcls are not set. |
| `queueServices` | _[queueServices](queueServices/readme.md)_ object | `{object}` |  | Queue service and queues to create. |
| `requireInfrastructureEncryption` | bool | `True` |  | A Boolean indicating whether or not the service applies a secondary layer of encryption with platform managed keys for data at rest. For security reasons, it is recommended to set it to true. |
| `roleAssignments` | array | `[]` |  | Array of role assignment objects that contain the 'roleDefinitionIdOrName' and 'principalId' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'. |
| `storageAccountAccessTier` | string | `'Hot'` | `[Cool, Hot]` | Storage Account Access Tier. |
| `storageAccountKind` | string | `'StorageV2'` | `[BlobStorage, BlockBlobStorage, FileStorage, Storage, StorageV2]` | Type of Storage Account to create. |
| `storageAccountSku` | string | `'Standard_GRS'` | `[Premium_LRS, Premium_ZRS, Standard_GRS, Standard_GZRS, Standard_LRS, Standard_RAGRS, Standard_RAGZRS, Standard_ZRS]` | Storage Account Sku Name. |
| `supportsHttpsTrafficOnly` | bool | `True` |  | Allows HTTPS traffic only to storage service if sets to true. |
| `systemAssignedIdentity` | bool | `False` |  | Enables system assigned managed identity on the resource. |
| `tableServices` | _[tableServices](tableServices/readme.md)_ object | `{object}` |  | Table service and tables to create. |
| `tags` | object | `{object}` |  | Tags of the resource. |
| `userAssignedIdentities` | object | `{object}` |  | The ID(s) to assign to the resource. |

**Generated parameters**
| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `basetime` | string | `[utcNow('u')]` | Do not provide a value! This date value is used to generate a SAS token to access the modules. |


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

### Parameter Usage: `networkAcls`

<details>

<summary>Parameter JSON format</summary>

```json
"networkAcls": {
    "value": {
        "bypass": "AzureServices",
        "defaultAction": "Deny",
        "virtualNetworkRules": [
            {
                "id": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/sxx-az-vnet-x-001/subnets/sxx-az-subnet-x-001"
            }
        ],
        "ipRules": [
            {
                "action": "Allow",
                "value": "1.1.1.1"
            }
        ]
    }
}
```

</details>

<details>

<summary>Bicep format</summary>

```bicep
networkAcls: {
    bypass: 'AzureServices'
    defaultAction: 'Deny'
    virtualNetworkRules: [
        {
            id: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/sxx-az-vnet-x-001/subnets/sxx-az-subnet-x-001'
        }
    ]
    ipRules: [
        {
            action: 'Allow'
            value: '1.1.1.1'
        }
    ]
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

### Parameter Usage: `privateEndpoints`

To use Private Endpoint the following dependencies must be deployed:

- Destination subnet must be created with the following configuration option - `"privateEndpointNetworkPolicies": "Disabled"`.  Setting this option acknowledges that NSG rules are not applied to Private Endpoints (this capability is coming soon). A full example is available in the Virtual Network Module.
- Although not strictly required, it is highly recommended to first create a private DNS Zone to host Private Endpoint DNS records. See [Azure Private Endpoint DNS configuration](https://docs.microsoft.com/en-us/azure/private-link/private-endpoint-dns) for more information.

<details>

<summary>Parameter JSON format</summary>

```json
"privateEndpoints": {
    "value": [
        // Example showing all available fields
        {
            "name": "sxx-az-pe", // Optional: Name will be automatically generated if one is not provided here
            "subnetResourceId": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/sxx-az-vnet-x-001/subnets/sxx-az-subnet-x-001",
            "service": "<<serviceName>>", // e.g. vault, registry, file, blob, queue, table etc.
            "privateDnsZoneResourceIds": [ // Optional: No DNS record will be created if a private DNS zone Resource ID is not specified
                "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
            ],
            "customDnsConfigs": [ // Optional
                {
                    "fqdn": "customname.test.local",
                    "ipAddresses": [
                        "10.10.10.10"
                    ]
                }
            ]
        },
        // Example showing only mandatory fields
        {
            "subnetResourceId": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/sxx-az-vnet-x-001/subnets/sxx-az-subnet-x-001",
            "service": "<<serviceName>>" // e.g. vault, registry, file, blob, queue, table etc.
        }
    ]
}
```

</details>

<details>

<summary>Bicep format</summary>

```bicep
privateEndpoints:  [
    // Example showing all available fields
    {
        name: 'sxx-az-pe' // Optional: Name will be automatically generated if one is not provided here
        subnetResourceId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/sxx-az-vnet-x-001/subnets/sxx-az-subnet-x-001'
        service: '<<serviceName>>' // e.g. vault registry file blob queue table etc.
        privateDnsZoneResourceIds: [ // Optional: No DNS record will be created if a private DNS zone Resource ID is not specified
            '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'
        ]
        // Optional
        customDnsConfigs: [
            {
                fqdn: 'customname.test.local'
                ipAddresses: [
                    '10.10.10.10'
                ]
            }
        ]
    }
    // Example showing only mandatory fields
    {
        subnetResourceId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/sxx-az-vnet-x-001/subnets/sxx-az-subnet-x-001'
        service: '<<serviceName>>' // e.g. vault registry file blob queue table etc.
    }
]
```

</details>
<p>

### Parameter Usage: `userAssignedIdentities`

You can specify multiple user assigned identities to a resource by providing additional resource IDs using the following format:

<details>

<summary>Parameter JSON format</summary>

```json
"userAssignedIdentities": {
    "value": {
        "/subscriptions/12345678-1234-1234-1234-123456789012/resourcegroups/validation-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/adp-sxx-az-msi-x-001": {},
        "/subscriptions/12345678-1234-1234-1234-123456789012/resourcegroups/validation-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/adp-sxx-az-msi-x-002": {}
    }
}
```

</details>

<details>

<summary>Bicep format</summary>

```bicep
userAssignedIdentities: {
    '/subscriptions/12345678-1234-1234-1234-123456789012/resourcegroups/validation-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/adp-sxx-az-msi-x-001': {}
    '/subscriptions/12345678-1234-1234-1234-123456789012/resourcegroups/validation-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/adp-sxx-az-msi-x-002': {}
}
```

</details>
<p>

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The name of the deployed storage account. |
| `primaryBlobEndpoint` | string | The primary blob endpoint reference if blob services are deployed. |
| `resourceGroupName` | string | The resource group of the deployed storage account. |
| `resourceId` | string | The resource ID of the deployed storage account. |
| `systemAssignedPrincipalId` | string | The principal ID of the system assigned identity. |

## Considerations

This is a generic module for deploying a Storage Account. Any customization for different storage needs (such as a diagnostic or other storage account) need to be done through the Archetype.
The hierarchical namespace of the storage account (see parameter `enableHierarchicalNamespace`), can be only set at creation time.

## Cross-referenced modules

This section gives you an overview of all local-referenced module files (i.e., other CARML modules that are referenced in this module) and all remote-referenced files (i.e., Bicep modules that are referenced from a Bicep Registry or Template Specs).

| Reference | Type |
| :-- | :-- |
| `Microsoft.Network/privateEndpoints` | Local reference |

## Deployment examples

The following module usage examples are retrieved from the content of the files hosted in the module's `.test` folder.
   >**Note**: The name of each example is based on the name of the file from which it is taken.
   >**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

<h3>Example 1: Encr</h3>

<details>

<summary>via Bicep module</summary>

```bicep
module storageAccounts './Microsoft.Storage/storageAccounts/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-storageAccounts'
  params: {
    allowBlobPublicAccess: false
    blobServices: {
      containers: [
        {
          name: '<<namePrefix>>container'
          publicAccess: 'None'
        }
      ]
    }
    cMKKeyName: 'keyEncryptionKey'
    cMKKeyVaultResourceId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.KeyVault/vaults/adp-<<namePrefix>>-az-kv-nopr-002'
    cMKUserAssignedIdentityResourceId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/adp-<<namePrefix>>-az-msi-x-001'
    name: '<<namePrefix>>azsaencr001'
    privateEndpoints: [
      {
        privateDnsZoneGroups: {
          privateDNSResourceIds: [
            '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'
          ]
        }
        service: 'blob'
        subnetResourceId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/adp-<<namePrefix>>-az-vnet-x-001/subnets/<<namePrefix>>-az-subnet-x-005-privateEndpoints'
      }
    ]
    requireInfrastructureEncryption: true
    storageAccountSku: 'Standard_LRS'
    systemAssignedIdentity: false
    userAssignedIdentities: {
      '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/adp-<<namePrefix>>-az-msi-x-001': {}
    }
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
    "allowBlobPublicAccess": {
      "value": false
    },
    "blobServices": {
      "value": {
        "containers": [
          {
            "name": "<<namePrefix>>container",
            "publicAccess": "None"
          }
        ]
      }
    },
    "cMKKeyName": {
      "value": "keyEncryptionKey"
    },
    "cMKKeyVaultResourceId": {
      "value": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.KeyVault/vaults/adp-<<namePrefix>>-az-kv-nopr-002"
    },
    "cMKUserAssignedIdentityResourceId": {
      "value": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/adp-<<namePrefix>>-az-msi-x-001"
    },
    "name": {
      "value": "<<namePrefix>>azsaencr001"
    },
    "privateEndpoints": {
      "value": [
        {
          "privateDnsZoneGroups": {
            "privateDNSResourceIds": [
              "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
            ]
          },
          "service": "blob",
          "subnetResourceId": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/adp-<<namePrefix>>-az-vnet-x-001/subnets/<<namePrefix>>-az-subnet-x-005-privateEndpoints"
        }
      ]
    },
    "requireInfrastructureEncryption": {
      "value": true
    },
    "storageAccountSku": {
      "value": "Standard_LRS"
    },
    "systemAssignedIdentity": {
      "value": false
    },
    "userAssignedIdentities": {
      "value": {
        "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/adp-<<namePrefix>>-az-msi-x-001": {}
      }
    }
  }
}
```

</details>
<p>

<h3>Example 2: Min</h3>

<details>

<summary>via Bicep module</summary>

```bicep
module storageAccounts './Microsoft.Storage/storageAccounts/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-storageAccounts'
  params: {
    allowBlobPublicAccess: false
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
    "allowBlobPublicAccess": {
      "value": false
    }
  }
}
```

</details>
<p>

<h3>Example 3: Nfs</h3>

<details>

<summary>via Bicep module</summary>

```bicep
module storageAccounts './Microsoft.Storage/storageAccounts/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-storageAccounts'
  params: {
    allowBlobPublicAccess: false
    diagnosticEventHubAuthorizationRuleId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.EventHub/namespaces/adp-<<namePrefix>>-az-evhns-x-001/AuthorizationRules/RootManageSharedAccessKey'
    diagnosticEventHubName: 'adp-<<namePrefix>>-az-evh-x-001'
    diagnosticLogsRetentionInDays: 7
    diagnosticStorageAccountId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Storage/storageAccounts/adp<<namePrefix>>azsax001'
    diagnosticWorkspaceId: '/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/microsoft.operationalinsights/workspaces/adp-<<namePrefix>>-az-law-x-001'
    fileServices: {
      shares: [
        {
          enabledProtocols: 'NFS'
          name: 'nfsfileshare'
        }
      ]
    }
    name: '<<namePrefix>>azsanfs001'
    roleAssignments: [
      {
        principalIds: [
          '<<deploymentSpId>>'
        ]
        roleDefinitionIdOrName: 'Reader'
      }
    ]
    storageAccountKind: 'FileStorage'
    storageAccountSku: 'Premium_LRS'
    supportsHttpsTrafficOnly: false
    systemAssignedIdentity: true
    userAssignedIdentities: {
      '/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/adp-<<namePrefix>>-az-msi-x-001': {}
    }
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
    "allowBlobPublicAccess": {
      "value": false
    },
    "diagnosticEventHubAuthorizationRuleId": {
      "value": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.EventHub/namespaces/adp-<<namePrefix>>-az-evhns-x-001/AuthorizationRules/RootManageSharedAccessKey"
    },
    "diagnosticEventHubName": {
      "value": "adp-<<namePrefix>>-az-evh-x-001"
    },
    "diagnosticLogsRetentionInDays": {
      "value": 7
    },
    "diagnosticStorageAccountId": {
      "value": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Storage/storageAccounts/adp<<namePrefix>>azsax001"
    },
    "diagnosticWorkspaceId": {
      "value": "/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/microsoft.operationalinsights/workspaces/adp-<<namePrefix>>-az-law-x-001"
    },
    "fileServices": {
      "value": {
        "shares": [
          {
            "enabledProtocols": "NFS",
            "name": "nfsfileshare"
          }
        ]
      }
    },
    "name": {
      "value": "<<namePrefix>>azsanfs001"
    },
    "roleAssignments": {
      "value": [
        {
          "principalIds": [
            "<<deploymentSpId>>"
          ],
          "roleDefinitionIdOrName": "Reader"
        }
      ]
    },
    "storageAccountKind": {
      "value": "FileStorage"
    },
    "storageAccountSku": {
      "value": "Premium_LRS"
    },
    "supportsHttpsTrafficOnly": {
      "value": false
    },
    "systemAssignedIdentity": {
      "value": true
    },
    "userAssignedIdentities": {
      "value": {
        "/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/adp-<<namePrefix>>-az-msi-x-001": {}
      }
    }
  }
}
```

</details>
<p>

<h3>Example 4: Parameters</h3>

<details>

<summary>via Bicep module</summary>

```bicep
module storageAccounts './Microsoft.Storage/storageAccounts/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-storageAccounts'
  params: {
    allowBlobPublicAccess: false
    blobServices: {
      containers: [
        {
          name: 'avdscripts'
          publicAccess: 'None'
          roleAssignments: [
            {
              principalIds: [
                '<<deploymentSpId>>'
              ]
              roleDefinitionIdOrName: 'Reader'
            }
          ]
        }
        {
          allowProtectedAppendWrites: false
          enableWORM: true
          name: 'archivecontainer'
          publicAccess: 'None'
          WORMRetention: 666
        }
      ]
      diagnosticEventHubAuthorizationRuleId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.EventHub/namespaces/adp-<<namePrefix>>-az-evhns-x-001/AuthorizationRules/RootManageSharedAccessKey'
      diagnosticEventHubName: 'adp-<<namePrefix>>-az-evh-x-001'
      diagnosticLogsRetentionInDays: 7
      diagnosticStorageAccountId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Storage/storageAccounts/adp<<namePrefix>>azsax001'
      diagnosticWorkspaceId: '/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/microsoft.operationalinsights/workspaces/adp-<<namePrefix>>-az-law-x-001'
    }
    diagnosticEventHubAuthorizationRuleId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.EventHub/namespaces/adp-<<namePrefix>>-az-evhns-x-001/AuthorizationRules/RootManageSharedAccessKey'
    diagnosticEventHubName: 'adp-<<namePrefix>>-az-evh-x-001'
    diagnosticLogsRetentionInDays: 7
    diagnosticStorageAccountId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Storage/storageAccounts/adp<<namePrefix>>azsax001'
    diagnosticWorkspaceId: '/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/microsoft.operationalinsights/workspaces/adp-<<namePrefix>>-az-law-x-001'
    fileServices: {
      diagnosticEventHubAuthorizationRuleId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.EventHub/namespaces/adp-<<namePrefix>>-az-evhns-x-001/AuthorizationRules/RootManageSharedAccessKey'
      diagnosticEventHubName: 'adp-<<namePrefix>>-az-evh-x-001'
      diagnosticLogsRetentionInDays: 7
      diagnosticStorageAccountId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Storage/storageAccounts/adp<<namePrefix>>azsax001'
      diagnosticWorkspaceId: '/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/microsoft.operationalinsights/workspaces/adp-<<namePrefix>>-az-law-x-001'
      shares: [
        {
          name: 'avdprofiles'
          roleAssignments: [
            {
              principalIds: [
                '<<deploymentSpId>>'
              ]
              roleDefinitionIdOrName: 'Reader'
            }
          ]
          shareQuota: '5120'
        }
        {
          name: 'avdprofiles2'
          shareQuota: '5120'
        }
      ]
    }
    lock: 'CanNotDelete'
    name: '<<namePrefix>>azsax001'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [
        {
          action: 'Allow'
          value: '1.1.1.1'
        }
      ]
      virtualNetworkRules: [
        {
          action: 'Allow'
          id: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/adp-<<namePrefix>>-az-vnet-x-001/subnets/<<namePrefix>>-az-subnet-x-001'
        }
      ]
    }
    privateEndpoints: [
      {
        privateDnsZoneGroups: {
          privateDNSResourceIds: [
            '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net'
          ]
        }
        service: 'blob'
        subnetResourceId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/adp-<<namePrefix>>-az-vnet-x-001/subnets/<<namePrefix>>-az-subnet-x-005-privateEndpoints'
      }
      {
        privateDnsZoneGroups: {
          privateDNSResourceIds: [
            '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/privateDnsZones/privatelink.table.core.windows.net'
          ]
        }
        service: 'table'
        subnetResourceId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/adp-<<namePrefix>>-az-vnet-x-001/subnets/<<namePrefix>>-az-subnet-x-005-privateEndpoints'
      }
      {
        privateDnsZoneGroups: {
          privateDNSResourceIds: [
            '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/privateDnsZones/privatelink.queue.core.windows.net'
          ]
        }
        service: 'queue'
        subnetResourceId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/adp-<<namePrefix>>-az-vnet-x-001/subnets/<<namePrefix>>-az-subnet-x-005-privateEndpoints'
      }
      {
        privateDnsZoneGroups: {
          privateDNSResourceIds: [
            '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net'
          ]
        }
        service: 'file'
        subnetResourceId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/adp-<<namePrefix>>-az-vnet-x-001/subnets/<<namePrefix>>-az-subnet-x-005-privateEndpoints'
      }
    ]
    queueServices: {
      diagnosticEventHubAuthorizationRuleId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.EventHub/namespaces/adp-<<namePrefix>>-az-evhns-x-001/AuthorizationRules/RootManageSharedAccessKey'
      diagnosticEventHubName: 'adp-<<namePrefix>>-az-evh-x-001'
      diagnosticLogsRetentionInDays: 7
      diagnosticStorageAccountId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Storage/storageAccounts/adp<<namePrefix>>azsax001'
      diagnosticWorkspaceId: '/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/microsoft.operationalinsights/workspaces/adp-<<namePrefix>>-az-law-x-001'
      queues: [
        {
          metadata: {}
          name: 'queue1'
          roleAssignments: [
            {
              principalIds: [
                '<<deploymentSpId>>'
              ]
              roleDefinitionIdOrName: 'Reader'
            }
          ]
        }
        {
          metadata: {}
          name: 'queue2'
        }
      ]
    }
    requireInfrastructureEncryption: true
    roleAssignments: [
      {
        principalIds: [
          '<<deploymentSpId>>'
        ]
        roleDefinitionIdOrName: 'Reader'
      }
    ]
    storageAccountSku: 'Standard_LRS'
    systemAssignedIdentity: true
    tableServices: {
      diagnosticEventHubAuthorizationRuleId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.EventHub/namespaces/adp-<<namePrefix>>-az-evhns-x-001/AuthorizationRules/RootManageSharedAccessKey'
      diagnosticEventHubName: 'adp-<<namePrefix>>-az-evh-x-001'
      diagnosticLogsRetentionInDays: 7
      diagnosticStorageAccountId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Storage/storageAccounts/adp<<namePrefix>>azsax001'
      diagnosticWorkspaceId: '/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/microsoft.operationalinsights/workspaces/adp-<<namePrefix>>-az-law-x-001'
      tables: [
        'table1'
        'table2'
      ]
    }
    userAssignedIdentities: {
      '/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/adp-<<namePrefix>>-az-msi-x-001': {}
    }
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
    "allowBlobPublicAccess": {
      "value": false
    },
    "blobServices": {
      "value": {
        "containers": [
          {
            "name": "avdscripts",
            "publicAccess": "None",
            "roleAssignments": [
              {
                "principalIds": [
                  "<<deploymentSpId>>"
                ],
                "roleDefinitionIdOrName": "Reader"
              }
            ]
          },
          {
            "allowProtectedAppendWrites": false,
            "enableWORM": true,
            "name": "archivecontainer",
            "publicAccess": "None",
            "WORMRetention": 666
          }
        ],
        "diagnosticEventHubAuthorizationRuleId": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.EventHub/namespaces/adp-<<namePrefix>>-az-evhns-x-001/AuthorizationRules/RootManageSharedAccessKey",
        "diagnosticEventHubName": "adp-<<namePrefix>>-az-evh-x-001",
        "diagnosticLogsRetentionInDays": 7,
        "diagnosticStorageAccountId": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Storage/storageAccounts/adp<<namePrefix>>azsax001",
        "diagnosticWorkspaceId": "/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/microsoft.operationalinsights/workspaces/adp-<<namePrefix>>-az-law-x-001"
      }
    },
    "diagnosticEventHubAuthorizationRuleId": {
      "value": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.EventHub/namespaces/adp-<<namePrefix>>-az-evhns-x-001/AuthorizationRules/RootManageSharedAccessKey"
    },
    "diagnosticEventHubName": {
      "value": "adp-<<namePrefix>>-az-evh-x-001"
    },
    "diagnosticLogsRetentionInDays": {
      "value": 7
    },
    "diagnosticStorageAccountId": {
      "value": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Storage/storageAccounts/adp<<namePrefix>>azsax001"
    },
    "diagnosticWorkspaceId": {
      "value": "/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/microsoft.operationalinsights/workspaces/adp-<<namePrefix>>-az-law-x-001"
    },
    "fileServices": {
      "value": {
        "diagnosticEventHubAuthorizationRuleId": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.EventHub/namespaces/adp-<<namePrefix>>-az-evhns-x-001/AuthorizationRules/RootManageSharedAccessKey",
        "diagnosticEventHubName": "adp-<<namePrefix>>-az-evh-x-001",
        "diagnosticLogsRetentionInDays": 7,
        "diagnosticStorageAccountId": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Storage/storageAccounts/adp<<namePrefix>>azsax001",
        "diagnosticWorkspaceId": "/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/microsoft.operationalinsights/workspaces/adp-<<namePrefix>>-az-law-x-001",
        "shares": [
          {
            "name": "avdprofiles",
            "roleAssignments": [
              {
                "principalIds": [
                  "<<deploymentSpId>>"
                ],
                "roleDefinitionIdOrName": "Reader"
              }
            ],
            "shareQuota": "5120"
          },
          {
            "name": "avdprofiles2",
            "shareQuota": "5120"
          }
        ]
      }
    },
    "lock": {
      "value": "CanNotDelete"
    },
    "name": {
      "value": "<<namePrefix>>azsax001"
    },
    "networkAcls": {
      "value": {
        "bypass": "AzureServices",
        "defaultAction": "Deny",
        "ipRules": [
          {
            "action": "Allow",
            "value": "1.1.1.1"
          }
        ],
        "virtualNetworkRules": [
          {
            "action": "Allow",
            "id": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/adp-<<namePrefix>>-az-vnet-x-001/subnets/<<namePrefix>>-az-subnet-x-001"
          }
        ]
      }
    },
    "privateEndpoints": {
      "value": [
        {
          "privateDnsZoneGroups": {
            "privateDNSResourceIds": [
              "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/privateDnsZones/privatelink.blob.core.windows.net"
            ]
          },
          "service": "blob",
          "subnetResourceId": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/adp-<<namePrefix>>-az-vnet-x-001/subnets/<<namePrefix>>-az-subnet-x-005-privateEndpoints"
        },
        {
          "privateDnsZoneGroups": {
            "privateDNSResourceIds": [
              "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/privateDnsZones/privatelink.table.core.windows.net"
            ]
          },
          "service": "table",
          "subnetResourceId": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/adp-<<namePrefix>>-az-vnet-x-001/subnets/<<namePrefix>>-az-subnet-x-005-privateEndpoints"
        },
        {
          "privateDnsZoneGroups": {
            "privateDNSResourceIds": [
              "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/privateDnsZones/privatelink.queue.core.windows.net"
            ]
          },
          "service": "queue",
          "subnetResourceId": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/adp-<<namePrefix>>-az-vnet-x-001/subnets/<<namePrefix>>-az-subnet-x-005-privateEndpoints"
        },
        {
          "privateDnsZoneGroups": {
            "privateDNSResourceIds": [
              "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/privateDnsZones/privatelink.file.core.windows.net"
            ]
          },
          "service": "file",
          "subnetResourceId": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/adp-<<namePrefix>>-az-vnet-x-001/subnets/<<namePrefix>>-az-subnet-x-005-privateEndpoints"
        }
      ]
    },
    "queueServices": {
      "value": {
        "diagnosticEventHubAuthorizationRuleId": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.EventHub/namespaces/adp-<<namePrefix>>-az-evhns-x-001/AuthorizationRules/RootManageSharedAccessKey",
        "diagnosticEventHubName": "adp-<<namePrefix>>-az-evh-x-001",
        "diagnosticLogsRetentionInDays": 7,
        "diagnosticStorageAccountId": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Storage/storageAccounts/adp<<namePrefix>>azsax001",
        "diagnosticWorkspaceId": "/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/microsoft.operationalinsights/workspaces/adp-<<namePrefix>>-az-law-x-001",
        "queues": [
          {
            "metadata": {},
            "name": "queue1",
            "roleAssignments": [
              {
                "principalIds": [
                  "<<deploymentSpId>>"
                ],
                "roleDefinitionIdOrName": "Reader"
              }
            ]
          },
          {
            "metadata": {},
            "name": "queue2"
          }
        ]
      }
    },
    "requireInfrastructureEncryption": {
      "value": true
    },
    "roleAssignments": {
      "value": [
        {
          "principalIds": [
            "<<deploymentSpId>>"
          ],
          "roleDefinitionIdOrName": "Reader"
        }
      ]
    },
    "storageAccountSku": {
      "value": "Standard_LRS"
    },
    "systemAssignedIdentity": {
      "value": true
    },
    "tableServices": {
      "value": {
        "diagnosticEventHubAuthorizationRuleId": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.EventHub/namespaces/adp-<<namePrefix>>-az-evhns-x-001/AuthorizationRules/RootManageSharedAccessKey",
        "diagnosticEventHubName": "adp-<<namePrefix>>-az-evh-x-001",
        "diagnosticLogsRetentionInDays": 7,
        "diagnosticStorageAccountId": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Storage/storageAccounts/adp<<namePrefix>>azsax001",
        "diagnosticWorkspaceId": "/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/microsoft.operationalinsights/workspaces/adp-<<namePrefix>>-az-law-x-001",
        "tables": [
          "table1",
          "table2"
        ]
      }
    },
    "userAssignedIdentities": {
      "value": {
        "/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/Microsoft.ManagedIdentity/userAssignedIdentities/adp-<<namePrefix>>-az-msi-x-001": {}
      }
    }
  }
}
```

</details>
<p>

<h3>Example 5: V1</h3>

<details>

<summary>via Bicep module</summary>

```bicep
module storageAccounts './Microsoft.Storage/storageAccounts/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-storageAccounts'
  params: {
    allowBlobPublicAccess: false
    name: '<<namePrefix>>azsav1001'
    storageAccountKind: 'Storage'
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
    "allowBlobPublicAccess": {
      "value": false
    },
    "name": {
      "value": "<<namePrefix>>azsav1001"
    },
    "storageAccountKind": {
      "value": "Storage"
    }
  }
}
```

</details>
<p>
