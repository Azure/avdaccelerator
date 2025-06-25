targetScope = 'subscription'

param location string
param resourceGroupName string
param time string
param userAssignedIdentityClientId string
param virtualMachineResourceId string

module cleanUp '../common/runCommand/deploy.bicep' = {
  scope: resourceGroup(resourceGroupName)
  name: 'clean-up-${time}'
  params: {
    asyncExecution: true
    location: location
    name: 'Remove-VirtualMachine'
    parameters: [
      {
        name: 'ResourceGroupName'
        value: resourceGroupName
      }
      {
        name: 'ResourceManagerUri'
        value: environment().resourceManager
      }
      {
        name: 'UserAssignedIdentityClientId'
        value: userAssignedIdentityClientId
      }
      {
        name: 'VirtualMachineResourceId'
        value: virtualMachineResourceId
      }
    ]
    script: loadTextContent('../../../scripts/Remove-VirtualMachine.ps1')
    tags: {}
    treatFailureAsDeploymentFailure: true
    virtualMachineName: split(virtualMachineResourceId, '/')[8]
  }
}
