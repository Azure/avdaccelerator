targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'ms.keyvault.vaults-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param location string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'kvvcom'

@description('Optional. Enable telemetry via a Globally Unique Identifier (GUID).')
param enableDefaultTelemetry bool = true

// ============ //
// Dependencies //
// ============ //

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location)}-nestedDependencies'
  params: {
    virtualNetworkName: 'dep-<<namePrefix>>-vnet-${serviceShort}'
    managedIdentityName: 'dep-<<namePrefix>>-msi-${serviceShort}'
  }
}

// Diagnostics
// ===========
module diagnosticDependencies '../../../../.shared/.templates/diagnostic.dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location)}-diagnosticDependencies'
  params: {
    storageAccountName: 'dep<<namePrefix>>diasa${serviceShort}03'
    logAnalyticsWorkspaceName: 'dep-<<namePrefix>>-law-${serviceShort}'
    eventHubNamespaceEventHubName: 'dep-<<namePrefix>>-evh-${serviceShort}01'
    eventHubNamespaceName: 'dep-<<namePrefix>>-evhns-${serviceShort}01'
    location: location
  }
}

// ============== //
// Test Execution //
// ============== //

module testDeployment '../../deploy.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location)}-test-${serviceShort}'
  params: {
    enableDefaultTelemetry: enableDefaultTelemetry
    name: '<<namePrefix>>${serviceShort}002'
    accessPolicies: [
      {
        objectId: nestedDependencies.outputs.managedIdentityPrincipalId
        permissions: {
          keys: [
            'get'
            'list'
            'update'
          ]
          secrets: [
            'all'
          ]
        }
        tenantId: tenant().tenantId
      }
      {
        objectId: nestedDependencies.outputs.managedIdentityPrincipalId
        permissions: {
          certificates: [
            'backup'
            'create'
            'delete'
          ]
          secrets: [
            'all'
          ]
        }
      }
    ]
    diagnosticLogsRetentionInDays: 7
    diagnosticStorageAccountId: diagnosticDependencies.outputs.storageAccountResourceId
    diagnosticWorkspaceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
    diagnosticEventHubAuthorizationRuleId: diagnosticDependencies.outputs.eventHubAuthorizationRuleId
    diagnosticEventHubName: diagnosticDependencies.outputs.eventHubNamespaceEventHubName
    // Only for testing purposes
    enablePurgeProtection: false
    enableRbacAuthorization: false
    keys: [
      {
        attributesExp: 1725109032
        attributesNbf: 10000
        name: 'keyName'
        roleAssignments: [
          {
            roleDefinitionIdOrName: 'Reader'
            principalIds: [
              nestedDependencies.outputs.managedIdentityPrincipalId
            ]
            principalType: 'ServicePrincipal'
          }
        ]
        rotationPolicy: {
          attributes: {
            expiryTime: 'P2Y'
          }
          lifetimeActions: [
            {
              trigger: {
                timeBeforeExpiry: 'P2M'
              }
              action: {
                type: 'Rotate'
              }
            }
            {
              trigger: {
                timeBeforeExpiry: 'P30D'
              }
              action: {
                type: 'Notify'
              }
            }
          ]
        }
      }
    ]
    lock: 'CanNotDelete'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: [
        {
          value: '40.74.28.0/23'
        }
      ]
      virtualNetworkRules: [
        {
          id: nestedDependencies.outputs.subnetResourceId
          ignoreMissingVnetServiceEndpoint: false
        }
      ]
    }
    privateEndpoints: [
      {
        privateDnsZoneGroup: {
          privateDNSResourceIds: [
            nestedDependencies.outputs.privateDNSResourceId
          ]
        }
        service: 'vault'
        subnetResourceId: nestedDependencies.outputs.subnetResourceId
        tags: {
          Environment: 'Non-Prod'
          Role: 'DeploymentValidation'
        }
      }
    ]
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Reader'
        principalIds: [
          nestedDependencies.outputs.managedIdentityPrincipalId
        ]
        principalType: 'ServicePrincipal'
      }
    ]
    secrets: {
      secureList: [
        {
          attributesExp: 1702648632
          attributesNbf: 10000
          contentType: 'Something'
          name: 'secretName'
          roleAssignments: [
            {
              roleDefinitionIdOrName: 'Reader'
              principalIds: [
                nestedDependencies.outputs.managedIdentityPrincipalId
              ]
              principalType: 'ServicePrincipal'
            }
          ]
          value: 'secretValue'
        }
      ]
    }
    softDeleteRetentionInDays: 7
    tags: {
      Environment: 'Non-Prod'
      Role: 'DeploymentValidation'
    }
  }
}
