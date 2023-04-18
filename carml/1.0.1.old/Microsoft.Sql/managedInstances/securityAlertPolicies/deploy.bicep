@description('Required. The name of the security alert policy')
param name string

@description('Required. Name of the SQL managed instance.')
param managedInstanceName string

@description('Optional. Enables advanced data security features, like recuring vulnerability assesment scans and ATP. If enabled, storage account must be provided.')
@allowed([
  'Enabled'
  'Disabled'
])
param state string = 'Disabled'

@description('Optional. Specifies that the schedule scan notification will be is sent to the subscription administrators.')
param emailAccountAdmins bool = false

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

resource managedInstance 'Microsoft.Sql/managedInstances@2021-05-01-preview' existing = {
  name: managedInstanceName
}

resource securityAlertPolicy 'Microsoft.Sql/managedInstances/securityAlertPolicies@2017-03-01-preview' = {
  name: name
  parent: managedInstance
  properties: {
    state: state
    emailAccountAdmins: emailAccountAdmins
  }
}

@description('The name of the deployed security alert policy')
output name string = securityAlertPolicy.name

@description('The resource ID of the deployed security alert policy')
output resourceId string = securityAlertPolicy.id

@description('The resource group of the deployed security alert policy')
output resourceGroupName string = resourceGroup().name
