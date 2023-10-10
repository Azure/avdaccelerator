// ========== //
// Parameters //
// ========== //

@sys.description('Extension deployment name.')
param name string

@sys.description('Location where to deploy compute services.')
param location string

@sys.description('URI for FSlogix configuration script.')
param baseScriptUri string

@sys.description('AVD Host Pool registration token')
//@secure()
param hostPoolToken string

// =========== //
// Variable declaration //
// =========== //
var varScriptArguments = '-HostPoolRegistrationToken ${hostPoolToken}'
var file = './Set-AvdAgents.ps1'

// =========== //
// Deployments //
// =========== //
// Add session hosts to Host Pool.
resource addToHostPool 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: '${name}/HostPoolRegistration'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    protectedSettings: {
      fileUris: array(baseScriptUri)
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${file} ${varScriptArguments}'
    }
  }
}
