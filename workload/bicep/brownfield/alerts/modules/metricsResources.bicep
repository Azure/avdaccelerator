param ActionGroupName string
param ANFVolumeResourceIds array
param DistributionGroup string
param HostPoolInfo string
param HostPools array
param Location string
param LogAnalyticsWorkspaceResourceId string
param LogAlertsStorage array
param LogAlertsHostPool array
param LogAlertsSvcHealth array
param MetricAlerts object
param StorageAccountResourceIds array
param Tags object

var SubscriptionId = subscription().subscriptionId
var CloudEnvironment = environment().name

module actionGroup '../../../../../carml/1.3.0/Microsoft.Insights/actionGroups/deploy.bicep' = {
  name: ActionGroupName
  params: {
    emailReceivers: [
      {
        emailAddress: DistributionGroup
        name: 'AVD Operations Admin(s)'
        useCommonAlertSchema: true
      }
    ]
    enabled: true
    location: 'global'
    enableDefaultTelemetry: false
    name: ActionGroupName
    groupShortName: 'AVDMetrics'
    tags: contains(Tags, 'Microsoft.Insights/actionGroups') ? Tags['Microsoft.Insights/actionGroups'] : {}
  }
}

module metricAlertsVMs 'metricAlertsVMs.bicep' = [for i in range(0, length(HostPools)): {
  name: 'linked_VMMtrcAlrts_${guid(HostPools[i])}'
  params: {
    HostPoolInfo: json(HostPoolInfo)[i]
    MetricAlerts: MetricAlerts
    Enabled: false
    AutoMitigate: false
    Location: Location
    ActionGroupId: actionGroup.outputs.resourceId
    Tags: Tags
  }
}]

module storAccountMetric 'storAccountMetric.bicep' = [for i in range(0, length(StorageAccountResourceIds)): if (length(StorageAccountResourceIds) > 0) {
  name: 'linked_StrAcctMtrcAlrts_${split(StorageAccountResourceIds[i], '/')[8]}'
  params: {
    AutoMitigate: false
    Enabled: false
    Location: Location
    StorageAccountResourceID: StorageAccountResourceIds[i]
    MetricAlertsStorageAcct: MetricAlerts.storageAccounts
    ActionGroupID: actionGroup.outputs.resourceId
    Tags: Tags
  }
}]

module azureNetAppFilesMetric 'anfMetric.bicep' = [for i in range(0, length(ANFVolumeResourceIds)): if (length(ANFVolumeResourceIds) > 0) {
  name: 'linked_ANFMtrcAlrts_${split(ANFVolumeResourceIds[i], '/')[12]}'
  params: {
    AutoMitigate: false
    Enabled: false
    Location: Location
    ANFVolumeResourceID: ANFVolumeResourceIds[i]
    MetricAlertsANF: MetricAlerts.anf
    ActionGroupID: actionGroup.outputs.resourceId
    Tags: Tags
  }
}]

// If Metric Namespace contains file services ; change scopes to append default
// module to loop through each scope time as it MUST be a single Resource ID
module fileServicesMetric 'fileservicsmetric.bicep' = [for i in range(0, length(StorageAccountResourceIds)): if (length(StorageAccountResourceIds) > 0) {
  name: 'linked_FlSvcsMtrcAlrts_${i}'
  params: {
    AutoMitigate: false
    Enabled: false
    Location: Location
    StorageAccountResourceID: StorageAccountResourceIds[i]
    MetricAlertsFileShares: MetricAlerts.fileShares
    ActionGroupID: actionGroup.outputs.resourceId
    Tags: Tags
  }
}]

module logAlertStorage '../../../../../carml/1.3.0/Microsoft.Insights/scheduledQueryRules/deploy.bicep' = [for i in range(0, length(LogAlertsStorage)): {
  name: 'carml_${LogAlertsStorage[i].name}'
  params: {
    enableDefaultTelemetry: false
    name: LogAlertsStorage[i].name
    autoMitigate: false
    criterias: LogAlertsStorage[i].criteria
    scopes: [ LogAnalyticsWorkspaceResourceId ]
    location: Location
    actions: [ actionGroup.outputs.resourceId ]
    alertDescription: LogAlertsStorage[i].description
    enabled: false
    evaluationFrequency: LogAlertsStorage[i].evaluationFrequency
    severity: LogAlertsStorage[i].severity
    tags: contains(Tags, 'Microsoft.Insights/scheduledQueryRules') ? Tags['Microsoft.Insights/scheduledQueryRules'] : {}
    windowSize: LogAlertsStorage[i].windowSize
  }
}]

module logAlertHostPoolQueries 'hostPoolAlerts.bicep' = [for hostpool in HostPools: {
  name: 'linked_HPAlrts-${guid(split(hostpool, '/')[4],split(hostpool, '/')[8])}'
  params: {
    AutoMitigate: false
    ActionGroupId: actionGroup.outputs.resourceId
    HostPoolName: split(hostpool, '/')[8]
    Location: Location
    LogAlertsHostPool: LogAlertsHostPool
    LogAnalyticsWorkspaceResourceId: LogAnalyticsWorkspaceResourceId
    Tags: {}
  }
}]

// Currently only deploys IF Cloud Environment is Azure Commercial Cloud
module logAlertSvcHealth '../../../../../carml/1.3.0/Microsoft.Insights/activityLogAlerts/deploy.bicep' = [for i in range(0, length(LogAlertsSvcHealth)): if (CloudEnvironment == 'AzureCloud') {
  name: 'carml_${LogAlertsSvcHealth[i].name}'
  params: {
    enableDefaultTelemetry: false
    name: LogAlertsSvcHealth[i].name
    enabled: false
    location: 'global'
    tags: contains(Tags, 'Microsoft.Insights/activityLogAlerts') ? Tags['Microsoft.Insights/activityLogAlerts'] : {}
    scopes: [
      '/subscriptions/${SubscriptionId}'
    ]
    conditions: [
      {
        field: 'category'
        equals: 'ServiceHealth'
      }
      {
        anyOf: LogAlertsSvcHealth[i].anyof
      }
      {
        field: 'properties.impactedServices[*].ServiceName'
        containsAny: [
          'Windows Virtual Desktop'
        ]
      }
      {
        field: 'properties.impactedServices[*].ImpactedRegions[*].RegionName'
        containsAny: [
          Location
        ]
      }
    ]
    actions: [ actionGroup.outputs.resourceId ]
    alertDescription: LogAlertsSvcHealth[i].description
  }
}]
