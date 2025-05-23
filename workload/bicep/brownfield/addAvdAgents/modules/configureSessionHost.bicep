// ========== //
// Parameters //
// ========== //

@sys.description('Extension deployment name.')
param name string

@sys.description('Location where to deploy compute services.')
param location string

@sys.description('URI for AVD session host configuration URI path.')
param baseScriptUri string

@sys.description('URI for AVD session host configuration script.')
param scriptName string

@sys.description('AVD Host Pool registration token')
@secure()
param hostPoolToken string

// =========== //
// Variable declaration //
// =========== //
var varIdentityServiceProvider = 'null'
var varScriptArguments = '-AmdVmSize $false -IdentityServiceProvider ${varIdentityServiceProvider} -Fslogix $false -HostPoolRegistrationToken ${hostPoolToken} -NvidiaVmSize $false -verbose'

// =========== //
// Deployments //
// =========== //
resource sessionHostConfig 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  name: '${name}/SessionHostConfig'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: array(baseScriptUri)
    }
    protectedSettings: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${scriptName} ${varScriptArguments}'
    }
  }
}
