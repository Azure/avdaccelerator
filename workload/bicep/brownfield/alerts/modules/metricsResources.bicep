param ActionGroupName string
param AllResourcesSameRG bool
param AutoResolveAlert bool
param AVDResourceGroupId string
param ANFVolumeResourceIds array
param DistributionGroup string
param Environment string
param HostPoolInfo array
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
var SubscriptionName = replace(subscription().displayName, ' ', '')

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

// If VM and Host Pools mapped - loop through each object in Host Pool Info which will have a single HP per VM RG
module metricAlertsVms 'metricAlertsVms.bicep' = [for i in range(0, length(HostPoolInfo)): if(!AllResourcesSameRG) {
  name: !AllResourcesSameRG ? 'lnk_VMMtrcAlrts_m_${split(HostPoolInfo[i].colHostPoolName, '/')[8]}' : 'lnk_VMMtrcAlrts_m_NA'
  params: {
    HostPoolName: !AllResourcesSameRG ? split(HostPoolInfo[i].colHostPoolName, '/')[8] : 'none'
    Environment: Environment
    VMResourceGroupId: HostPoolInfo[i].colVMresGroup
    MetricAlerts: MetricAlerts
    Enabled: false
    AutoMitigate: AutoResolveAlert
    Location: Location
    ActionGroupId: actionGroup.outputs.resourceId
    Tags: Tags
  }
}]
// If all resources in same RG, loop through Host Pools
module metricAlertsVmsSingleRG 'metricAlertsVms.bicep' = [for i in range(0, length(HostPools)): if(AllResourcesSameRG) {
  name: 'lnk_VMMtrcAlrts_s_${split(HostPools[i], '/')[8]}'
  params: {
    Environment: Environment
    HostPoolName: split(HostPools[i], '/')[8]
    VMResourceGroupId: AVDResourceGroupId
    MetricAlerts: MetricAlerts
    Enabled: false
    AutoMitigate: AutoResolveAlert
    Location: Location
    ActionGroupId: actionGroup.outputs.resourceId
    Tags: Tags
  }
}]

module storAccountMetric 'storAccountMetric.bicep' = [for i in range(0, length(StorageAccountResourceIds)): if (length(StorageAccountResourceIds) > 0) {
  name: 'lnk_StrAcctMtrcAlrts_${split(StorageAccountResourceIds[i], '/')[8]}'
  params: {
    AutoMitigate: AutoResolveAlert
    Enabled: false
    Environment: Environment
    Location: Location
    StorageAccountResourceID: StorageAccountResourceIds[i]
    MetricAlertsStorageAcct: MetricAlerts.storageAccounts
    ActionGroupID: actionGroup.outputs.resourceId
    Tags: Tags
  }
}]

module azureNetAppFilesMetric 'anfMetric.bicep' = [for i in range(0, length(ANFVolumeResourceIds)): if (length(ANFVolumeResourceIds) > 0) {
  name: 'lnk_ANFMtrcAlrts_${split(ANFVolumeResourceIds[i], '/')[12]}'
  params: {
    AutoMitigate: AutoResolveAlert
    Enabled: false
    Environment: Environment
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
  name: 'lnk_FlSvcsMtrcAlrts_${i}'
  params: {
    AutoMitigate: AutoResolveAlert
    Enabled: false
    Environment: Environment
    Location: Location
    StorageAccountResourceID: StorageAccountResourceIds[i]
    MetricAlertsFileShares: MetricAlerts.fileShares
    ActionGroupID: actionGroup.outputs.resourceId
    Tags: Tags
  }
}]

module logAlertStorage '../../../../../carml/1.3.0/Microsoft.Insights/scheduledQueryRules/deploy.bicep' = [for i in range(0, length(LogAlertsStorage)): {
  name: 'c_${LogAlertsStorage[i].name}'
  params: {
    enableDefaultTelemetry: false
    name: LogAlertsStorage[i].name
    autoMitigate: AutoResolveAlert
    criterias: LogAlertsStorage[i].criteria
    scopes: [ LogAnalyticsWorkspaceResourceId ]
    location: Location
    actions: [ actionGroup.outputs.resourceId ]
    alertDisplayName: LogAlertsStorage[i].displayName
    alertDescription: LogAlertsStorage[i].description
    enabled: false
    evaluationFrequency: LogAlertsStorage[i].evaluationFrequency
    severity: LogAlertsStorage[i].severity
    tags: contains(Tags, 'Microsoft.Insights/scheduledQueryRules') ? Tags['Microsoft.Insights/scheduledQueryRules'] : {}
    windowSize: LogAlertsStorage[i].windowSize
  }
}]

module logAlertHostPoolQueriesMapped 'hostPoolAlerts.bicep' = [for hostpool in HostPoolInfo: if(!AllResourcesSameRG) {
  name: 'lnk_HPAlrts-${split(hostpool.colHostPoolName, '/')[8]}'
  params: {
    AutoMitigate: AutoResolveAlert
    ActionGroupId: actionGroup.outputs.resourceId
    Environment: Environment
    HostPoolName: split(hostpool.colHostPoolName, '/')[8]
    Location: Location
    LogAlertsHostPool: LogAlertsHostPool
    LogAnalyticsWorkspaceResourceId: LogAnalyticsWorkspaceResourceId
    Tags: {}
  }
}]

module logAlertHostPoolQueriesSingleRG 'hostPoolAlerts.bicep' = [for hostpool in HostPools: if(AllResourcesSameRG) {
  name: 'lnk_HPAlrts-${split(hostpool, '/')[8]}'
  params: {
    AutoMitigate: AutoResolveAlert
    ActionGroupId: actionGroup.outputs.resourceId
    Environment: Environment
    HostPoolName: split(hostpool, '/')[8]
    Location: Location
    LogAlertsHostPool: LogAlertsHostPool
    LogAnalyticsWorkspaceResourceId: LogAnalyticsWorkspaceResourceId
    Tags: {}
  }
}]

// Currently only deploys IF Cloud Environment is Azure Commercial Cloud
module logAlertSvcHealth '../../../../../carml/1.3.0/Microsoft.Insights/activityLogAlerts/deploy.bicep' = [for i in range(0, length(LogAlertsSvcHealth)): {
  name: 'c_${LogAlertsSvcHealth[i].name}'
  params: {
    enableDefaultTelemetry: false
    name: '${LogAlertsSvcHealth[i].displayName}-${SubscriptionName}'
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
