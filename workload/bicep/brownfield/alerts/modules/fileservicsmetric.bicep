param AutoMitigate bool
param Enabled bool
param Location string
param StorageAccountResourceID string
param MetricAlertsFileShares array
param ActionGroupID string
param Tags object

var FileServicesResourceID = '${StorageAccountResourceID}/fileServices/default'

module metricAlerts_FileServices '../../../../../carml/1.3.0/Microsoft.Insights/metricAlerts/deploy.bicep' = [for i in range(0, length(MetricAlertsFileShares)): {
  name: 'carml_${MetricAlertsFileShares[i].name}-${split(FileServicesResourceID, '/')[8]}'
  params: {
    enableDefaultTelemetry: false
    name: '${MetricAlertsFileShares[i].name}-${split(FileServicesResourceID, '/')[8]}'
    criterias: MetricAlertsFileShares[i].criteria.allOf
    location: 'global'
    alertDescription: MetricAlertsFileShares[i].description
    severity:MetricAlertsFileShares[i].severity
    enabled: Enabled
    scopes: [FileServicesResourceID]  //Assuming first VM Resource ID has same RG for all
    evaluationFrequency: MetricAlertsFileShares[i].evaluationFrequency
    windowSize: MetricAlertsFileShares[i].windowSize
    autoMitigate: AutoMitigate
    tags: contains(Tags, 'Microsoft.Insights/metricAlerts') ? Tags['Microsoft.Insights/metricAlerts'] : {}
    targetResourceType: MetricAlertsFileShares[i].targetResourceType
    targetResourceRegion: Location
    actions: [
      {
        actionGroupId: ActionGroupID
      }
    ]

  }
}]
