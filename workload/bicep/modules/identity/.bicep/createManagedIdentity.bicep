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

// Introduce wait for managed identity to be ready
module managedIdentityWait '../../deploymentScripts/deploy.bicep' = {
  name: 'MI-${name}-Wait-${time}'
  params: {
    name: 'MI-${name}-Wait-${time}'
    location: location
    scriptContent: '''
      Write-Host "Start"
      Get-Date
      Start-Sleep -Seconds 60
      Write-Host "Stop"
      Get-Date
      '''
    tags: tags
  }
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
