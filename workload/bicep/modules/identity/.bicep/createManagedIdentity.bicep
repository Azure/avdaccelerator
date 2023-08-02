targetScope = 'resourceGroup'

// ========== //
// Parameters //
// ========== //
@sys.description('Location where to deploy managed identity.')
param location string

@sys.description('Managed ientity name.')
param name string

@sys.description('Tags to be applied to resources')
param tags object

@sys.description('Do not modify, used to set unique value for resource deployment.')
param time string = utcNow()

// =========== //
// Variable declaration //
// =========== //

// =========== //
// Deployments //
// =========== //

// Managed identity
resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: name
  location: location
  tags: tags
}

// Introduce wait for management VM to be ready.
resource managedIdentityWait 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'MI-${name}-Wait-${time}'
  location: location
  kind: 'AzurePowerShell'
  properties: {
    azPowerShellVersion: '9.7' //'8.3.0'
    cleanupPreference: 'Always'
    timeout: 'PT10M'
    retentionInterval: 'PT1H'
    scriptContent: '''
      Write-Host "Start"
      Get-Date
      Start-Sleep -Seconds 60
      Write-Host "Stop"
      Get-Date
      '''
  }
  tags: tags
  dependsOn: [
    managedIdentity
  ]
}

// =========== //
// Outputs //
// =========== //
output resourceId string = managedIdentity.id
output clientId string = managedIdentity.properties.clientId
output principalId string = managedIdentity.properties.principalId
