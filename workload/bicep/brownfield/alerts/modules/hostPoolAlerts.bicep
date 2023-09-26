param AutoMitigate bool
param ActionGroupId string
param Environment string
param HostPoolName string
param LogAlertsHostPool array
param LogAnalyticsWorkspaceResourceId string
param Location string
param Tags object
param Timestamp string = utcNow()

// Help ensure entire deployment name is under 64 characters
var HostPoolResourceName = length(HostPoolName) < 20 ? HostPoolName : skip(HostPoolName, length(HostPoolName)-20)

module logAlertHostPoolQueries '../../../../../carml/1.3.0/Microsoft.Insights/scheduledQueryRules/deploy.bicep' = [for i in range(0, length(LogAlertsHostPool)): {
  name: 'c_${replace(LogAlertsHostPool[i].name, 'xHostPoolNamex', HostPoolResourceName)}-${Environment}'
  params: {
    enableDefaultTelemetry: false
    name: '${replace(LogAlertsHostPool[i].name, 'xHostPoolNamex', HostPoolResourceName)}-${Environment}'
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
    alertDescription: '${replace(LogAlertsHostPool[i].description, 'xHostPoolNamex', HostPoolName)}-${Environment}'
    enabled: false
    evaluationFrequency: LogAlertsHostPool[i].evaluationFrequency
    severity: LogAlertsHostPool[i].severity
    tags: contains(Tags, 'Microsoft.Insights/scheduledQueryRules') ? Tags['Microsoft.Insights/scheduledQueryRules'] : {}
    windowSize: LogAlertsHostPool[i].windowSize
  }
}]

output HostPoolResourceName string = HostPoolResourceName
output HostPoolName string = HostPoolName
output HostPoolNameLength int = length(HostPoolName)
