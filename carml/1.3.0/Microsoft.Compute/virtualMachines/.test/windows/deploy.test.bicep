targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //
@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(80)
param resourceGroupName string = 'ms.compute.virtualMachines-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param location string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'cvmwincom'

@description('Optional. The password to leverage for the login.')
@secure()
param password string = newGuid()

@description('Optional. Enable telemetry via a Globally Unique Identifier (GUID).')
param enableDefaultTelemetry bool = true

// =========== //
// Deployments //
// =========== //

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: location
}

module resourceGroupResources 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location)}-nestedDependencies'
  params: {
    location: location
    virtualNetworkName: 'dep-<<namePrefix>>-vnet-${serviceShort}'
    applicationSecurityGroupName: 'dep-<<namePrefix>>-asg-${serviceShort}'
    managedIdentityName: 'dep-<<namePrefix>>-msi-${serviceShort}'
    keyVaultName: 'dep-<<namePrefix>>-kv-${serviceShort}'
    loadBalancerName: 'dep-<<namePrefix>>-lb-${serviceShort}'
    recoveryServicesVaultName: 'dep-<<namePrefix>>-rsv-${serviceShort}'
    storageAccountName: 'dep<<namePrefix>>sa${serviceShort}01'
    storageUploadDeploymentScriptName: 'dep-<<namePrefix>>-sads-${serviceShort}'
    proximityPlacementGroupName: 'dep-<<namePrefix>>-ppg-${serviceShort}'
  }
}

// Diagnostics
// ===========
module diagnosticDependencies '../../../../.shared/dependencyConstructs/diagnostic.dependencies.bicep' = {
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
  name: '${uniqueString(deployment().name)}-test-${serviceShort}'
  params: {
    enableDefaultTelemetry: enableDefaultTelemetry
    location: location
    name: '<<namePrefix>>${serviceShort}'
    adminUsername: 'localAdminUser'
    imageReference: {
      publisher: 'MicrosoftWindowsServer'
      offer: 'WindowsServer'
      sku: '2019-datacenter'
      version: 'latest'
    }
    nicConfigurations: [
      {
        deleteOption: 'Delete'
        ipConfigurations: [
          {
            applicationSecurityGroups: [
              {
                id: resourceGroupResources.outputs.applicationSecurityGroupResourceId
              }
            ]
            loadBalancerBackendAddressPools: [
              {
                id: resourceGroupResources.outputs.loadBalancerBackendPoolResourceId
              }
            ]
            name: 'ipconfig01'
            pipConfiguration: {
              publicIpNameSuffix: '-pip-01'
              roleAssignments: [
                {
                  roleDefinitionIdOrName: 'Reader'
                  principalIds: [
                    resourceGroupResources.outputs.managedIdentityPrincipalId
                  ]
                  principalType: 'ServicePrincipal'
                }
              ]
            }
            subnetResourceId: resourceGroupResources.outputs.subnetResourceId
          }
        ]
        nicSuffix: '-nic-01'
        roleAssignments: [
          {
            roleDefinitionIdOrName: 'Reader'
            principalIds: [
              resourceGroupResources.outputs.managedIdentityPrincipalId
            ]
            principalType: 'ServicePrincipal'
          }
        ]
      }
    ]
    osDisk: {
      caching: 'None'
      createOption: 'fromImage'
      deleteOption: 'Delete'
      diskSizeGB: '128'
      managedDisk: {
        storageAccountType: 'Premium_LRS'
      }
    }
    osType: 'Windows'
    vmSize: 'Standard_B12ms'
    adminPassword: password
    availabilityZone: 2
    backupPolicyName: resourceGroupResources.outputs.recoveryServicesVaultBackupPolicyName
    backupVaultName: resourceGroupResources.outputs.recoveryServicesVaultName
    backupVaultResourceGroup: resourceGroupResources.outputs.recoveryServicesVaultResourceGroupName
    dataDisks: [
      {
        caching: 'None'
        createOption: 'Empty'
        deleteOption: 'Delete'
        diskSizeGB: '128'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      {
        caching: 'None'
        createOption: 'Empty'
        deleteOption: 'Delete'
        diskSizeGB: '128'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
    ]
    enableAutomaticUpdates: true
    patchMode: 'AutomaticByPlatform'
    diagnosticStorageAccountId: diagnosticDependencies.outputs.storageAccountResourceId
    diagnosticWorkspaceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
    diagnosticEventHubAuthorizationRuleId: diagnosticDependencies.outputs.eventHubAuthorizationRuleId
    diagnosticEventHubName: diagnosticDependencies.outputs.eventHubNamespaceEventHubName
    diagnosticLogsRetentionInDays: 7
    encryptionAtHost: false
    extensionAntiMalwareConfig: {
      enabled: true
      settings: {
        AntimalwareEnabled: 'true'
        Exclusions: {
          Extensions: '.ext1;.ext2'
          Paths: 'c:\\excluded-path-1;c:\\excluded-path-2'
          Processes: 'excludedproc1.exe;excludedproc2.exe'
        }
        RealtimeProtectionEnabled: 'true'
        ScheduledScanSettings: {
          day: '7'
          isEnabled: 'true'
          scanType: 'Quick'
          time: '120'
        }
      }
    }
    extensionCustomScriptConfig: {
      enabled: true
      fileData: [
        {
          storageAccountId: resourceGroupResources.outputs.storageAccountResourceId
          uri: resourceGroupResources.outputs.storageAccountCSEFileUrl
        }
      ]
    }
    extensionCustomScriptProtectedSetting: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -Command "& ./${resourceGroupResources.outputs.storageAccountCSEFileName}"'
    }
    extensionDependencyAgentConfig: {
      enabled: true
    }
    extensionAzureDiskEncryptionConfig: {
      enabled: true
      settings: {
        EncryptionOperation: 'EnableEncryption'
        KekVaultResourceId: resourceGroupResources.outputs.keyVaultResourceId
        KeyEncryptionAlgorithm: 'RSA-OAEP'
        KeyEncryptionKeyURL: resourceGroupResources.outputs.keyVaultEncryptionKeyUrl
        KeyVaultResourceId: resourceGroupResources.outputs.keyVaultResourceId
        KeyVaultURL: resourceGroupResources.outputs.keyVaultUrl
        ResizeOSDisk: 'false'
        VolumeType: 'All'
      }
    }
    extensionDSCConfig: {
      enabled: true
    }
    extensionMonitoringAgentConfig: {
      enabled: true
    }
    extensionNetworkWatcherAgentConfig: {
      enabled: true
    }
    lock: 'CanNotDelete'
    monitoringWorkspaceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
    proximityPlacementGroupResourceId: resourceGroupResources.outputs.proximityPlacementGroupResourceId
    roleAssignments: [
      {
        roleDefinitionIdOrName: 'Reader'
        principalIds: [
          resourceGroupResources.outputs.managedIdentityPrincipalId
        ]
        principalType: 'ServicePrincipal'
      }
    ]
    systemAssignedIdentity: true
    userAssignedIdentities: {
      '${resourceGroupResources.outputs.managedIdentityResourceId}': {}
    }
  }
}
