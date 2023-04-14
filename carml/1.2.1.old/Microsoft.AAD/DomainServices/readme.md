# Azure Active Directory Domain Services `[Microsoft.AAD/DomainServices]`

This template deploys Azure Active Directory Domain Services (AADDS).

## Navigation

- [Resource types](#Resource-types)
- [Parameters](#Parameters)
- [Considerations](#Considerations)
- [Outputs](#Outputs)
- [Cross-referenced modules](#Cross-referenced-modules)
- [Deployment examples](#Deployment-examples)

## Resource types

| Resource Type | API Version |
| :-- | :-- |
| `Microsoft.AAD/domainServices` | [2021-05-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.AAD/2021-05-01/domainServices) |
| `Microsoft.Authorization/locks` | [2017-04-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2017-04-01/locks) |
| `Microsoft.Authorization/roleAssignments` | [2022-04-01](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Authorization/2022-04-01/roleAssignments) |
| `Microsoft.Insights/diagnosticSettings` | [2021-05-01-preview](https://docs.microsoft.com/en-us/azure/templates/Microsoft.Insights/2021-05-01-preview/diagnosticSettings) |

## Parameters

**Required parameters**
| Parameter Name | Type | Description |
| :-- | :-- | :-- |
| `domainName` | string | The domain name specific to the Azure ADDS service. |

**Conditional parameters**
| Parameter Name | Type | Default Value | Description |
| :-- | :-- | :-- | :-- |
| `pfxCertificate` | string | `''` | The certificate required to configure Secure LDAP. Should be a base64encoded representation of the certificate PFX file. Required if secure LDAP is enabled and must be valid more than 30 days. |
| `pfxCertificatePassword` | secureString | `''` | The password to decrypt the provided Secure LDAP certificate PFX file. Required if secure LDAP is enabled. |

**Optional parameters**
| Parameter Name | Type | Default Value | Allowed Values | Description |
| :-- | :-- | :-- | :-- | :-- |
| `additionalRecipients` | array | `[]` |  | The email recipient value to receive alerts. |
| `diagnosticEventHubAuthorizationRuleId` | string | `''` |  | Resource ID of the diagnostic event hub authorization rule for the Event Hubs namespace in which the event hub should be created or streamed to. |
| `diagnosticEventHubName` | string | `''` |  | Name of the diagnostic event hub within the namespace to which logs are streamed. Without this, an event hub is created for each log category. |
| `diagnosticLogsRetentionInDays` | int | `365` |  | Specifies the number of days that logs will be kept for; a value of 0 will retain data indefinitely. |
| `diagnosticStorageAccountId` | string | `''` |  | Resource ID of the diagnostic storage account. |
| `diagnosticWorkspaceId` | string | `''` |  | Resource ID of the diagnostic log analytics workspace. |
| `domainConfigurationType` | string | `'FullySynced'` | `[FullySynced, ResourceTrusting]` | The value is to provide domain configuration type. |
| `enableDefaultTelemetry` | bool | `True` |  | Enable telemetry via the Customer Usage Attribution ID (GUID). |
| `externalAccess` | string | `'Enabled'` | `[Disabled, Enabled]` | The value is to enable the Secure LDAP for external services of Azure ADDS Services. |
| `filteredSync` | string | `'Enabled'` |  | The value is to synchronize scoped users and groups. |
| `kerberosArmoring` | string | `'Enabled'` | `[Disabled, Enabled]` | The value is to enable to provide a protected channel between the Kerberos client and the KDC. |
| `kerberosRc4Encryption` | string | `'Enabled'` | `[Disabled, Enabled]` | The value is to enable Kerberos requests that use RC4 encryption. |
| `ldaps` | string | `'Enabled'` | `[Disabled, Enabled]` | A flag to determine whether or not Secure LDAP is enabled or disabled. |
| `location` | string | `[resourceGroup().location]` |  | The location to deploy the Azure ADDS Services. |
| `lock` | string | `''` | `['', CanNotDelete, ReadOnly]` | Specify the type of lock. |
| `logsToEnable` | array | `[AccountLogon, AccountManagement, DetailTracking, DirectoryServiceAccess, LogonLogoff, ObjectAccess, PolicyChange, PrivilegeUse, SystemSecurity]` | `[AccountLogon, AccountManagement, DetailTracking, DirectoryServiceAccess, LogonLogoff, ObjectAccess, PolicyChange, PrivilegeUse, SystemSecurity]` | The name of logs that will be streamed. |
| `name` | string | `[parameters('domainName')]` |  | The name of the AADDS resource. Defaults to the domain name specific to the Azure ADDS service. |
| `notifyDcAdmins` | string | `'Enabled'` | `[Disabled, Enabled]` | The value is to notify the DC Admins. |
| `notifyGlobalAdmins` | string | `'Enabled'` | `[Disabled, Enabled]` | The value is to notify the Global Admins. |
| `ntlmV1` | string | `'Enabled'` | `[Disabled, Enabled]` | The value is to enable clients making request using NTLM v1. |
| `replicaSets` | array | `[]` |  | Additional replica set for the managed domain. |
| `roleAssignments` | array | `[]` |  | Array of role assignment objects that contain the 'roleDefinitionIdOrName' and 'principalId' to define RBAC role assignments on this resource. In the roleDefinitionIdOrName attribute, you can provide either the display name of the role definition, or its fully qualified ID in the following format: '/providers/Microsoft.Authorization/roleDefinitions/c2f4ef07-c644-48eb-af81-4b1b4947fb11'. |
| `sku` | string | `'Standard'` | `[Enterprise, Premium, Standard]` | The name of the SKU specific to Azure ADDS Services. |
| `syncNtlmPasswords` | string | `'Enabled'` | `[Disabled, Enabled]` | The value is to enable synchronized users to use NTLM authentication. |
| `syncOnPremPasswords` | string | `'Enabled'` | `[Disabled, Enabled]` | The value is to enable on-premises users to authenticate against managed domain. |
| `tags` | object | `{object}` |  | Tags of the resource. |
| `tlsV1` | string | `'Enabled'` | `[Disabled, Enabled]` | The value is to enable clients making request using TLSv1. |


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

## Considerations

- A network security group has to be created and assigned to the designated AADDS subnet before deploying this module
  - The following inbound rules should be allowed on the network security group
    | Name | Protocol | Source Port Range | Source Address Prefix | Destination Port Range | Destination Address Prefix |
    | - | - | - | - | - | - |
    | AllowSyncWithAzureAD | TCP | `*` | `AzureActiveDirectoryDomainServices` | `443` | `*` |
    | AllowPSRemoting | TCP | `*` | `AzureActiveDirectoryDomainServices` | `5986` | `*` |
- Associating a route table to the AADDS subnet is not recommended
- The network used for AADDS must have its DNS Servers [configured](https://docs.microsoft.com/en-us/azure/active-directory-domain-services/tutorial-configure-networking#configure-dns-servers-in-the-peered-virtual-network) (e.g. with IPs `10.0.1.4` & `10.0.1.5`)
- Your Azure Active Directory must have the 'Domain Controller Services' service principal registered. If that's not  the case, you can register it by executing the command `New-AzADServicePrincipal -ApplicationId '2565bd9d-da50-47d4-8b85-4c97f669dc36'` with an eligible user.

### Create self-signed certificate for secure LDAP
Follow the below PowerShell commands to get base64 encoded string of a self-signed certificate (with a `pfxCertificatePassword`)

```PowerShell
$pfxCertificatePassword = ConvertTo-SecureString '<<YourPfxCertificatePassword>>' -AsPlainText -Force
$certInputObject = @{
    Subject           = 'CN=*.<<YourDomainName>>'
    DnsName           = '*.<<YourDomainName>>'
    CertStoreLocation = 'cert:\LocalMachine\My'
    KeyExportPolicy   = 'Exportable'
    Provider          = 'Microsoft Enhanced RSA and AES Cryptographic Provider'
    NotAfter          = (Get-Date).AddMonths(3)
    HashAlgorithm     = 'SHA256'
}
$rawCert = New-SelfSignedCertificate @certInputObject
Export-PfxCertificate -Cert ('Cert:\localmachine\my\' + $rawCert.Thumbprint) -FilePath "$home/aadds.pfx" -Password $pfxCertificatePassword -Force
$rawCertByteStream = Get-Content "$home/aadds.pfx" -AsByteStream
$pfxCertificate = [System.Convert]::ToBase64String($rawCertByteStream)
```

## Outputs

| Output Name | Type | Description |
| :-- | :-- | :-- |
| `location` | string | The location the resource was deployed into. |
| `name` | string | The domain name of the Azure Active Directory Domain Services(Azure ADDS). |
| `resourceGroupName` | string | The name of the resource group the Azure Active Directory Domain Services(Azure ADDS) was created in. |
| `resourceId` | string | The resource ID of the Azure Active Directory Domain Services(Azure ADDS). |

## Cross-referenced modules

_None_

## Deployment examples

The following module usage examples are retrieved from the content of the files hosted in the module's `.test` folder.
   >**Note**: The name of each example is based on the name of the file from which it is taken.
   >**Note**: Each example lists all the required parameters first, followed by the rest - each in alphabetical order.

<h3>Example 1: Parameters</h3>

<details>

<summary>via Bicep module</summary>

```bicep
resource kv1 'Microsoft.KeyVault/vaults@2019-09-01' existing = {
  name: 'adp-<<namePrefix>>-az-kv-x-001'
  scope: resourceGroup('<<subscriptionId>>','validation-rg')
}

module DomainServices './Microsoft.AAD/DomainServices/deploy.bicep' = {
  name: '${uniqueString(deployment().name)}-DomainServices'
  params: {
    // Required parameters
    domainName: '<<namePrefix>>.onmicrosoft.com'
    // Non-required parameters
    additionalRecipients: [
      '<<namePrefix>>@noreply.github.com'
    ]
    diagnosticEventHubAuthorizationRuleId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.EventHub/namespaces/adp-<<namePrefix>>-az-evhns-x-001/AuthorizationRules/RootManageSharedAccessKey'
    diagnosticEventHubName: 'adp-<<namePrefix>>-az-evh-x-001'
    diagnosticStorageAccountId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Storage/storageAccounts/adp<<namePrefix>>azsax001'
    diagnosticWorkspaceId: '/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/microsoft.operationalinsights/workspaces/adp-<<namePrefix>>-az-law-x-001'
    lock: 'CanNotDelete'
    pfxCertificate: kv1.getSecret('pfxBase64Certificate')
    pfxCertificatePassword: kv1.getSecret('pfxCertificatePassword')
    replicaSets: [
      {
        location: 'WestEurope'
        subnetId: '/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/adp-<<namePrefix>>-az-vnet-aadds-001/subnets/AADDSSubnet'
      }
    ]
    sku: 'Standard'
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
    "domainName": {
      "value": "<<namePrefix>>.onmicrosoft.com"
    },
    // Non-required parameters
    "additionalRecipients": {
      "value": [
        "<<namePrefix>>@noreply.github.com"
      ]
    },
    "diagnosticEventHubAuthorizationRuleId": {
      "value": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.EventHub/namespaces/adp-<<namePrefix>>-az-evhns-x-001/AuthorizationRules/RootManageSharedAccessKey"
    },
    "diagnosticEventHubName": {
      "value": "adp-<<namePrefix>>-az-evh-x-001"
    },
    "diagnosticStorageAccountId": {
      "value": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Storage/storageAccounts/adp<<namePrefix>>azsax001"
    },
    "diagnosticWorkspaceId": {
      "value": "/subscriptions/<<subscriptionId>>/resourcegroups/validation-rg/providers/microsoft.operationalinsights/workspaces/adp-<<namePrefix>>-az-law-x-001"
    },
    "lock": {
      "value": "CanNotDelete"
    },
    "pfxCertificate": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.KeyVault/vaults/adp-<<namePrefix>>-az-kv-x-001"
        },
        "secretName": "pfxBase64Certificate"
      }
    },
    "pfxCertificatePassword": {
      "reference": {
        "keyVault": {
          "id": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.KeyVault/vaults/adp-<<namePrefix>>-az-kv-x-001"
        },
        "secretName": "pfxCertificatePassword"
      }
    },
    "replicaSets": {
      "value": [
        {
          "location": "WestEurope",
          "subnetId": "/subscriptions/<<subscriptionId>>/resourceGroups/validation-rg/providers/Microsoft.Network/virtualNetworks/adp-<<namePrefix>>-az-vnet-aadds-001/subnets/AADDSSubnet"
        }
      ]
    },
    "sku": {
      "value": "Standard"
    }
  }
}
```

</details>
<p>
