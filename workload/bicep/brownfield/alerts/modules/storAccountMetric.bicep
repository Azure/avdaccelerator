param AutoMitigate bool
param Enabled bool
param Environment string
param Location string
param StorageAccountResourceID string
param MetricAlertsStorageAcct array
param ActionGroupID string
param Tags object

module metricAlerts_StorageAcct '../../../../../carml/1.3.0/Microsoft.Insights/metricAlerts/deploy.bicep' = [for i in range(0, length(MetricAlertsStorageAcct)):  {
  name: 'c_${MetricAlertsStorageAcct[i].name}-${split(StorageAccountResourceID, '/')[8]}-${Environment}'
  params: {
    enableDefaultTelemetry: false
    name: '${MetricAlertsStorageAcct[i].displayName}-${split(StorageAccountResourceID, '/')[8]}-${Environment}'
    criterias: MetricAlertsStorageAcct[i].criteria.allOf
    location: 'global'
    alertDescription: MetricAlertsStorageAcct[i].description
    severity: MetricAlertsStorageAcct[i].severity
    enabled: Enabled
    scopes: [StorageAccountResourceID]  //Assuming first VM Resource ID has same RG for all
    evaluationFrequency: MetricAlertsStorageAcct[i].evaluationFrequency
    windowSize: MetricAlertsStorageAcct[i].windowSize
    autoMitigate: AutoMitigate
    tags: contains(Tags, 'Microsoft.Insights/metricAlerts') ? Tags['Microsoft.Insights/metricAlerts'] : {}
    targetResourceType: MetricAlertsStorageAcct[i].targetResourceType
    targetResourceRegion: Location
    actions: [
      {
        actionGroupId: ActionGroupID
      }
    ]

  }
}]


