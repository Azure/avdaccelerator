param AutoMitigate bool
param Enabled bool
param Location string
param MetricAlertsANF array
param ANFVolumeResourceID string
param ActionGroupID string
param Tags object

module metricAlerts_VirtualMachines '../../../../../carml/1.3.0/Microsoft.Insights/metricAlerts/deploy.bicep' = [for i in range(0, length(MetricAlertsANF)): {
  name: 'carml_${MetricAlertsANF[i].name}-${split(ANFVolumeResourceID, '/')[12]}'
  params: {
    enableDefaultTelemetry: false
    name: '${MetricAlertsANF[i].name}-${split(ANFVolumeResourceID, '/')[12]}'
    criterias: MetricAlertsANF[i].criteria.allOf
    location: 'global'
    alertDescription: MetricAlertsANF[i].description
    severity: MetricAlertsANF[i].severity
    enabled: Enabled
    scopes: [ANFVolumeResourceID]
    evaluationFrequency: MetricAlertsANF[i].evaluationFrequency
    windowSize: MetricAlertsANF[i].windowSize
    autoMitigate: AutoMitigate
    tags: contains(Tags, 'Microsoft.Insights/metricAlerts') ? Tags['Microsoft.Insights/metricAlerts'] : {}
    targetResourceType: MetricAlertsANF[i].targetResourceType
    targetResourceRegion: Location
    actions: [
      {
        actionGroupId: ActionGroupID
      }
    ]
  }
}]
