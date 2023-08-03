targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //
@sys.description('Deployment location.')
param location string

@sys.description('Deployment script name.')
param name string

@sys.description('Deployment script name.')
param scriptContent string

@sys.description('Tags to be applied to resources')
param tags object

// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //
resource deploymentScript 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: name
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '9.7'
    cleanupPreference: 'Always'
    timeout: 'PT10M'
    retentionInterval: 'PT1H'
    scriptContent: scriptContent
  }
  tags: tags
}
