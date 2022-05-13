param name string
param location string
param baseScriptUri string
param file string
param FsLogixScriptArguments string

resource fslogixconfigure 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  name: '${name}/configurefslogix'
  location: location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {}
    protectedSettings: {
      fileUris: array(baseScriptUri)
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File ${file} ${FsLogixScriptArguments}'
    }
  }
}
