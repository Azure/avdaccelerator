param name string
param location string
param baseScriptUri string
param file string
@secure()
param ScriptArguments string

resource dscStorageScript 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  name: '${name}/dscStorageScript'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {}
    protectedSettings: {
      fileUris: array(baseScriptUri)
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${file} ${ScriptArguments}'
    }
  }
}
