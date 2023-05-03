param AutoMitigate bool
param ActionGroupId string
param HostPoolName string
param LogAlertsHostPool array
param LogAnalyticsWorkspaceResourceId string
param Location string
param Tags object
param Timestamp string = utcNow()

module logAlertHostPoolQueries '../../../../../carml/1.3.0/Microsoft.Insights/scheduledQueryRules/deploy.bicep' = [for i in range(0, length(LogAlertsHostPool)): {
  name: 'carml_${guid(replace(LogAlertsHostPool[i].name, 'xHostPoolNamex', HostPoolName),Timestamp)}'
  params: {
    enableDefaultTelemetry: false
    name: replace(LogAlertsHostPool[i].name, 'xHostPoolNamex', HostPoolName)
    autoMitigate: AutoMitigate
    criterias: {
      allOf: [
        {
          query: replace(LogAlertsHostPool[i].criteria.allOf[0].query, 'xHostPoolNamex', HostPoolName)
          timeAggregation: LogAlertsHostPool[i].criteria.allOf[0].timeAggregation
          dimensions: LogAlertsHostPool[i].criteria.allOf[0].dimensions
          operator: LogAlertsHostPool[i].criteria.allOf[0].operator
          threshold: LogAlertsHostPool[i].criteria.allOf[0].threshold
          failingPeriods: LogAlertsHostPool[i].criteria.allOf[0].failingPeriods
        }]
    }
    scopes: [LogAnalyticsWorkspaceResourceId]
    location: Location
    actions: [ActionGroupId]
    alertDescription: replace(LogAlertsHostPool[i].description, 'xHostPoolNamex', HostPoolName)
    enabled: false
    evaluationFrequency: LogAlertsHostPool[i].evaluationFrequency
    severity: LogAlertsHostPool[i].severity
    tags: contains(Tags, 'Microsoft.Insights/scheduledQueryRules') ? Tags['Microsoft.Insights/scheduledQueryRules'] : {}
    windowSize: LogAlertsHostPool[i].windowSize
  }
}]
