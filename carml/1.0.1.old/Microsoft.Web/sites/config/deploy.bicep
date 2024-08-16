@description('Required. Name of the site config.')
@allowed([
  'appsettings'
])
param name string

@description('Required. Name of the site parent resource.')
param appName string

@description('Optional. Required if app of kind functionapp. Resource ID of the storage account to manage triggers and logging function executions.')
param storageAccountId string = ''

@description('Optional. Runtime of the function worker.')
@allowed([
  'dotnet'
  'node'
  'python'
  'java'
  'powershell'
  ''
])
param functionsWorkerRuntime string = ''

@description('Optional. Version of the function extension.')
param functionsExtensionVersion string = '~3'

@description('Optional. Resource ID of the app insight to leverage for this resource.')
param appInsightId string = ''

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

resource appInsight 'microsoft.insights/components@2020-02-02' existing = if (!empty(appInsightId)) {
  name: last(split(appInsightId, '/'))
  scope: resourceGroup(split(appInsightId, '/')[2], split(appInsightId, '/')[4])
}

resource storageAccount 'Microsoft.Storage/storageAccounts@2021-02-01' existing = if (!empty(storageAccountId)) {
  name: last(split(storageAccountId, '/'))
  scope: resourceGroup(split(storageAccountId, '/')[2], split(storageAccountId, '/')[4])
}

resource app 'Microsoft.Web/sites@2020-12-01' existing = {
  name: appName
}

resource config 'Microsoft.Web/sites/config@2021-02-01' = {
  name: name
  parent: app
  properties: {
    AzureWebJobsStorage: !empty(storageAccountId) ? 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};' : any(null)
    AzureWebJobsDashboard: !empty(storageAccountId) ? 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};' : any(null)
    FUNCTIONS_EXTENSION_VERSION: app.kind == 'functionapp' && !empty(functionsExtensionVersion) ? functionsExtensionVersion : any(null)
    FUNCTIONS_WORKER_RUNTIME: app.kind == 'functionapp' && !empty(functionsWorkerRuntime) ? functionsWorkerRuntime : any(null)
    APPINSIGHTS_INSTRUMENTATIONKEY: !empty(appInsightId) ? appInsight.properties.InstrumentationKey : ''
    APPLICATIONINSIGHTS_CONNECTION_STRING: !empty(appInsightId) ? appInsight.properties.ConnectionString : ''
  }
}

@description('The name of the site config.')
output name string = config.name

@description('The resource ID of the site config.')
output resourceId string = config.id

@description('The resource group the site config was deployed into.')
output resourceGroupName string = resourceGroup().name
