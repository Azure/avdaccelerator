// ========== //
// Parameters //
// ========== //

@sys.description('Extension deployment name.')
param name string

@sys.description('Location where to deploy compute services.')
param location string

@sys.description('URI for clean up configuration script.')
param baseScriptUri string

@sys.description('Clean up script file name.')
param file string

@sys.description('Configuration arguments for clean up script.')
param cleanUpScriptArguments string

// =========== //
// Deployments //
// =========== //

// Clean up RG deployments.
resource fslogixConfigure 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: '${name}/DeploymentCleanUp'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {}
    protectedSettings: {
      fileUris: array(baseScriptUri)
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${file} ${cleanUpScriptArguments}'
    }
  }
}


