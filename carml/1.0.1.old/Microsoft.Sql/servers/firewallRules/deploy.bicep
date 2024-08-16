@description('Required. The name of the Server Firewall Rule.')
param name string

@description('Optional. The end IP address of the firewall rule. Must be IPv4 format. Must be greater than or equal to startIpAddress. Use value \'0.0.0.0\' for all Azure-internal IP addresses.')
param endIpAddress string = '0.0.0.0'

@description('Optional. The start IP address of the firewall rule. Must be IPv4 format. Use value \'0.0.0.0\' for all Azure-internal IP addresses.')
param startIpAddress string = '0.0.0.0'

@description('Required. The Name of SQL Server')
param serverName string

@description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
param enableDefaultTelemetry bool = true

resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

resource server 'Microsoft.Sql/servers@2021-05-01-preview' existing = {
  name: serverName
}

resource firewallRule 'Microsoft.Sql/servers/firewallRules@2021-05-01-preview' = {
  name: name
  parent: server
  properties: {
    endIpAddress: endIpAddress
    startIpAddress: startIpAddress
  }
}

@description('The name of the deployed firewall rule')
output name string = firewallRule.name

@description('The resource ID of the deployed firewall rule')
output resourceId string = firewallRule.id

@description('The resourceGroup of the deployed firewall rule')
output resourceGroupName string = resourceGroup().name
