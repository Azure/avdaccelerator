@description('Required. Name of the Automation Account module.')
param name string

@description('Required. Name of the parent Automation Account.')
param automationAccountName string

@description('Required. Module package uri, e.g. https://www.powershellgallery.com/api/v2/package.')
param uri string

@description('Optional. Module version or specify latest to get the latest version.')
param version string = 'latest'

@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Optional. Tags of the Automation Account resource.')
param tags object = {}

@description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
param enableDefaultTelemetry bool = true

resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name, location)}'
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

resource automationAccount 'Microsoft.Automation/automationAccounts@2020-01-13-preview' existing = {
  name: automationAccountName
}

resource module 'Microsoft.Automation/automationAccounts/modules@2020-01-13-preview' = {
  name: name
  parent: automationAccount
  location: location
  tags: tags
  properties: {
    contentLink: {
      uri: version != 'latest' ? '${uri}/${name}/${version}' : '${uri}/${name}'
      version: version != 'latest' ? version : null
    }
  }
}

@description('The name of the deployed module')
output name string = module.name

@description('The resource ID of the deployed module')
output resourceId string = module.id

@description('The resource group of the deployed module')
output resourceGroupName string = resourceGroup().name
