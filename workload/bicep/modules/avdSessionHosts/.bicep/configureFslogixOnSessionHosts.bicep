// ========== //
// Parameters //
// ========== //

@description('Extension deployment name.')
param name string

@description('Location where to deploy compute services.')
param location string

@description('URI for FSlogix configuration script.')
param baseScriptUri string

@description('FSlogix configuration script file name.')
param file string

@description('Configuration arguments for FSlogix.')
param fsLogixScriptArguments string

// =========== //
// Deployments //
// =========== //

// FSLogix configuration.
resource fslogixconfigure 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: '${name}/FSlogixSetup'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {}
    protectedSettings: {
      fileUris: array(baseScriptUri)
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${file} ${fsLogixScriptArguments}'
    }
  }
}
