// ========== //
// Parameters //
// ========== //

@sys.description('Determine whether the run command should be executed asynchronously.')
param asyncExecution bool = false

@sys.description('The Azure location where the run command resource will be created.')
param location string

@sys.description('The name of the run command resource.')
param name string

@sys.description('The parameters required by the script to run on the virtual machine.')
param parameters array = []

@sys.description('The inline script to run on the virtual machine.')
param script string

@sys.description('Metadata tags to apply to the run command resource.')
param tags object

@sys.description('Determine whether the run command should be treated as a deployment failure if it fails.')
param treatFailureAsDeploymentFailure bool = true

@sys.description('The name of the virtual machine to run the command on.')
param virtualMachineName string

// =========== //
// Deployments //
// =========== //

// Existing Virtual Machine
resource virtualMachine 'Microsoft.Compute/virtualMachines@2024-11-01' existing = {
  name: virtualMachineName
}

// Run Command
resource runCommand 'Microsoft.Compute/virtualMachines/runCommands@2024-11-01' = {
  parent: virtualMachine
  name: name
  location: location
  tags: tags 
  properties: {
    asyncExecution: asyncExecution
    parameters: parameters
    source: {
      script: script
    }
    treatFailureAsDeploymentFailure: treatFailureAsDeploymentFailure
  }
}
