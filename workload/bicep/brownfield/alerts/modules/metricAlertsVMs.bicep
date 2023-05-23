param AutoMitigate bool
param ActionGroupId string
param Enabled bool
param HostPoolInfo object  // Should be single object from array of objects collected via Deployment Script
param MetricAlerts object
param Tags object
param Location string
param Timestamp string = utcNow()

module metricAlerts_VirtualMachines '../../../../../carml/1.3.0/Microsoft.Insights/metricAlerts/deploy.bicep' = [for i in range(0, length(MetricAlerts.virtualMachines)): if(HostPoolInfo.VMResourceGroup != null) {
  name: 'carml_${MetricAlerts.virtualMachines[i].name}_${Timestamp}'
  params: {
    enableDefaultTelemetry: false
    name: replace(MetricAlerts.virtualMachines[i].name, 'xHostPoolNamex', HostPoolInfo.HostPoolName)
    criterias: [MetricAlerts.virtualMachines[i].criteria.allOf]
    location: 'global'
    alertDescription: MetricAlerts.virtualMachines[i].description
    severity: MetricAlerts.virtualMachines[i].severity
    enabled: Enabled
    scopes: [HostPoolInfo.VMResourceGroup]  //Assuming first VM Resource ID has same RG for all
    evaluationFrequency: MetricAlerts.virtualMachines[i].evaluationFrequency
    windowSize: MetricAlerts.virtualMachines[i].windowSize
    autoMitigate: AutoMitigate
    tags: contains(Tags, 'Microsoft.Insights/metricAlerts') ? Tags['Microsoft.Insights/metricAlerts'] : {}
    targetResourceType: MetricAlerts.virtualMachines[i].targetResourceType
    targetResourceRegion: Location
    actions: [
      {
        actionGroupId: ActionGroupId
        webHookProperties: {}
      }
    ]

  }
}]
