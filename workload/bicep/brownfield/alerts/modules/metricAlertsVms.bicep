param AutoMitigate bool
param ActionGroupId string
param Enabled bool
param Environment string
param HostPoolName string
param MetricAlerts object
param Tags object
param Location string
param VMResourceGroupId string

// Help ensure entire deployment name is under 64 characters
var HostPoolResourceName = length(HostPoolName) < 20 ? HostPoolName : skip(HostPoolName, length(HostPoolName)-20)

module metricAlerts_VirtualMachines '../../../../../carml/1.3.0/Microsoft.Insights/metricAlerts/deploy.bicep' = [for i in range(0, length(MetricAlerts.virtualMachines)): {
  name: 'c_${replace(MetricAlerts.virtualMachines[i].name, 'xHostPoolNamex', HostPoolResourceName)}-${Environment}'
  params: {
    enableDefaultTelemetry: false
    name: '${replace(MetricAlerts.virtualMachines[i].displayName, 'xHostPoolNamex', HostPoolResourceName)}-${Environment}'
    criterias: MetricAlerts.virtualMachines[i].criteria.allOf
    location: 'global'
    alertDescription: replace(MetricAlerts.virtualMachines[i].description, 'xHostPoolNamex', HostPoolName)
    severity: MetricAlerts.virtualMachines[i].severity
    enabled: Enabled
    scopes: [VMResourceGroupId]
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
