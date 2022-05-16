@description('Required. The name of the of the API Management service.')
param apiManagementServiceName string

@description('Required. The name of the of the Product.')
param productName string

@description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
param enableDefaultTelemetry bool = true

@description('Required. Name of the product API.')
param name string

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

resource service 'Microsoft.ApiManagement/service@2021-08-01' existing = {
  name: apiManagementServiceName

  resource product 'products@2021-04-01-preview' existing = {
    name: productName
  }
}

resource api 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  name: name
  parent: service::product
}

@description('The resource ID of the product API')
output resourceId string = api.id

@description('The name of the product API')
output name string = api.name

@description('The resource group the product API was deployed into')
output resourceGroupName string = resourceGroup().name
