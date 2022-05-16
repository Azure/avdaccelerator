@description('Required. The name of the event hub namespace')
param namespaceName string

@description('Required. The name of the event hub namespace event hub')
param eventHubName string

@description('Required. The name of the consumer group')
param name string

@description('Optional. User Metadata is a placeholder to store user-defined string data with maximum length 1024. e.g. it can be used to store descriptive data, such as list of teams and their contact information also user-defined configuration settings can be stored.')
param userMetadata string = ''

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

resource namespace 'Microsoft.EventHub/namespaces@2021-06-01-preview' existing = {
  name: namespaceName

  resource eventhub 'eventHubs@2021-06-01-preview' existing = {
    name: eventHubName
  }
}

resource consumerGroup 'Microsoft.EventHub/namespaces/eventhubs/consumergroups@2021-06-01-preview' = {
  name: name
  parent: namespace::eventhub
  properties: {
    userMetadata: !empty(userMetadata) ? userMetadata : null
  }
}

@description('The name of the consumer group.')
output name string = consumerGroup.name

@description('The resource ID of the consumer group.')
output resourceId string = consumerGroup.id

@description('The name of the resource group the consumer group was created in.')
output resourceGroupName string = resourceGroup().name
