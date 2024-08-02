targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'ms.desktopvirtualization.hostpools-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param location string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'dvhpcom'

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
    managedIdentityName: 'dep-<<namePrefix>>-msi-${serviceShort}'
  }
}

// Diagnostics
// ===========
module diagnosticDependencies '../../../../.shared/.templates/diagnostic.dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location)}-diagnosticDependencies'
  params: {
    storageAccountName: 'dep<<namePrefix>>diasa${serviceShort}01'
    logAnalyticsWorkspaceName: 'dep-<<namePrefix>>-law-${serviceShort}'
    eventHubNamespaceEventHubName: 'dep-<<namePrefix>>-evh-${serviceShort}'
    eventHubNamespaceName: 'dep-<<namePrefix>>-evhns-${serviceShort}'
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
    name: '<<namePrefix>>${serviceShort}001'
    customRdpProperty: 'audiocapturemode:i:1;audiomode:i:0;drivestoredirect:s:;redirectclipboard:i:1;redirectcomports:i:1;redirectprinters:i:1;redirectsmartcards:i:1;screen mode id:i:2;'
    diagnosticLogsRetentionInDays: 7
    diagnosticStorageAccountId: diagnosticDependencies.outputs.storageAccountResourceId
    diagnosticWorkspaceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
    diagnosticEventHubAuthorizationRuleId: diagnosticDependencies.outputs.eventHubAuthorizationRuleId
    diagnosticEventHubName: diagnosticDependencies.outputs.eventHubNamespaceEventHubName
    description: 'My first AVD Host Pool'
    friendlyName: 'AVDv2'
    type: 'Pooled'
    loadBalancerType: 'BreadthFirst'
    location: location
    lock: 'CanNotDelete'
    maxSessionLimit: 99999
    personalDesktopAssignmentType: 'Automatic'
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Reader'
        principalIds: [
          nestedDependencies.outputs.managedIdentityPrincipalId
        ]
        principalType: 'ServicePrincipal'
      }
    ]
    vmTemplate: {
      customImageId: null
      domain: 'domainname.onmicrosoft.com'
      galleryImageOffer: 'office-365'
      galleryImagePublisher: 'microsoftwindowsdesktop'
      galleryImageSKU: '20h1-evd-o365pp'
      imageType: 'Gallery'
      imageUri: null
      namePrefix: 'avdv2'
      osDiskType: 'StandardSSD_LRS'
      useManagedDisks: true
      vmSize: {
        cores: 2
        id: 'Standard_D2s_v3'
        ram: 8
      }
    }
    tags: {
      Environment: 'Non-Prod'
      Role: 'DeploymentValidation'
    }
    agentUpdate: {
      type: 'Scheduled'
      useSessionHostLocalTime: false
      maintenanceWindowTimeZone: 'Alaskan Standard Time'
      maintenanceWindows: [
        {
          hour: 7
          dayOfWeek: 'Friday'
        }
        {
          hour: 8
          dayOfWeek: 'Saturday'
        }
      ]
    }
  }
}
