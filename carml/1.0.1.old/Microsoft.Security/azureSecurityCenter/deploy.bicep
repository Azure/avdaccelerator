targetScope = 'subscription'

@description('Required. The full Azure ID of the workspace to save the data in.')
param workspaceId string

@description('Required. All the VMs in this scope will send their security data to the mentioned workspace unless overridden by a setting with more specific scope.')
param scope string

@description('Optional. Enable telemetry via the Customer Usage Attribution ID (GUID).')
param enableDefaultTelemetry bool = true

@description('Optional. Describes what kind of security agent provisioning action to take. - On or Off')
@allowed([
  'On'
  'Off'
])
param autoProvision string = 'On'

@description('Optional. Device Security group data')
param deviceSecurityGroupProperties object = {}

@description('Optional. Security Solution data')
param ioTSecuritySolutionProperties object = {}

@description('Optional. The pricing tier value for VMs. Azure Security Center is provided in two pricing tiers: free and standard, with the standard tier available with a trial period. The standard tier offers advanced security capabilities, while the free tier offers basic security features. - Free or Standard')
@allowed([
  'Free'
  'Standard'
])
param virtualMachinesPricingTier string = 'Free'

@description('Optional. The pricing tier value for SqlServers. Azure Security Center is provided in two pricing tiers: free and standard, with the standard tier available with a trial period. The standard tier offers advanced security capabilities, while the free tier offers basic security features. - Free or Standard')
@allowed([
  'Free'
  'Standard'
])
param sqlServersPricingTier string = 'Free'

@description('Optional. The pricing tier value for AppServices. Azure Security Center is provided in two pricing tiers: free and standard, with the standard tier available with a trial period. The standard tier offers advanced security capabilities, while the free tier offers basic security features. - Free or Standard')
@allowed([
  'Free'
  'Standard'
])
param appServicesPricingTier string = 'Free'

@description('Optional. The pricing tier value for StorageAccounts. Azure Security Center is provided in two pricing tiers: free and standard, with the standard tier available with a trial period. The standard tier offers advanced security capabilities, while the free tier offers basic security features. - Free or Standard')
@allowed([
  'Free'
  'Standard'
])
param storageAccountsPricingTier string = 'Free'

@description('Optional. The pricing tier value for SqlServerVirtualMachines. Azure Security Center is provided in two pricing tiers: free and standard, with the standard tier available with a trial period. The standard tier offers advanced security capabilities, while the free tier offers basic security features. - Free or Standard')
@allowed([
  'Free'
  'Standard'
])
param sqlServerVirtualMachinesPricingTier string = 'Free'

@description('Optional. The pricing tier value for KubernetesService. Azure Security Center is provided in two pricing tiers: free and standard, with the standard tier available with a trial period. The standard tier offers advanced security capabilities, while the free tier offers basic security features. - Free or Standard')
@allowed([
  'Free'
  'Standard'
])
param kubernetesServicePricingTier string = 'Free'

@description('Optional. The pricing tier value for ContainerRegistry. Azure Security Center is provided in two pricing tiers: free and standard, with the standard tier available with a trial period. The standard tier offers advanced security capabilities, while the free tier offers basic security features. - Free or Standard')
@allowed([
  'Free'
  'Standard'
])
param containerRegistryPricingTier string = 'Free'

@description('Optional. The pricing tier value for KeyVaults. Azure Security Center is provided in two pricing tiers: free and standard, with the standard tier available with a trial period. The standard tier offers advanced security capabilities, while the free tier offers basic security features. - Free or Standard')
@allowed([
  'Free'
  'Standard'
])
param keyVaultsPricingTier string = 'Free'

@description('Optional. The pricing tier value for DNS. Azure Security Center is provided in two pricing tiers: free and standard, with the standard tier available with a trial period. The standard tier offers advanced security capabilities, while the free tier offers basic security features. - Free or Standard')
@allowed([
  'Free'
  'Standard'
])
param dnsPricingTier string = 'Free'

@description('Optional. The pricing tier value for ARM. Azure Security Center is provided in two pricing tiers: free and standard, with the standard tier available with a trial period. The standard tier offers advanced security capabilities, while the free tier offers basic security features. - Free or Standard')
@allowed([
  'Free'
  'Standard'
])
param armPricingTier string = 'Free'

@description('Optional. The pricing tier value for OpenSourceRelationalDatabases. Azure Security Center is provided in two pricing tiers: free and standard, with the standard tier available with a trial period. The standard tier offers advanced security capabilities, while the free tier offers basic security features. - Free or Standard')
@allowed([
  'Free'
  'Standard'
])
param openSourceRelationalDatabasesTier string = 'Free'

@description('Optional. The pricing tier value for containers. Azure Security Center is provided in two pricing tiers: free and standard, with the standard tier available with a trial period. The standard tier offers advanced security capabilities, while the free tier offers basic security features. - Free or Standard')
@allowed([
  'Free'
  'Standard'
])
param containersTier string = 'Free'

@description('Optional. The pricing tier value for CosmosDbs. Azure Security Center is provided in two pricing tiers: free and standard, with the standard tier available with a trial period. The standard tier offers advanced security capabilities, while the free tier offers basic security features. - Free or Standard')
@allowed([
  'Free'
  'Standard'
])
param cosmosDbsTier string = 'Free'

@description('Optional. Security contact data')
param securityContactProperties object = {}

@description('Optional. Location deployment metadata.')
param location string = deployment().location

resource defaultTelemetry 'Microsoft.Resources/deployments@2021-04-01' = if (enableDefaultTelemetry) {
  name: 'pid-47ed15a6-730a-4827-bcb4-0fd963ffbd82-${uniqueString(deployment().name, location)}'
  location: location
  properties: {
    mode: 'Incremental'
    template: {
      '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      resources: []
    }
  }
}

resource autoProvisioningSettings 'Microsoft.Security/autoProvisioningSettings@2017-08-01-preview' = {
  name: 'default'
  properties: {
    autoProvision: autoProvision
  }
}

resource deviceSecurityGroups 'Microsoft.Security/deviceSecurityGroups@2019-08-01' = if (!empty(deviceSecurityGroupProperties)) {
  name: 'deviceSecurityGroups'
  properties: {
    thresholdRules: deviceSecurityGroupProperties.thresholdRules
    timeWindowRules: deviceSecurityGroupProperties.timeWindowRules
    allowlistRules: deviceSecurityGroupProperties.allowlistRules
    denylistRules: deviceSecurityGroupProperties.denylistRules
  }
}

module iotSecuritySolutions '.bicep/nested_iotSecuritySolutions.bicep' = if (!empty(ioTSecuritySolutionProperties)) {
  name: '${uniqueString(deployment().name)}-ASC-IotSecuritySolutions'
  scope: resourceGroup(empty(ioTSecuritySolutionProperties) ? 'dummy' : ioTSecuritySolutionProperties.resourceGroup)
  params: {
    ioTSecuritySolutionProperties: ioTSecuritySolutionProperties
  }
}

resource VirtualMachinesPricingTier 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'VirtualMachines'
  properties: {
    pricingTier: virtualMachinesPricingTier
  }
}

resource SqlServersPricingTier 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'SqlServers'
  properties: {
    pricingTier: sqlServersPricingTier
  }
}

resource AppServicesPricingTier 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'AppServices'
  properties: {
    pricingTier: appServicesPricingTier
  }
}

resource StorageAccountsPricingTier 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'StorageAccounts'
  properties: {
    pricingTier: storageAccountsPricingTier
  }
}

resource SqlServerVirtualMachinesPricingTier 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'SqlServerVirtualMachines'
  properties: {
    pricingTier: sqlServerVirtualMachinesPricingTier
  }
}

resource KubernetesServicePricingTier 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'KubernetesService'
  properties: {
    pricingTier: kubernetesServicePricingTier
  }
}

resource ContainerRegistryPricingTier 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'ContainerRegistry'
  properties: {
    pricingTier: containerRegistryPricingTier
  }
}

resource KeyVaultsPricingTier 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'KeyVaults'
  properties: {
    pricingTier: keyVaultsPricingTier
  }
}

resource DnsPricingTier 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'Dns'
  properties: {
    pricingTier: dnsPricingTier
  }
}

resource ArmPricingTier 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'Arm'
  properties: {
    pricingTier: armPricingTier
  }
}

resource OpenSourceRelationalDatabasesPricingTier 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'OpenSourceRelationalDatabases'
  properties: {
    pricingTier: openSourceRelationalDatabasesTier
  }
}

resource ContainersPricingTier 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'Containers'
  properties: {
    pricingTier: containersTier
  }
}

resource CosmosDbsPricingTier 'Microsoft.Security/pricings@2018-06-01' = {
  name: 'CosmosDbs'
  properties: {
    pricingTier: cosmosDbsTier
  }
}

resource securityContacts 'Microsoft.Security/securityContacts@2017-08-01-preview' = if (!empty(securityContactProperties)) {
  name: 'securityContacts'
  properties: {
    email: securityContactProperties.email
    phone: securityContactProperties.phone
    alertNotifications: securityContactProperties.alertNotifications
    alertsToAdmins: securityContactProperties.alertsToAdmins
  }
}

resource workspaceSettings 'Microsoft.Security/workspaceSettings@2017-08-01-preview' = {
  name: 'default'
  properties: {
    workspaceId: workspaceId
    scope: scope
  }
  dependsOn: [
    autoProvisioningSettings
  ]
}

@description('The resource IDs of the used log analytics workspace')
output workspaceId string = workspaceId
