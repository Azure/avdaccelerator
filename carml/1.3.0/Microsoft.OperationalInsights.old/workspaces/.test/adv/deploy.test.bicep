targetScope = 'subscription'

// ========== //
// Parameters //
// ========== //

@description('Optional. The name of the resource group to deploy for testing purposes.')
@maxLength(90)
param resourceGroupName string = 'ms.operationalinsights.workspaces-${serviceShort}-rg'

@description('Optional. The location to deploy resources to.')
param location string = deployment().location

@description('Optional. A short identifier for the kind of deployment. Should be kept short to not run into resource-name length-constraints.')
param serviceShort string = 'oiwadv'

@description('Optional. Enable telemetry via a Globally Unique Identifier (GUID).')
param enableDefaultTelemetry bool = true

// ============ //
// Dependencies //
// ============ //

// General resources
// =================
resource resourceGroup 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: resourceGroupName
  location: location
}

module nestedDependencies 'dependencies.bicep' = {
  scope: resourceGroup
  name: '${uniqueString(deployment().name, location)}-nestedDependencies'
  params: {
    storageAccountName: 'dep<<namePrefix>>sa${serviceShort}'
    automationAccountName: 'dep-<<namePrefix>>-auto-${serviceShort}'
    eventHubNamespaceName: 'dep-<<namePrefix>>-ehw-${serviceShort}'
    eventHubName: 'dep-<<namePrefix>>-eh-${serviceShort}'
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
    dailyQuotaGb: 10
    dataSources: [
      {
        eventLogName: 'Application'
        eventTypes: [
          {
            eventType: 'Error'
          }
          {
            eventType: 'Warning'
          }
          {
            eventType: 'Information'
          }
        ]
        kind: 'WindowsEvent'
        name: 'applicationEvent'
      }
      {
        counterName: '% Processor Time'
        instanceName: '*'
        intervalSeconds: 60
        kind: 'WindowsPerformanceCounter'
        name: 'windowsPerfCounter1'
        objectName: 'Processor'
      }
      {
        kind: 'IISLogs'
        name: 'sampleIISLog1'
        state: 'OnPremiseEnabled'
      }
      {
        kind: 'LinuxSyslog'
        name: 'sampleSyslog1'
        syslogName: 'kern'
        syslogSeverities: [
          {
            severity: 'emerg'
          }
          {
            severity: 'alert'
          }
          {
            severity: 'crit'
          }
          {
            severity: 'err'
          }
          {
            severity: 'warning'
          }
        ]
      }
      {
        kind: 'LinuxSyslogCollection'
        name: 'sampleSyslogCollection1'
        state: 'Enabled'
      }
      {
        instanceName: '*'
        intervalSeconds: 10
        kind: 'LinuxPerformanceObject'
        name: 'sampleLinuxPerf1'
        objectName: 'Logical Disk'
        syslogSeverities: [
          {
            counterName: '% Used Inodes'
          }
          {
            counterName: 'Free Megabytes'
          }
          {
            counterName: '% Used Space'
          }
          {
            counterName: 'Disk Transfers/sec'
          }
          {
            counterName: 'Disk Reads/sec'
          }
          {
            counterName: 'Disk Writes/sec'
          }
        ]
      }
      {
        kind: 'LinuxPerformanceCollection'
        name: 'sampleLinuxPerfCollection1'
        state: 'Enabled'
      }
    ]
    diagnosticLogsRetentionInDays: 7
    diagnosticStorageAccountId: diagnosticDependencies.outputs.storageAccountResourceId
    diagnosticWorkspaceId: diagnosticDependencies.outputs.logAnalyticsWorkspaceResourceId
    diagnosticEventHubAuthorizationRuleId: diagnosticDependencies.outputs.eventHubAuthorizationRuleId
    diagnosticEventHubName: diagnosticDependencies.outputs.eventHubNamespaceEventHubName
    gallerySolutions: [
      {
        name: 'AzureAutomation'
        product: 'OMSGallery'
        publisher: 'Microsoft'
      }
    ]
    linkedServices: [
      {
        name: 'Automation'
        resourceId: nestedDependencies.outputs.automationAccountResourceId
      }
    ]
    linkedStorageAccounts: [
      {
        name: 'Query'
        resourceId: nestedDependencies.outputs.storageAccountResourceId
      }
    ]
    lock: 'CanNotDelete'
    publicNetworkAccessForIngestion: 'Disabled'
    publicNetworkAccessForQuery: 'Disabled'
    savedSearches: [
      {
        category: 'VDC Saved Searches'
        displayName: 'VMSS Instance Count2'
        name: 'VMSSQueries'
        query: 'Event | where Source == ServiceFabricNodeBootstrapAgent | summarize AggregatedValue = count() by Computer'
      }
    ]
    storageInsightsConfigs: [
      {
        storageAccountResourceId: nestedDependencies.outputs.storageAccountResourceId
        tables: [
          'LinuxsyslogVer2v0'
          'WADETWEventTable'
          'WADServiceFabric*EventTable'
          'WADWindowsEventLogsTable'
        ]
      }
    ]
    useResourcePermissions: true
    tables: [
      {
        name: 'CustomTableBasic_CL'
        schema: {
          name: 'CustomTableBasic_CL'
          columns: [
            {
              name: 'TimeGenerated'
              type: 'DateTime'
            }
            {
              name: 'RawData'
              type: 'String'
            }
          ]
        }
        totalRetentionInDays: 90
        retentionInDays: 60
      }
      {
        name: 'CustomTableAdvanced_CL'
        schema: {
          name: 'CustomTableAdvanced_CL'
          columns: [
            {
              name: 'TimeGenerated'
              type: 'DateTime'
            }
            {
              name: 'EventTime'
              type: 'DateTime'
            }
            {
              name: 'EventLevel'
              type: 'String'
            }
            {
              name: 'EventCode'
              type: 'Int'
            }
            {
              name: 'Message'
              type: 'String'
            }
            {
              name: 'RawData'
              type: 'String'
            }
          ]
        }
      }
    ]
    dataExports: [
      {
        name: 'eventHubExport'
        enable: true
        destination: {
          resourceId: nestedDependencies.outputs.eventHubNamespaceResourceId
          metaData: {
            eventHubName: nestedDependencies.outputs.eventHubName
          }
        }
        tableNames: [
          'Alert'
          'InsightsMetrics'
        ]
      }
      {
        name: 'storageAccountExport'
        enable: true
        destination: {
          resourceId: nestedDependencies.outputs.storageAccountResourceId
        }
        tableNames: [
          'Operation'
        ]
      }
    ]
    userAssignedIdentities: {
      '${nestedDependencies.outputs.managedIdentityResourceId}': {}
    }
    tags: {
      Environment: 'Non-Prod'
      Role: 'DeploymentValidation'
    }
  }
}
